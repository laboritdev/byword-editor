import AppKit
import Foundation
import SwiftUI

struct SyntaxStyle {
    let font: NSFont
    let foregroundColor: NSColor
    let backgroundColor: NSColor?
    let lineHeight: CGFloat
    let isDarkMode: Bool
}

final class MarkdownSyntaxHighlighter {
    private static let taskLinePattern = try! NSRegularExpression(
        pattern: #"^(\s*[-*+]\s+\[)([ xX])(\])(\s*)(.+)$"#,
        options: []
    )

    private static let headingPattern = try! NSRegularExpression(
        pattern: #"^(#{1,6})(\s+)(.+)$"#,
        options: [.anchorsMatchLines]
    )

    func applyHighlighting(
        to storage: NSMutableAttributedString,
        in range: NSRange,
        baseStyle: SyntaxStyle,
        colors: EditorColorsNS,
        mode: SyntaxHighlightMode
    ) {
        guard range.length > 0 else { return }

        let paragraphStyle = EditorTypography.paragraphStyle(
            lineHeight: baseStyle.lineHeight,
            font: baseStyle.font
        )

        storage.beginEditing()
        storage.addAttributes(
            [
                .font: baseStyle.font,
                .foregroundColor: baseStyle.foregroundColor.editorFixed,
                .paragraphStyle: paragraphStyle,
            ],
            range: range
        )
        if let background = baseStyle.backgroundColor {
            storage.addAttribute(.backgroundColor, value: background.editorFixed, range: range)
        }

        guard mode != .off else {
            storage.endEditing()
            return
        }

        applyTaskListHighlighting(
            to: storage,
            in: range,
            baseStyle: baseStyle,
            colors: colors,
            mode: mode
        )

        applyHeadingHighlighting(
            to: storage,
            in: range,
            baseStyle: baseStyle,
            colors: colors,
            mode: mode
        )

        applyListHighlighting(to: storage, in: range, colors: colors, baseStyle: baseStyle)
        applyRule(
            storage,
            range,
            pattern: "^>\\s?.+$",
            options: [.anchorsMatchLines],
            color: colors.blockquote,
            font: italicFont(from: baseStyle.font)
        )
        applyRule(storage, range, pattern: "^-{3,}$|^\\*{3,}$", options: [.anchorsMatchLines], color: colors.horizontalRule)

        if mode == .subtle {
            applyDelimitedPattern(
                storage, range,
                pattern: "(`)([^`]+)(`)",
                markerColor: colors.syntaxMarker,
                contentColor: colors.code,
                contentFont: monospacedFont(from: baseStyle.font, mode: mode)
            )
            applyDelimitedPattern(
                storage, range,
                pattern: "(\\*\\*)(.+?)(\\*\\*)|(__)(.+?)(__)",
                markerColor: colors.syntaxMarker,
                contentColor: colors.bold,
                contentFont: boldFont(from: baseStyle.font)
            )
            applyDelimitedPattern(
                storage, range,
                pattern: "(?<!\\*)(\\*)(?!\\*)(.+?)(?<!\\*)\\*(?!\\*)|(?<!_)(_)(?!_)(.+?)(?<!_)_(?!_)",
                markerColor: colors.syntaxMarker,
                contentColor: colors.italic,
                contentFont: italicFont(from: baseStyle.font)
            )
            applyLinkHighlighting(to: storage, in: range, colors: colors, underline: true)
        } else {
            applyRule(
                storage,
                range,
                pattern: "`[^`]+`",
                options: [],
                color: colors.code,
                font: monospacedFont(from: baseStyle.font, mode: mode),
                background: colors.codeBlockBackground
            )
            applyRule(
                storage,
                range,
                pattern: "\\*\\*[^*]+\\*\\*|__[^_]+__",
                options: [],
                color: colors.bold,
                font: boldFont(from: baseStyle.font)
            )
            applyRule(
                storage,
                range,
                pattern: "(?<!\\*)\\*(?!\\*)[^*]+\\*(?!\\*)|(?<!_)_(?!_)[^_]+_(?!_)",
                options: [],
                color: colors.italic,
                font: italicFont(from: baseStyle.font)
            )
            applyLinkHighlighting(to: storage, in: range, colors: colors, underline: false)
        }

        applyRule(
            storage,
            range,
            pattern: "^```.*$",
            options: [.anchorsMatchLines],
            color: colors.code,
            font: monospacedFont(from: baseStyle.font, mode: mode),
            background: colors.codeBlockBackground
        )

        storage.endEditing()
    }

