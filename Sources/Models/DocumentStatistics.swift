import Foundation

public enum ViewMode: String, Codable {
    case editor
    case preview
}

public struct DocumentStatistics: Equatable {
    let wordCount: Int
    let characterCount: Int
    let lineCount: Int
    let readingMinutes: Int

    public static func compute(from text: String) -> DocumentStatistics {
        DocumentStatistics(
            wordCount: text.wordCount,
            characterCount: text.count,
            lineCount: text.lineCount,
            readingMinutes: text.estimatedReadingMinutes
        )
    }

    var statusText: String {
        let wordLabel = wordCount == 1 ? "word" : "words"
        let charLabel = characterCount == 1 ? "character" : "characters"
        return "Markdown · \(wordCount) \(wordLabel) · \(characterCount) \(charLabel)"
    }
}
