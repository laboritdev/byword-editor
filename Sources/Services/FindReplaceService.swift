import AppKit
import Foundation

public struct FindOptions: Equatable {
    var searchText: String = ""
    var replacementText: String = ""
    var caseSensitive: Bool = false
    var wholeWord: Bool = false
    var usesRegularExpression: Bool = false
}

public struct FindMatch: Equatable {
    public let range: NSRange
}

enum FindReplaceError: LocalizedError {
    case invalidPattern
    case noMatch

    var errorDescription: String? {
        switch self {
        case .invalidPattern:
            return "The search pattern is invalid."
        case .noMatch:
            return "No matches found."
        }
    }
}

public final class FindReplaceService {
    public init() {}

    public func findMatches(in text: String, options: FindOptions) throws -> [FindMatch] {
        guard !options.searchText.isEmpty else { return [] }

        let nsText = text as NSString
        let searchOptions = buildSearchOptions(options: options)
        let pattern = buildPattern(searchText: options.searchText, wholeWord: options.wholeWord, usesRegex: options.usesRegularExpression)

        if options.usesRegularExpression || options.wholeWord {
            let regexOptions: NSRegularExpression.Options = options.caseSensitive ? [] : .caseInsensitive
            guard let regex = try? NSRegularExpression(pattern: pattern, options: regexOptions) else {
                throw FindReplaceError.invalidPattern
            }
            let range = NSRange(location: 0, length: nsText.length)
            let results = regex.matches(in: text, options: [], range: range)
            return results.map { FindMatch(range: $0.range) }
        }

        var matches: [FindMatch] = []
        var searchRange = NSRange(location: 0, length: nsText.length)
        while searchRange.location < nsText.length {
            let found = nsText.range(of: options.searchText, options: searchOptions, range: searchRange)
            if found.location == NSNotFound { break }
            matches.append(FindMatch(range: found))
            searchRange.location = found.location + max(found.length, 1)
            searchRange.length = nsText.length - searchRange.location
        }
        return matches
    }

    public func findNext(in text: String, from location: Int, options: FindOptions) throws -> FindMatch? {
        let matches = try findMatches(in: text, options: options)
        guard !matches.isEmpty else { return nil }
        return matches.first { $0.range.location >= location } ?? matches.first
    }

    func findPrevious(in text: String, from location: Int, options: FindOptions) throws -> FindMatch? {
        let matches = try findMatches(in: text, options: options)
        guard !matches.isEmpty else { return nil }
        return matches.last { $0.range.location < location } ?? matches.last
    }

    func replace(in text: String, match: FindMatch, replacement: String) -> String {
        guard let range = Range(match.range, in: text) else { return text }
        return text.replacingCharacters(in: range, with: replacement)
    }

    public func replaceAll(in text: String, options: FindOptions) throws -> String {
        let matches = try findMatches(in: text, options: options).reversed()
        var result = text
        for match in matches {
            result = replace(in: result, match: match, replacement: options.replacementText)
        }
        return result
    }

    private func buildSearchOptions(options: FindOptions) -> NSString.CompareOptions {
        var searchOptions: NSString.CompareOptions = []
        if !options.caseSensitive {
            searchOptions.insert(.caseInsensitive)
        }
        return searchOptions
    }

    private func buildPattern(searchText: String, wholeWord: Bool, usesRegex: Bool) -> String {
        if usesRegex {
            return searchText
        }
        let escaped = NSRegularExpression.escapedPattern(for: searchText)
        if wholeWord {
            return "\\b\(escaped)\\b"
        }
        return escaped
    }
}
