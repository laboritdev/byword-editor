import Foundation
import Testing
@testable import LabWordCore

@Suite("Document Snapshot Status")
struct DocumentSnapshotStatusTests {
    @Test("untitled document shows save hint")
    func untitledLocation() {
        let snapshot = DocumentSnapshot(content: "Hello", isDirty: true)
        #expect(snapshot.fileLocationLabel.contains("⌘S"))
        #expect(snapshot.saveStateLabel == "Unsaved")
        #expect(snapshot.workspaceLabel == nil)
    }

    @Test("saved file shows path and workspace")
    func savedLocation() {
        let url = URL(fileURLWithPath: "/Users/me/Documents/notes/test.md")
        let snapshot = DocumentSnapshot(fileURL: url, content: "Hello", isDirty: false)
        #expect(snapshot.fileLocationLabel.contains("test.md"))
        #expect(snapshot.workspaceLabel?.contains("Documents") == true)
        #expect(snapshot.saveStateLabel == "Saved")
    }
}
