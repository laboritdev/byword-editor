import Foundation
import Testing
@testable import LabWordCore

@Suite("BlockDocument")
struct BlockDocumentTests {
    @Test("stores numbered list as a single block with indexed items")
    func numberedBlock() {
        var document = BlockDocument(markdown: "1. one\n2. two\n3. three")
        #expect(document.blocks.count == 1)
        guard case .list(let group) = document.blocks[0] else {
            Issue.record("Expected list block")
            return
        }
        #expect(group.kind == .numbered)
        #expect(group.items.count == 3)
    }

    @Test("renumbers items when middle item is removed from block")
    func renumberOnDelete() {
        var document = BlockDocument(markdown: "1. one\n2. two\n3. three")
        document.applyEditedMarkdown("1. one\n3. three")
        #expect(document.markdown == "1. one\n2. three")
    }

    @Test("inserts task item as a new block item")
    func insertTaskBlock() {
        var document = BlockDocument(markdown: "- [ ] first")
        let cursor = document.handleEnter(at: document.markdown.utf16.count)
        #expect(document.markdown == "- [ ] first\n- [ ] ")
        #expect(cursor != nil)
        guard case .list(let group) = document.blocks[0] else {
            Issue.record("Expected list block")
            return
        }
        #expect(group.items.count == 2)
    }

    @Test("does not split task marker when enter is inside prefix")
    func enterInsidePrefix() {
        var document = BlockDocument(markdown: "- [ ] something to do")
        let cursor = document.handleEnter(at: 2)
        #expect(document.markdown == "- [ ] something to do\n- [ ] ")
        #expect(document.markdown.contains("[ ] [") == false)
        #expect(cursor == document.markdown.utf16.count)
    }

    @Test("exiting empty task item then enter on blank does not recreate task")
    func exitThenBlankEnter() {
        var document = BlockDocument(
            markdown: "- [ ] something to do\n- [x] something done\n- [ ] "
        )
        let source = "- [ ] something to do\n- [x] something done\n- [ ] "
        let exitCursor = document.handleEnter(at: source.utf16.count, in: source)
        #expect(exitCursor != nil)
        #expect(document.markdown == "- [ ] something to do\n- [x] something done\n")
        #expect(document.blocks.count == 2)

        let afterExit = document.markdown
        let nsAfterExit = afterExit as NSString
        let blankLineCursor = nsAfterExit.length

        let secondEnter = document.handleEnter(at: blankLineCursor, in: afterExit)
        #expect(secondEnter != nil)
        #expect(document.markdown == "- [ ] something to do\n- [x] something done\n\n")
        guard case .list(let group) = document.blocks[0] else {
            Issue.record("Expected list block")
            return
        }
        #expect(group.items.count == 2)
    }

    @Test("newline at end of list maps to blank line not last task")
    func trailingNewlineLineIndex() {
        let text = "- [ ] something to do\n- [x] something done\n"
        let nsText = text as NSString
        let lineIndex = DocumentComponentParser.lineIndex(at: nsText.length - 1, in: text)
        #expect(lineIndex == 2)
    }

    @Test("exit empty task places cursor on blank line after list")
    func exitCursorOnBlankLine() {
        var document = BlockDocument(
            markdown: "- [ ] something to do\n- [x] something done\n- [ ] "
        )
        let source = "- [ ] something to do\n- [x] something done\n- [ ] "
        let cursor = document.handleEnter(at: source.utf16.count, in: source)
        #expect(cursor != nil)

        let markdown = document.markdown
        let doneLine = "- [x] something done"
        let doneEnd = (markdown as NSString).range(of: doneLine).location + doneLine.utf16.count

        #expect(cursor == markdown.utf16.count)
        #expect(cursor != doneEnd)
        #expect(BlockCursorMap.lineIndex(at: cursor!, in: markdown) == 2)
    }
}
