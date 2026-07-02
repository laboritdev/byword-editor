import Testing
@testable import LabWordCore

@Suite("MarkdownRenderer")
struct MarkdownRendererTests {
    private let renderer = MarkdownRenderer()

    @Test("renders headings")
    func heading() {
        let html = renderer.renderHTML(from: "# Title")
        #expect(html.contains("<h1>Title</h1>"))
    }

    @Test("renders bold text")
    func bold() {
        let html = renderer.renderHTML(from: "**bold**")
        #expect(html.contains("<strong>bold</strong>"))
    }

    @Test("renders task list checkboxes in preview")
    func taskList() {
        let html = renderer.renderHTML(from: "- [ ] Todo\n- [x] Done")
        #expect(html.contains("class=\"task-list\""))
        #expect(html.contains("type=\"checkbox\""))
        #expect(html.contains("Todo"))
        #expect(html.contains("checked"))
    }
}
