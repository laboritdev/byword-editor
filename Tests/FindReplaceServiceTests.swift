import Testing
@testable import BywordEditorCore

@Suite("FindReplaceService")
struct FindReplaceServiceTests {
    private let service = FindReplaceService()

    @Test("finds all case-insensitive matches")
    func findAll() throws {
        let options = FindOptions(searchText: "hello", caseSensitive: false)
        let matches = try service.findMatches(in: "Hello hello HELLO", options: options)
        #expect(matches.count == 3)
    }

    @Test("replaces all matches")
    func replaceAll() throws {
        let options = FindOptions(searchText: "cat", replacementText: "dog")
        let result = try service.replaceAll(in: "cat and cat", options: options)
        #expect(result == "dog and dog")
    }

    @Test("finds next from cursor location")
    func findNext() throws {
        let options = FindOptions(searchText: "a")
        let match = try service.findNext(in: "aba", from: 1, options: options)
        #expect(match?.range.location == 2)
    }
}