    private func applyListHighlighting(
        to storage: NSMutableAttributedString,
        in range: NSRange,
        colors: EditorColorsNS,
        baseStyle: SyntaxStyle
    ) {
        let bulletPattern = try! NSRegularExpression(
            pattern: #"^(\s*[-*+]\s+)(.+)$"#,
            options: [.anchorsMatchLines]
        )
        let numberedPattern = try! NSRegularExpression(
            pattern: #"^(\s*\d+\.\s+)(.+)$"#,
            options: [.anchorsMatchLines]
        )

        for regex in [bulletPattern, numberedPattern] {
            let matches = regex.matches(in: storage.string, options: [], range: range)
            for match in matches {
                storage.addAttribute(.foregroundColor, value: colors.syntaxMarker.editorFixed, range: match.range(at: 1))
                storage.addAttribute(.foregroundColor, value: baseStyle.foregroundColor.editorFixed, range: match.range(at: 2))
                storage.addAttribute(.font, value: baseStyle.font, range: match.range(at: 2))
            }
        }
    }

    private func applyHeadingHighlighting(
        to storage: NSMutableAttributedString,
        in range: NSRange,
        baseStyle: SyntaxStyle,
        colors: EditorColorsNS,
        mode: SyntaxHighlightMode
    ) {
        let matches = Self.headingPattern.matches(in: storage.string, options: [], range: range)
        for match in matches {
            let hashRange = match.range(at: 1)
            let spaceRange = match.range(at: 2)
            let contentRange = match.range(at: 3)
            let level = (storage.string as NSString).substring(with: hashRange).count
            let headingFont = headingFont(for: baseStyle.font, level: level, mode: mode)
            let contentColor = mode == .subtle ? colors.heading : colors.heading

            storage.addAttribute(.foregroundColor, value: colors.syntaxMarker.editorFixed, range: hashRange)
            storage.addAttribute(.foregroundColor, value: colors.syntaxMarker.editorFixed, range: spaceRange)
            storage.addAttribute(.foregroundColor, value: contentColor.editorFixed, range: contentRange)
            storage.addAttribute(.font, value: headingFont, range: contentRange)

            if baseStyle.isDarkMode && mode == .subtle {
                storage.addAttribute(
                    .kern,
                    value: EditorTypography.headingKern(for: level),
                    range: contentRange
                )
            }
        }
    }

    private func applyLinkHighlighting(
        to storage: NSMutableAttributedString,
        in range: NSRange,
        colors: EditorColorsNS,
        underline: Bool
    ) {
        let patterns = [
            "\\[[^\\]]+\\]\\([^\\)]+\\)",
            "<https?://[^>]+>",
        ]
        for pattern in patterns {
            guard let regex = try? NSRegularExpression(pattern: pattern, options: []) else { continue }
            let matches = regex.matches(in: storage.string, options: [], range: range)
            for match in matches {
                storage.addAttribute(.foregroundColor, value: colors.link.editorFixed, range: match.range)
                if underline {
                    storage.addAttribute(
                        .underlineStyle,
                        value: NSUnderlineStyle.single.rawValue,
                        range: match.range
                    )
                    storage.addAttribute(
                        .underlineColor,
                        value: colors.link.withAlphaComponent(0.35).editorFixed,
                        range: match.range
                    )
                }
            }
        }
    }

