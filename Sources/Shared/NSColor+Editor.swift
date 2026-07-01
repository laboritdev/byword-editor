import AppKit

extension NSColor {
    var editorFixed: NSColor {
        usingColorSpace(.deviceRGB) ?? self
    }

    func isEditorEqual(to other: NSColor) -> Bool {
        let left = editorFixed
        let right = other.editorFixed
        return abs(left.redComponent - right.redComponent) < 0.001
            && abs(left.greenComponent - right.greenComponent) < 0.001
            && abs(left.blueComponent - right.blueComponent) < 0.001
            && abs(left.alphaComponent - right.alphaComponent) < 0.001
    }
}

enum EditorColorFactory {
    static func rgb(red: CGFloat, green: CGFloat, blue: CGFloat, alpha: CGFloat = 1) -> NSColor {
        NSColor(calibratedRed: red, green: green, blue: blue, alpha: alpha).editorFixed
    }
}
