import Testing
@testable import LabWordCore

@Suite("EditorCursorPosition")
struct EditorCursorPositionTests {
    @Test("reports line and column for cursor location")
    func lineAndColumn() {
        let text = "hello\nworld"
        let position = EditorCursorPosition.from(text: text, location: 6, selectionLength: 0)
        #expect(position.line == 2)
        #expect(position.column == 1)
        #expect(position.statusLabel == "Ln 2, Col 1")
    }

    @Test("includes selection length in status label")
    func selectionLabel() {
        let text = "hello\nworld"
        let position = EditorCursorPosition.from(text: text, location: 0, selectionLength: 5)
        #expect(position.statusLabel == "Ln 1, Col 1 · 5 selected")
    }

    @Test("places cursor on new line after trailing newline")
    func trailingNewline() {
        let text = "hello\n"
        let position = EditorCursorPosition.from(text: text, location: text.utf16.count, selectionLength: 0)
        #expect(position.line == 2)
        #expect(position.column == 1)
    }

    @Test("defaults to first line in empty document")
    func emptyDocument() {
        let position = EditorCursorPosition.from(text: "", location: 0, selectionLength: 0)
        #expect(position.statusLabel == "Ln 1, Col 1")
    }
}
