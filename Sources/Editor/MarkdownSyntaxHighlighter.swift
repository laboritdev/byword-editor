import AppKit
import Foundation
import SwiftUI

struct SyntaxStyle {
    let font: NSFont
    let foregroundColor: NSColor
    let backgroundColor: NSColor?
}

final class MarkdownSyntaxHighlighter {
    private struct Rule {
        let pattern: String
        let options: NSRegularExpression.Options
        let apply: (NSMutableAttributedString, NSRange, SyntaxStyle) -> Void
    }

    func applyHighlighting(
        to storage: NSMutableAttributedString,
        in range: NSRange,
        baseStyle: SyntaxStyle,
        colors: EditorColorsNS
    ) {
        guard range.length > 0 else { return }

        storage.beginEditing()
        storage.addAttributes(
            [
                .font: baseStyle.font,
                .foregroundColor: baseStyle.foregroundColor,
            ],
            range: range
        )
        if let background = baseStyle.backgroundColor {
            storage.addAttribute(.backgroundColor, value: background, range: range)
        }

        applyRule(storage, range, pattern: "^#{1,6}\\s.+$", options: [.anchorsMatchLines], color: colors.heading, font: boldFont(from: baseStyle.font))
        applyRule(storage, range, pattern: "^\\s*[-*+]\\s+\\[[ xX]\\]\\s", options: [.anchorsMatchLines], color: colors.listMarker)
        applyRule(storage, range, pattern: "^\\s*[-*+]\\s+", options: [.anchorsMatchLines], color: colors.listMarker)
        applyRule(storage, range, pattern: "^\\s*\\d+\\.\\s+", options: [.anchorsMatchLines], color: colors.listMarker)
        applyRule(storage, range, pattern: "^>\\s?.+$", options: [.anchorsMatchLines], color: colors.blockquote, font: italicFont(from: baseStyle.font))
        applyRule(storage, range, pattern: "^-{3,}$|^\\*{3,}$", options: [.anchorsMatchLines], color: colors.horizontalRule)
        applyRule(storage, range, pattern: "`[^`]+`", options: [], color: colors.code, background: colors.codeBlockBackground)
        applyRule(storage, range, pattern: "^```.*$", options: [.anchorsMatchLines], color: colors.code, background: colors.codeBlockBackground)
        applyRule(storage, range, pattern: "\\*\\*[^*]+\\*\\*|__[^_]+__", options: [], color: colors.bold, font: boldFont(from: baseStyle.font))
        applyRule(storage, range, pattern: "(?<!\\*)\\*(?!\\*)[^*]+\\*(?!\\*)|(?<!_)_(?!_)[^_]+_(?!_)", options: [], color: colors.italic, font: italicFont(from: baseStyle.font))
        applyRule(storage, range, pattern: "!\\[[^\\]]*\\]\\([^\\)]*\\)", options: [], color: colors.link)
        applyRule(storage, range, pattern: "\\[[^\\]]+\\]\\([^\\)]+\\)", options: [], color: colors.link)
        applyRule(storage, range, pattern: "<https?://[^>]+>", options: [], color: colors.link)

        storage.endEditing()
    }

    private func applyRule(
        _ storage: NSMutableAttributedString,
        _ range: NSRange,
        pattern: String,
        options: NSRegularExpression.Options,
        color: NSColor,
        font: NSFont? = nil,
        background: NSColor? = nil
    ) {
        guard let regex = try? NSRegularExpression(pattern: pattern, options: options) else { return }
        let matches = regex.matches(in: storage.string, options: [], range: range)
        for match in matches {
            storage.addAttribute(.foregroundColor, value: color, range: match.range)
            if let font {
                storage.addAttribute(.font, value: font, range: match.range)
            }
            if let background {
                storage.addAttribute(.backgroundColor, value: background, range: match.range)
            }
        }
    }

    private func boldFont(from font: NSFont) -> NSFont {
        NSFontManager.shared.convert(font, toHaveTrait: .boldFontMask)
    }

    private func italicFont(from font: NSFont) -> NSFont {
        NSFontManager.shared.convert(font, toHaveTrait: .italicFontMask)
    }
}
