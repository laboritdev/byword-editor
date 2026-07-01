import AppKit
import SwiftUI

@MainActor
protocol EditorTextViewDelegate: AnyObject {
    func editorTextDidChange(_ text: String)
    func editorSelectionDidChange(location: Int, length: Int)
    func editorScrollDidChange(offset: Double)
}

struct EditorConfiguration: Equatable {
    var font: NSFont
    var textColor: NSColor
    var backgroundColor: NSColor
    var lineHeight: CGFloat
    var horizontalMargin: CGFloat
    var columnWidth: CGFloat
    var syntaxColors: EditorColorsNS

    static func == (lhs: EditorConfiguration, rhs: EditorConfiguration) -> Bool {
        lhs.font.fontName == rhs.font.fontName
            && lhs.font.pointSize == rhs.font.pointSize
            && lhs.textColor == rhs.textColor
            && lhs.backgroundColor == rhs.backgroundColor
            && lhs.lineHeight == rhs.lineHeight
            && lhs.horizontalMargin == rhs.horizontalMargin
            && lhs.columnWidth == rhs.columnWidth
            && lhs.syntaxColors == rhs.syntaxColors
    }
}

struct NSTextViewRepresentable: NSViewRepresentable {
    @Binding var text: String
    var configuration: EditorConfiguration
    var cursorLocation: Int
    var selectionLength: Int
    var scrollOffset: Double
    var delegate: EditorTextViewDelegate?

    func makeNSView(context: Context) -> NSScrollView {
        let scrollView = MarkdownScrollView()
        scrollView.hasVerticalScroller = true
        scrollView.borderType = .noBorder
        scrollView.autohidesScrollers = true
        scrollView.drawsBackground = false

        let textView = MarkdownTextView()
        textView.isEditable = true
        textView.isSelectable = true
        textView.isRichText = true
        textView.drawsBackground = true
        textView.isAutomaticQuoteSubstitutionEnabled = false
        textView.isAutomaticDashSubstitutionEnabled = false
        textView.isAutomaticTextReplacementEnabled = false
        textView.isAutomaticSpellingCorrectionEnabled = false
        textView.allowsUndo = true
        textView.usesFindBar = true
        textView.isIncrementalSearchingEnabled = true
        textView.textContainer?.widthTracksTextView = false
        textView.textContainer?.containerSize = NSSize(
            width: configuration.columnWidth,
            height: CGFloat.greatestFiniteMagnitude
        )
        textView.isHorizontallyResizable = false
        textView.isVerticallyResizable = true
        textView.textContainerInset = NSSize(
            width: configuration.horizontalMargin,
            height: 48
        )
        textView.delegate = context.coordinator

        scrollView.documentView = textView
        scrollView.hasHorizontalScroller = false
        scrollView.contentView.postsBoundsChangedNotifications = true

        context.coordinator.textView = textView
        context.coordinator.scrollView = scrollView
        context.coordinator.delegate = delegate
        context.coordinator.applyConfiguration(configuration)
        context.coordinator.setText(text, cursorLocation: cursorLocation, selectionLength: selectionLength)

        DispatchQueue.main.async {
            textView.window?.makeFirstResponder(textView)
        }

        NotificationCenter.default.addObserver(
            context.coordinator,
            selector: #selector(Coordinator.scrollViewDidScroll(_:)),
            name: NSView.boundsDidChangeNotification,
            object: scrollView.contentView
        )

        return scrollView
    }

    func updateNSView(_ scrollView: NSScrollView, context: Context) {
        guard scrollView.documentView is MarkdownTextView else { return }
        context.coordinator.parent = self
        context.coordinator.delegate = delegate

        if context.coordinator.lastConfiguration != configuration {
            context.coordinator.lastConfiguration = configuration
            context.coordinator.applyConfiguration(configuration)
        }

        if context.coordinator.lastKnownText != text {
            context.coordinator.setText(text, cursorLocation: cursorLocation, selectionLength: selectionLength)
        }

        if abs(context.coordinator.lastScrollOffset - scrollOffset) > 1 {
            context.coordinator.setScrollOffset(scrollOffset)
        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(parent: self)
    }

    @MainActor
    final class Coordinator: NSObject, NSTextViewDelegate {
        var parent: NSTextViewRepresentable
        weak var textView: MarkdownTextView?
        weak var scrollView: NSScrollView?
        weak var delegate: EditorTextViewDelegate?
        var lastKnownText: String = ""
        var lastScrollOffset: Double = 0
        var lastConfiguration: EditorConfiguration?
        private let highlighter = MarkdownSyntaxHighlighter()
        private var isUpdating = false

        init(parent: NSTextViewRepresentable) {
            self.parent = parent
        }

        func applyConfiguration(_ configuration: EditorConfiguration) {
            guard let textView else { return }
            textView.backgroundColor = configuration.backgroundColor
            textView.textColor = configuration.textColor
            textView.insertionPointColor = configuration.textColor
            textView.selectedTextAttributes = [
                .backgroundColor: NSColor.selectedTextBackgroundColor,
            ]
            textView.typingAttributes = [
                .font: configuration.font,
                .foregroundColor: configuration.textColor,
            ]
            textView.textContainer?.containerSize = NSSize(
                width: configuration.columnWidth,
                height: CGFloat.greatestFiniteMagnitude
            )
            textView.textContainerInset = NSSize(width: configuration.horizontalMargin, height: 48)
            refreshHighlighting(configuration: configuration)
        }

        func setText(_ text: String, cursorLocation: Int, selectionLength: Int) {
            guard let textView, let storage = textView.textStorage else { return }
            isUpdating = true
            defer { isUpdating = false }

            if storage.string != text {
                storage.setAttributedString(NSAttributedString(string: text))
                refreshHighlighting(configuration: parent.configuration)
            }

            let nsString = textView.string as NSString
            let safeLocation = min(max(0, cursorLocation), nsString.length)
            let safeLength = min(selectionLength, nsString.length - safeLocation)
            textView.setSelectedRange(NSRange(location: safeLocation, length: safeLength))
            lastKnownText = text
        }

        func setScrollOffset(_ offset: Double) {
            guard let scrollView else { return }
            scrollView.contentView.scroll(to: NSPoint(x: 0, y: offset))
            lastScrollOffset = offset
        }

        @objc func scrollViewDidScroll(_ notification: Notification) {
            guard let scrollView, !isUpdating else { return }
            let offset = scrollView.contentView.bounds.origin.y
            lastScrollOffset = offset
            delegate?.editorScrollDidChange(offset: offset)
        }

        func textDidChange(_ notification: Notification) {
            guard !isUpdating, let textView else { return }
            let newText = textView.string
            lastKnownText = newText
            parent.text = newText
            delegate?.editorTextDidChange(newText)
            refreshHighlighting(configuration: parent.configuration)
        }

        func textViewDidChangeSelection(_ notification: Notification) {
            guard let textView else { return }
            let range = textView.selectedRange()
            delegate?.editorSelectionDidChange(location: range.location, length: range.length)
        }

        private func refreshHighlighting(configuration: EditorConfiguration) {
            guard let textView, let storage = textView.textStorage else { return }
            let range = NSRange(location: 0, length: storage.length)
            let baseStyle = SyntaxStyle(
                font: configuration.font,
                foregroundColor: configuration.textColor,
                backgroundColor: nil
            )
            highlighter.applyHighlighting(
                to: storage,
                in: range,
                baseStyle: baseStyle,
                colors: configuration.syntaxColors
            )
        }
    }
}

final class MarkdownScrollView: NSScrollView {}

final class MarkdownTextView: NSTextView {}
