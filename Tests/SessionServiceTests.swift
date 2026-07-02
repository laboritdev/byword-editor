import Foundation
import Testing
@testable import LabWordCore

@Suite("SessionService")
struct SessionServiceTests {
    @Test("persists and restores session state")
    func saveAndLoad() {
        let service = SessionService()
        let snapshot = DocumentSnapshot(
            fileURL: URL(fileURLWithPath: "/tmp/test.md"),
            content: "session content"
        )
        service.saveSession(documents: [snapshot])
        let loaded = service.loadSession()
        #expect(loaded?.documents.count == 1)
        #expect(loaded?.documents.first?.fileURL == snapshot.fileURL)
    }
}
