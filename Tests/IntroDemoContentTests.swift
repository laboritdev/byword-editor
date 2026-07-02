import Testing
@testable import LabWordCore

@Suite("IntroDemoContent")
struct IntroDemoContentTests {
    @Test("demo content is non-empty and includes markdown samples")
    func contentIsNonEmpty() {
        let content = IntroDemoContent.content
        #expect(!content.isEmpty)
        #expect(content.contains("# "))
        #expect(content.contains("**"))
        #expect(content.contains("- [ ]"))
        #expect(content.contains("- [x]"))
        #expect(content.contains("> "))
    }

    @Test("initial content respects showIntroDemo preference")
    func initialContentRespectsPreference() {
        let withDemo = IntroDemoContent.initialContent(showIntroDemo: true)
        let withoutDemo = IntroDemoContent.initialContent(showIntroDemo: false)

        #expect(withDemo == IntroDemoContent.content)
        #expect(withoutDemo.isEmpty)
    }
}
