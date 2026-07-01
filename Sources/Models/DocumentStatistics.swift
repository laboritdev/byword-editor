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
        "\(wordCount) words · \(characterCount) characters · \(lineCount) lines · ~\(readingMinutes) min read"
    }
}
