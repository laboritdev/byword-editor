import AppKit
import Testing
@testable import LabWordCore

@Suite("Editor Typography")
struct EditorTypographyTests {
    @Test("paragraph style applies configured line height")
    func paragraphStyleLineHeight() {
        let font = NSFont.systemFont(ofSize: 18)
        let style = EditorTypography.paragraphStyle(lineHeight: 1.7, font: font)
        #expect(style.lineHeightMultiple == 1.7)
        #expect(style.lineSpacing > 0)
    }

    @Test("centered margin keeps minimum side margin")
    func centeredMargin() {
        let margin = EditorTypography.centeredHorizontalMargin(
            containerWidth: 900,
            columnWidth: 640,
            minimumMargin: 64
        )
        #expect(margin == 130)
    }

    @Test("centered margin respects minimum when window is narrow")
    func centeredMarginMinimum() {
        let margin = EditorTypography.centeredHorizontalMargin(
            containerWidth: 700,
            columnWidth: 640,
            minimumMargin: 64
        )
        #expect(margin == 64)
    }
}

@Suite("Editor Theme")
struct EditorThemeTests {
    @Test("subtle syntax mode brightens headings relative to body")
    func subtleSyntaxBrightensHeadings() {
        let colors = EditorColorsNS.colors(for: .light, theme: .classic, syntaxMode: .subtle)
        #expect(!colors.heading.isEditorEqual(to: colors.text))
        #expect(colors.syntaxMarker.isEditorEqual(to: colors.listMarker))
    }

    @Test("classic dark uses warm charcoal background")
    func classicDarkBackground() {
        let colors = EditorColorsNS.colors(for: .dark, theme: .classic, syntaxMode: .subtle)
        let background = colors.background.editorFixed
        #expect(background.redComponent < 0.18)
        #expect(background.redComponent > 0.08)
        #expect(abs(background.redComponent - background.blueComponent) < 0.02)
    }

    @Test("syntax marker is muted relative to body text")
    func syntaxMarkerIsMuted() {
        let colors = EditorColorsNS.colors(for: .dark, theme: .classic, syntaxMode: .subtle)
        #expect(!colors.syntaxMarker.isEditorEqual(to: colors.text))
    }
}
