import Foundation
import Testing
@testable import LabWordCore

@Suite("DocumentService")
struct DocumentServiceTests {
    private let service = DocumentService()
    private let tempDirectory: URL

    init() {
        tempDirectory = FileManager.default.temporaryDirectory
            .appendingPathComponent(UUID().uuidString, isDirectory: true)
        try? FileManager.default.createDirectory(at: tempDirectory, withIntermediateDirectories: true)
    }

    @Test("loads and saves markdown files")
    func saveAndLoad() throws {
        let fileURL = tempDirectory.appendingPathComponent("note.md")
        let content = "# Hello\n\nWorld"
        try service.save(content: content, to: fileURL)
        let loaded = try service.load(from: fileURL)
        #expect(loaded == content)
    }

    @Test("rejects unsupported extensions")
    func unsupportedExtension() throws {
        let fileURL = tempDirectory.appendingPathComponent("note.doc")
        do {
            _ = try service.load(from: fileURL)
            Issue.record("Expected unsupported file type error")
        } catch let error as DocumentError {
            #expect(error == .unsupportedFileType)
        }
    }

    @Test("duplicates files")
    func duplicate() throws {
        let source = tempDirectory.appendingPathComponent("source.md")
        let destination = tempDirectory.appendingPathComponent("copy.md")
        try service.save(content: "duplicate me", to: source)
        try service.duplicate(source: source, destination: destination)
        let loaded = try service.load(from: destination)
        #expect(loaded == "duplicate me")
    }
}
