import Testing
@testable import LabWordCore

@Suite("DocumentStatistics")
struct DocumentStatisticsTests {
    @Test("computes word and line counts")
    func compute() {
        let stats = DocumentStatistics.compute(from: "one two\nthree")
        #expect(stats.wordCount == 3)
        #expect(stats.lineCount == 2)
        #expect(stats.characterCount == 13)
    }
}
