import AppKit
import SwiftUI
import Testing
@testable import LabWordCore

@Suite("Editor Highlight Legibility")
struct EditorHighlightLegibilityTests {
    @Test("intro demo keeps visible foreground in dark mode")
    func introDemoDarkModeForeground() throws {
        try assertLegibleHighlighting(
            text: IntroDemoContent.content,
            scheme: .dark,
            theme: .classic,
            mode: .subtle
        )
    }

    @Test("intro demo keeps visible foreground in light mode")
    func introDemoLightModeForeground() throws {
        try assertLegibleHighlighting(
            text: IntroDemoContent.content,
            scheme: .light,
            theme: .classic,
            mode: .subtle
        )
    }

    @Test("subtle mode enlarges heading font")
    func headingFontSize() {
        let text = "# NOW\n## working\nBody"
        let colors = EditorColorsNS.colors(for: .dark, theme: .classic, syntaxMode: .subtle)
        let font = NSFont(name: "Menlo", size: 18) ?? NSFont.monospacedSystemFont(ofSize: 18, weight: .regular)
        let storage = NSMutableAttributedString(
            string: text,
            attributes: EditorTypography.baseAttributes(font: font, textColor: colors.text, lineHeight: 1.7)
        )
        let highlighter = MarkdownSyntaxHighlighter()
        let baseStyle = SyntaxStyle(
            font: font,
            foregroundColor: colors.text.editorFixed,
            backgroundColor: nil,
            lineHeight: 1.7,
            isDarkMode: true
        )
        highlighter.applyHighlighting(
            to: storage,
            in: NSRange(location: 0, length: storage.length),
            baseStyle: baseStyle,
            colors: colors,
            mode: .subtle
        )

        let headingFont = storage.attribute(.font, at: 2, effectiveRange: nil) as? NSFont
        let bodyFont = storage.attribute(.font, at: text.utf16.count - 1, effectiveRange: nil) as? NSFont
        #expect(headingFont != nil)
        #expect(bodyFont != nil)
        #expect(headingFont!.pointSize > bodyFont!.pointSize)
    }

    private func assertLegibleHighlighting(
        text: String,
        scheme: ColorScheme,
        theme: ColorTheme,
        mode: SyntaxHighlightMode
    ) throws {
        let colors = EditorColorsNS.colors(for: scheme, theme: theme, syntaxMode: mode)
        let font = NSFont.monospacedSystemFont(ofSize: 18, weight: .regular)
        let storage = NSMutableAttributedString(
            string: text,
            attributes: EditorTypography.baseAttributes(
                font: font,
                textColor: colors.text,
                lineHeight: 1.7
            )
        )

        let highlighter = MarkdownSyntaxHighlighter()
        let baseStyle = SyntaxStyle(
            font: font,
            foregroundColor: colors.text.editorFixed,
            backgroundColor: nil,
            lineHeight: 1.7,
            isDarkMode: scheme == .dark
        )
        highlighter.applyHighlighting(
            to: storage,
            in: NSRange(location: 0, length: storage.length),
            baseStyle: baseStyle,
            colors: colors,
            mode: mode
        )

        let background = colors.background.editorFixed
        let fullRange = NSRange(location: 0, length: storage.length)
        storage.enumerateAttributes(in: fullRange) { attributes, _, _ in
            let foreground = (attributes[.foregroundColor] as? NSColor)?.editorFixed
            #expect(foreground != nil)
            #expect(foreground!.alphaComponent >= 0.5)
            let delta = abs(foreground!.luminance - background.luminance)
            #expect(delta >= 0.08)
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
