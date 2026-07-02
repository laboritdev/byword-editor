import AppKit
import SwiftUI
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
    var syntaxHighlightMode: SyntaxHighlightMode
    var isDarkMode: Bool
    var colorTheme: ColorTheme

    static func == (lhs: EditorConfiguration, rhs: EditorConfiguration) -> Bool {
        lhs.font.fontName == rhs.font.fontName
            && lhs.font.pointSize == rhs.font.pointSize
            && lhs.textColor.isEditorEqual(to: rhs.textColor)
            && lhs.backgroundColor.isEditorEqual(to: rhs.backgroundColor)
            && lhs.lineHeight == rhs.lineHeight
            && lhs.horizontalMargin == rhs.horizontalMargin
            && lhs.columnWidth == rhs.columnWidth
            && lhs.syntaxColors == rhs.syntaxColors
            && lhs.syntaxHighlightMode == rhs.syntaxHighlightMode
            && lhs.isDarkMode == rhs.isDarkMode
            && lhs.colorTheme == rhs.colorTheme
    }
}

struct NSTextViewRepresentable: NSViewRepresentable {
    @Binding var text: String
    var configuration: EditorConfiguration
    var cursorLocation: Int
    var selectionLength: Int
    var scrollOffset: Double
    var delegate: EditorTextViewDelegate?
    var onToggleCheckbox: ((Int) -> TaskListEditResult?)?
    var onListContinuation: ((Int, String) -> TaskListEditResult?)?

    func makeNSView(context: Context) -> NSScrollView {
        let scrollView = MarkdownScrollView()
        scrollView.hasVerticalScroller = true
        scrollView.borderType = .noBorder
        scrollView.autohidesScrollers = true
        scrollView.scrollerStyle = .overlay
        scrollView.drawsBackground = true
        scrollView.appearance = NSAppearance(
            named: configuration.isDarkMode ? .darkAqua : .aqua
        )

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
            height: EditorTypography.verticalTextInset
        )
        textView.delegate = context.coordinator
        textView.onToggleCheckbox = { [weak coordinator = context.coordinator] index in
            coordinator?.handleCheckboxClick(at: index) ?? false
        }
        textView.onListContinuation = { [weak coordinator = context.coordinator] location in
            coordinator?.handleListContinuation(at: location) ?? false
        }
        textView.onWindowAttached = { [weak coordinator = context.coordinator] in
            coordinator?.syncWhenWindowAttached()
        }

        scrollView.documentView = textView
        scrollView.hasHorizontalScroller = false
        scrollView.contentView.postsBoundsChangedNotifications = true

        context.coordinator.textView = textView
        context.coordinator.scrollView = scrollView
        context.coordinator.delegate = delegate
        context.coordinator.applyConfiguration(configuration)
        context.coordinator.setText(text, cursorLocation: cursorLocation, selectionLength: selectionLength)

        let coordinator = context.coordinator
        let initialText = text
        let initialCursor = cursorLocation
        let initialSelection = selectionLength
        DispatchQueue.main.async {
            coordinator.setText(initialText, cursorLocation: initialCursor, selectionLength: initialSelection)
        }

        DispatchQueue.main.async {
            textView.window?.makeFirstResponder(textView)
        }

        NotificationCenter.default.addObserver(
            context.coordinator,
            selector: #selector(Coordinator.scrollViewDidScroll(_:)),
            name: NSView.boundsDidChangeNotification,
            object: scrollView.contentView
        )

        NotificationCenter.default.addObserver(
            context.coordinator,
            selector: #selector(Coordinator.effectiveAppearanceDidChange(_:)),
            name: .editorEffectiveAppearanceDidChange,
            object: nil
        )

