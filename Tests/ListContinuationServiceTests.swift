import Testing
@testable import LabWordCore

@Suite("ListContinuationService")
struct ListContinuationServiceTests {
    @Test("continues bullet list on enter via block document")
    func bulletContinue() {
        var document = BlockDocument(markdown: "- Item")
        let cursor = document.handleEnter(at: document.markdown.utf16.count)
        #expect(document.markdown == "- Item\n- ")
        #expect(cursor == 9)
    }

    @Test("exits bullet list on empty item")
    func bulletExit() {
        var document = BlockDocument(markdown: "- Item\n- ")
        let cursor = document.handleEnter(at: document.markdown.utf16.count)
        #expect(document.markdown == "- Item\n")
        #expect(cursor == 7)
    }

    @Test("continues numbered list on enter")
    func numberedContinue() {
        var document = BlockDocument(markdown: "1. teste")
        let cursor = document.handleEnter(at: document.markdown.utf16.count)
        #expect(document.markdown == "1. teste\n2. ")
        #expect(cursor == 12)
    }

    @Test("exits numbered list on empty item")
    func numberedExit() {
        var document = BlockDocument(markdown: "1. teste\n2. ")
        let cursor = document.handleEnter(at: document.markdown.utf16.count)
        #expect(document.markdown == "1. teste\n")
        #expect(cursor == 9)
    }

    @Test("continues task list on enter")
    func taskContinue() {
        var document = BlockDocument(markdown: "- [ ] hyperion sso hml")
        let cursor = document.handleEnter(at: document.markdown.utf16.count)
        #expect(document.markdown == "- [ ] hyperion sso hml\n- [ ] ")
        #expect(cursor == 29)
    }

    @Test("exits task list on empty item")
    func taskExit() {
        var document = BlockDocument(markdown: "- [ ] hyperion\n- [ ] ")
        let cursor = document.handleEnter(at: document.markdown.utf16.count)
        #expect(document.markdown == "- [ ] hyperion\n")
        #expect(cursor == 15)
    }

    @Test("inserts blank line after plain paragraph")
    func plainParagraphEnter() {
        var document = BlockDocument(markdown: "plain paragraph")
        let cursor = document.handleEnter(at: document.markdown.utf16.count, in: document.markdown)
        #expect(cursor != nil)
        #expect(document.markdown == "plain paragraph\n")
    }
}