    private func applyTaskListHighlighting(
        to storage: NSMutableAttributedString,
        in range: NSRange,
        baseStyle: SyntaxStyle,
        colors: EditorColorsNS,
        mode: SyntaxHighlightMode
    ) {
        let text = storage.string as NSString
        let matches = Self.taskLinePattern.matches(in: storage.string, options: [], range: range)
        for match in matches {
            let prefixRange = match.range(at: 1)
            let checkRange = match.range(at: 2)
            let suffixRange = match.range(at: 3)
            let spacerRange = match.range(at: 4)
            let contentRange = match.range(at: 5)
            let checkChar = text.substring(with: checkRange)
            let isChecked = checkChar == "x" || checkChar == "X"

            storage.addAttribute(.foregroundColor, value: colors.syntaxMarker.editorFixed, range: prefixRange)
            storage.addAttribute(.foregroundColor, value: colors.syntaxMarker.editorFixed, range: suffixRange)
            if spacerRange.length > 0 {
                storage.addAttribute(.foregroundColor, value: colors.syntaxMarker.editorFixed, range: spacerRange)
            }

            if isChecked {
                storage.addAttribute(.foregroundColor, value: colors.taskChecked.editorFixed, range: checkRange)
            } else {
                storage.addAttribute(.foregroundColor, value: colors.syntaxMarker.editorFixed, range: checkRange)
            }

            storage.addAttribute(.foregroundColor, value: baseStyle.foregroundColor.editorFixed, range: contentRange)
            storage.addAttribute(.font, value: baseStyle.font, range: contentRange)

            if isChecked && mode != .off {
                let mutedText = blend(baseStyle.foregroundColor, toward: colors.background, amount: 0.30)
                storage.addAttribute(.foregroundColor, value: mutedText.editorFixed, range: contentRange)
                storage.addAttribute(.strikethroughStyle, value: NSUnderlineStyle.single.rawValue, range: contentRange)
                storage.addAttribute(
                    .strikethroughColor,
                    value: mutedText.withAlphaComponent(0.6).editorFixed,
                    range: contentRange
                )
            }
        }
    }

    private func applyDelimitedPattern(
        _ storage: NSMutableAttributedString,
        _ range: NSRange,
        pattern: String,
        markerColor: NSColor,
        contentColor: NSColor,
        contentFont: NSFont
    ) {
        guard let regex = try? NSRegularExpression(pattern: pattern, options: []) else { return }
        let matches = regex.matches(in: storage.string, options: [], range: range)
        for match in matches {
            for group in 1..<match.numberOfRanges {
                let groupRange = match.range(at: group)
                guard groupRange.location != NSNotFound, groupRange.length > 0 else { continue }
                let snippet = (storage.string as NSString).substring(with: groupRange)
                if snippet == "**" || snippet == "__" || snippet == "*" || snippet == "_" || snippet == "`" {
                    storage.addAttribute(.foregroundColor, value: markerColor.editorFixed, range: groupRange)
                } else {
                    storage.addAttribute(.foregroundColor, value: contentColor.editorFixed, range: groupRange)
                    storage.addAttribute(.font, value: contentFont, range: groupRange)
                }
            }
        }
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
            storage.addAttribute(.foregroundColor, value: color.editorFixed, range: match.range)
            if let font {
                storage.addAttribute(.font, value: font, range: match.range)
            }
            if let background {
                storage.addAttribute(.backgroundColor, value: background.editorFixed, range: match.range)
            }
        }
    }

    private func headingFont(for font: NSFont, level: Int, mode: SyntaxHighlightMode) -> NSFont {
        let bold = boldFont(from: font)
        let sizeBoost: CGFloat = switch level {
        case 1: 6
        case 2: 4
        case 3: 2
        case 4: 1
        default: 0
        }
        let targetSize = font.pointSize + (mode == .subtle ? sizeBoost : sizeBoost + 1)
        return EditorFont.withCascade(NSFontManager.shared.convert(bold, toSize: targetSize))
    }

    private func monospacedFont(from font: NSFont, mode: SyntaxHighlightMode) -> NSFont {
        let size = mode == .subtle ? font.pointSize - 0.5 : font.pointSize
        let targetSize = max(11, size)
        if let menlo = NSFont(name: "Menlo", size: targetSize) {
            return EditorFont.withCascade(menlo)
        }
        return EditorFont.withCascade(
            NSFont.monospacedSystemFont(ofSize: targetSize, weight: .regular)
        )
    }

    private func boldFont(from font: NSFont) -> NSFont {
        EditorFont.withCascade(NSFontManager.shared.convert(font, toHaveTrait: .boldFontMask))
    }

    private func italicFont(from font: NSFont) -> NSFont {
        EditorFont.withCascade(NSFontManager.shared.convert(font, toHaveTrait: .italicFontMask))
    }

    private func blend(_ base: NSColor, toward other: NSColor, amount: CGFloat) -> NSColor {
        let left = base.editorFixed
        let right = other.editorFixed
        let ratio = min(max(amount, 0), 1)
        return EditorColorFactory.rgb(
            red: left.redComponent + (right.redComponent - left.redComponent) * ratio,
            green: left.greenComponent + (right.greenComponent - left.greenComponent) * ratio,
            blue: left.blueComponent + (right.blueComponent - left.blueComponent) * ratio,
            alpha: left.alphaComponent + (right.alphaComponent - left.alphaComponent) * ratio
        )
    }
}