        return scrollView
    }

    func updateNSView(_ scrollView: NSScrollView, context: Context) {
        guard let textView = scrollView.documentView as? MarkdownTextView else { return }
        context.coordinator.parent = self
        context.coordinator.delegate = delegate
        context.coordinator.onToggleCheckbox = onToggleCheckbox
        context.coordinator.onListContinuation = onListContinuation
        textView.onToggleCheckbox = { [weak coordinator = context.coordinator] index in
            coordinator?.handleCheckboxClick(at: index) ?? false
        }
        textView.onListContinuation = { [weak coordinator = context.coordinator] location in
            coordinator?.handleListContinuation(at: location) ?? false
        }
        textView.onWindowAttached = { [weak coordinator = context.coordinator] in
            coordinator?.syncWhenWindowAttached()
        }

        if context.coordinator.lastAppliedConfiguration != configuration {
            context.coordinator.lastAppliedConfiguration = configuration
            context.coordinator.applyConfiguration(configuration)
        }

        if context.coordinator.needsTextSync(
            textView: textView,
            text: text,
            cursorLocation: cursorLocation,
            selectionLength: selectionLength
        ) {
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
        var onToggleCheckbox: ((Int) -> TaskListEditResult?)?
        var onListContinuation: ((Int, String) -> TaskListEditResult?)?
        var lastKnownText: String = ""
        var lastKnownCursor: Int = 0
        var lastKnownSelectionLength: Int = 0
        var lastScrollOffset: Double = 0
        var lastAppliedConfiguration: EditorConfiguration?
        private let highlighter = MarkdownSyntaxHighlighter()
        private var isUpdating = false

        init(parent: NSTextViewRepresentable) {
            self.parent = parent
        }

        func handleCheckboxClick(at index: Int) -> Bool {
            guard let result = onToggleCheckbox?(index) else { return false }
            setText(result.text, cursorLocation: result.cursorLocation, selectionLength: 0)
            delegate?.editorSelectionDidChange(location: result.cursorLocation, length: 0)
            return true
        }

        func handleListContinuation(at location: Int) -> Bool {
            guard let textView else { return false }
            guard let result = onListContinuation?(location, textView.string) else { return false }
            applyStructuralEdit(text: result.text, cursorLocation: result.cursorLocation)
            return true
        }

        func syncWhenWindowAttached() {
            applyConfiguration(parent.configuration)
            setText(
                parent.text,
                cursorLocation: parent.cursorLocation,
                selectionLength: parent.selectionLength
            )
        }

        func needsTextSync(
            textView: MarkdownTextView,
            text: String,
            cursorLocation: Int,
            selectionLength: Int
        ) -> Bool {
            let storageLength = textView.textStorage?.length ?? 0
            if !text.isEmpty && storageLength == 0 {
                return true
            }
            if textView.string != text {
                return true
            }
            if lastKnownCursor != cursorLocation || lastKnownSelectionLength != selectionLength {
                return true
            }
            return false
        }

        private func applyStructuralEdit(text: String, cursorLocation: Int) {
            setText(text, cursorLocation: cursorLocation, selectionLength: 0)
            delegate?.editorSelectionDidChange(location: cursorLocation, length: 0)

            guard let textView else { return }
            let nsText = text as NSString
            let safeLocation = min(max(0, cursorLocation), nsText.length)
            textView.scrollRangeToVisible(NSRange(location: safeLocation, length: 0))

            DispatchQueue.main.async { [weak self] in
                guard let self, let textView = self.textView else { return }
                let length = (textView.string as NSString).length
                let cursor = min(max(0, cursorLocation), length)
                self.isUpdating = true
                textView.setSelectedRange(NSRange(location: cursor, length: 0))
                textView.scrollRangeToVisible(NSRange(location: cursor, length: 0))
                self.isUpdating = false
                self.lastKnownCursor = cursor
                self.delegate?.editorSelectionDidChange(location: cursor, length: 0)
            }
        }

        func applyConfiguration(_ configuration: EditorConfiguration) {
            guard let textView else { return }

            let resolvedConfiguration = configuration.resolved(for: textView.effectiveAppearance)
            let textColor = resolvedConfiguration.textColor.editorFixed
            let backgroundColor = resolvedConfiguration.backgroundColor.editorFixed
            let font = resolvedConfiguration.font

            let appearance = NSAppearance(
                named: resolvedConfiguration.isDarkMode ? .darkAqua : .aqua
            )
            textView.appearance = appearance
            scrollView?.appearance = appearance
            scrollView?.backgroundColor = backgroundColor
            scrollView?.contentView.drawsBackground = true
            scrollView?.contentView.backgroundColor = backgroundColor
            textView.usesAdaptiveColorMappingForDarkAppearance = false
            textView.backgroundColor = backgroundColor
            textView.textColor = textColor
            textView.font = font
            textView.insertionPointColor = textColor
            textView.selectedTextAttributes = [
                .backgroundColor: resolvedConfiguration.syntaxColors.selection.editorFixed,
                .foregroundColor: textColor,
            ]
            textView.typingAttributes = baseAttributes(for: resolvedConfiguration)
            textView.textContainer?.containerSize = NSSize(
                width: resolvedConfiguration.columnWidth,
                height: CGFloat.greatestFiniteMagnitude
            )
            textView.textContainerInset = NSSize(
                width: resolvedConfiguration.horizontalMargin,
                height: EditorTypography.verticalTextInset
            )
            refreshHighlighting(configuration: resolvedConfiguration)
            textView.needsDisplay = true
        }

        private func resolvedConfiguration(for textView: MarkdownTextView) -> EditorConfiguration {
            parent.configuration.resolved(for: textView.effectiveAppearance)
        }

        private func baseAttributes(for configuration: EditorConfiguration) -> [NSAttributedString.Key: Any] {
            EditorTypography.baseAttributes(
                font: configuration.font,
                textColor: configuration.textColor,
                lineHeight: configuration.lineHeight
            )
        }

        func setText(_ text: String, cursorLocation: Int, selectionLength: Int) {
            guard let textView, let storage = textView.textStorage else { return }
            isUpdating = true
            defer { isUpdating = false }

            let configuration = parent.configuration.resolved(for: textView.effectiveAppearance)
            let textColor = configuration.textColor.editorFixed

            if storage.string != text {
                let attributed = NSAttributedString(
                    string: text,
                    attributes: baseAttributes(for: configuration)
                )
                storage.setAttributedString(attributed)
            }

            refreshHighlighting(configuration: configuration)

            textView.textColor = textColor
            textView.font = configuration.font
            textView.insertionPointColor = textColor
            textView.typingAttributes = baseAttributes(for: configuration)

            let nsString = textView.string as NSString
            let safeLocation = min(max(0, cursorLocation), nsString.length)
            let safeLength = min(selectionLength, nsString.length - safeLocation)
            textView.setSelectedRange(NSRange(location: safeLocation, length: safeLength))
            lastKnownText = text
            lastKnownCursor = safeLocation
            lastKnownSelectionLength = safeLength
            textView.layoutManager?.ensureLayout(for: textView.textContainer!)
            textView.needsDisplay = true
        }

        func setScrollOffset(_ offset: Double) {
            guard let scrollView else { return }
            scrollView.contentView.scroll(to: NSPoint(x: 0, y: offset))
            lastScrollOffset = offset
        }

        @objc func effectiveAppearanceDidChange(_ notification: Notification) {
            guard let textView else { return }
            applyConfiguration(parent.configuration)
            setText(
                parent.text,
                cursorLocation: parent.cursorLocation,
                selectionLength: parent.selectionLength
            )
            textView.needsDisplay = true
        }

        @objc func scrollViewDidScroll(_ notification: Notification) {
            guard let scrollView, !isUpdating else { return }
            let offset = scrollView.contentView.bounds.origin.y
            lastScrollOffset = offset
            delegate?.editorScrollDidChange(offset: offset)
        }

        func textView(
            _ textView: NSTextView,
            shouldChangeTextIn affectedCharRange: NSRange,
            replacementString: String?
        ) -> Bool {
            guard let markdownTextView = textView as? MarkdownTextView else { return true }
            textView.typingAttributes = baseAttributes(for: resolvedConfiguration(for: markdownTextView))
            return true
        }

        func textDidChange(_ notification: Notification) {
            guard !isUpdating, let textView else { return }
            let newText = textView.string
            guard newText != lastKnownText else { return }
            lastKnownText = newText
            parent.text = newText
            delegate?.editorTextDidChange(newText)
            let configuration = resolvedConfiguration(for: textView)
            textView.typingAttributes = baseAttributes(for: configuration)
            refreshHighlighting(configuration: configuration)
            textView.needsDisplay = true
        }

        func textViewDidChangeSelection(_ notification: Notification) {
            guard let textView else { return }
            let range = textView.selectedRange()
            delegate?.editorSelectionDidChange(location: range.location, length: range.length)
        }

        private func refreshHighlighting(configuration: EditorConfiguration) {
            guard let textView, let storage = textView.textStorage else { return }
            let range = NSRange(location: 0, length: storage.length)
            let textColor = configuration.textColor.editorFixed
            let backgroundColor = configuration.backgroundColor.editorFixed
            let baseStyle = SyntaxStyle(
                font: configuration.font,
                foregroundColor: textColor,
                backgroundColor: nil,
                lineHeight: configuration.lineHeight,
                isDarkMode: configuration.isDarkMode
            )
            highlighter.applyHighlighting(
                to: storage,
                in: range,
                baseStyle: baseStyle,
                colors: configuration.syntaxColors,
                mode: configuration.syntaxHighlightMode
            )
            ensureLegibleForeground(
                in: storage,
                textColor: textColor,
                backgroundColor: backgroundColor
            )
        }

        private func ensureLegibleForeground(
            in storage: NSMutableAttributedString,
            textColor: NSColor,
            backgroundColor: NSColor
        ) {
            guard storage.length > 0 else { return }

            let fallback = textColor.editorFixed
            let background = backgroundColor.editorFixed
            let fullRange = NSRange(location: 0, length: storage.length)

            storage.enumerateAttributes(in: fullRange) { attributes, range, _ in
                let foreground = (attributes[.foregroundColor] as? NSColor)?.editorFixed
                if foreground == nil
                    || foreground!.alphaComponent < 0.05
                    || !Self.hasVisibleContrast(foreground!, against: background) {
                    storage.addAttribute(.foregroundColor, value: fallback, range: range)
                }
            }
        }

        private static func hasVisibleContrast(_ foreground: NSColor, against background: NSColor) -> Bool {
            let delta = abs(foreground.luminance - background.luminance)
            return delta >= 0.08 || foreground.alphaComponent >= 0.5
        }
    }
}

