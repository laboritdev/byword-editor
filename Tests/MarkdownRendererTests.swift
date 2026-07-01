import Testing
@testable import BywordEditorCore

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
}
