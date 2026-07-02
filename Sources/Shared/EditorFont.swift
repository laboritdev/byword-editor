import AppKit

enum EditorFont {
    static func withCascade(_ font: NSFont) -> NSFont {
        let fallbackFamilies = [
            "Helvetica Neue",
            "Arial Unicode MS",
            "Arial",
            ".AppleSystemUIFont",
        ]
        let cascade = fallbackFamilies.map {
            NSFontDescriptor(fontAttributes: [.family: $0])
        }
        let descriptor = font.fontDescriptor.addingAttributes([
            .cascadeList: cascade,
        ])
        return NSFont(descriptor: descriptor, size: font.pointSize) ?? font
    }
}