private extension NSColor {
    var luminance: CGFloat {
        let color = editorFixed
        return 0.2126 * color.redComponent
            + 0.7152 * color.greenComponent
            + 0.0722 * color.blueComponent
    }
}

private extension EditorConfiguration {
    func resolved(for appearance: NSAppearance) -> EditorConfiguration {
        guard EditorAppearance.isDark(appearance) != isDarkMode else { return self }

        let scheme: ColorScheme = EditorAppearance.isDark(appearance) ? .dark : .light
        let colors = EditorColorsNS.colors(
            for: scheme,
            theme: colorTheme,
            syntaxMode: syntaxHighlightMode
        )
        return EditorConfiguration(
            font: font,
            textColor: colors.text,
            backgroundColor: colors.background,
            lineHeight: lineHeight,
            horizontalMargin: horizontalMargin,
            columnWidth: columnWidth,
            syntaxColors: colors,
            syntaxHighlightMode: syntaxHighlightMode,
            isDarkMode: scheme == .dark,
            colorTheme: colorTheme
        )
    }
}

final class MarkdownScrollView: NSScrollView {}

private extension Notification.Name {
    static let editorEffectiveAppearanceDidChange = Notification.Name(
        "NSApplicationDidChangeEffectiveAppearanceNotification"
    )
}

final class MarkdownTextView: NSTextView {
    var onToggleCheckbox: ((Int) -> Bool)?
    var onListContinuation: ((Int) -> Bool)?
    var onWindowAttached: (() -> Void)?

    override func viewDidMoveToWindow() {
        super.viewDidMoveToWindow()
        guard window != nil else { return }
        onWindowAttached?()
    }

    override func insertNewline(_ sender: Any?) {
        if onListContinuation?(selectedRange().location) == true {
            return
        }
        super.insertNewline(sender)
    }

    override func mouseDown(with event: NSEvent) {
        let point = convert(event.locationInWindow, from: nil)
        let index = characterIndexForInsertion(at: point)
        if onToggleCheckbox?(index) == true {
            return
        }
        super.mouseDown(with: event)
    }
}
