import Testing
@testable import LabWordCore

@Suite("Application Shell")
struct AppShellTests {
    @Test("supported file extensions include markdown")
    func supportedExtensions() {
        #expect(Constants.supportedExtensions.contains("md"))
        #expect(Constants.supportedExtensions.contains("markdown"))
        #expect(Constants.supportedExtensions.contains("txt"))
    }
}
