import Foundation

struct EditorCursorPosition: Equatable {
    let line: Int
    let column: Int
    let selectionLength: Int

    var statusLabel: String {
        if selectionLength > 0 {
            return "Ln \(line), Col \(column) · \(selectionLength) selected"
        }
        return "Ln \(line), Col \(column)"
    }

    static func from(text: String, location: Int, selectionLength: Int) -> EditorCursorPosition {
        let nsText = text as NSString
        let safeLocation = min(max(0, location), nsText.length)
        let safeSelection = max(0, selectionLength)

        guard nsText.length > 0 else {
            return EditorCursorPosition(line: 1, column: 1, selectionLength: safeSelection)
        }

        let probeLocation = safeLocation == nsText.length ? max(0, nsText.length - 1) : safeLocation
        let lineRange = nsText.lineRange(for: NSRange(location: probeLocation, length: 0))

        var line = 1
        var scan = 0
        while scan < lineRange.location {
            let range = nsText.lineRange(for: NSRange(location: scan, length: 0))
            line += 1
            scan = range.location + range.length
        }

        if safeLocation == nsText.length, text.hasSuffix("\n"), safeLocation > lineRange.location {
            return EditorCursorPosition(line: line + 1, column: 1, selectionLength: safeSelection)
        }

        let column = safeLocation - lineRange.location + 1
        return EditorCursorPosition(
            line: max(1, line),
            column: max(1, column),
            selectionLength: safeSelection
        )
    }
}
