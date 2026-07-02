import Foundation
import Testing
@testable import LabWordCore

@Suite("Document Title")
struct DocumentTitleTests {
    @Test("first markdown heading extracts title text")
    func firstHeading() {
        let content = "# My Document\n\nBody text."
        #expect(content.firstMarkdownHeading == "My Document")
    }

    @Test("display title uses heading when file is untitled")
    func untitledUsesHeading() {
        let snapshot = DocumentSnapshot(content: "# Notes\n\nHello")
        #expect(snapshot.displayTitle == "Notes")
    }

    @Test("display title prefers filename when saved")
    func savedUsesFilename() {
        let url = URL(fileURLWithPath: "/tmp/report.md")
        let snapshot = DocumentSnapshot(fileURL: url, content: "# Other Name")
        #expect(snapshot.displayTitle == "report")
    }
}
