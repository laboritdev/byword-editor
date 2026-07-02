import AppKit

enum EditorTypography {
    static let verticalTextInset: CGFloat = 72

    static func paragraphStyle(lineHeight: CGFloat, font: NSFont) -> NSParagraphStyle {
        let style = NSMutableParagraphStyle()
        style.lineHeightMultiple = lineHeight
        style.lineSpacing = max(0, (lineHeight - 1.0) * font.pointSize * 0.35)
        style.paragraphSpacing = font.pointSize * 0.28
        style.paragraphSpacingBefore = font.pointSize * 0.08
        style.lineBreakMode = .byWordWrapping
        return style
    }

    static func baseAttributes(
        font: NSFont,
        textColor: NSColor,
        lineHeight: CGFloat
    ) -> [NSAttributedString.Key: Any] {
        [
            .font: font,
            .foregroundColor: textColor.editorFixed,
            .paragraphStyle: paragraphStyle(lineHeight: lineHeight, font: font),
        ]
    }

    static func centeredHorizontalMargin(
        containerWidth: CGFloat,
        columnWidth: CGFloat,
        minimumMargin: CGFloat
    ) -> CGFloat {
        max(minimumMargin, (containerWidth - columnWidth) / 2)
    }

    static func headingKern(for level: Int) -> CGFloat {
        switch level {
        case 1: 0.6
        case 2: 0.45
        case 3: 0.3
        default: 0.15
        }
    }
}
