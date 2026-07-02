import AppKit
import Foundation

extension URL {
    var isSupportedTextFile: Bool {
        Constants.supportedExtensions.contains(pathExtension.lowercased())
    }

    var displayName: String {
        deletingPathExtension().lastPathComponent
    }

    var abbreviatedPath: String {
        abbreviate(path(percentEncoded: false))
    }

    var abbreviatedDirectory: String {
        abbreviate(deletingLastPathComponent().path(percentEncoded: false))
    }

    private func abbreviate(_ path: String) -> String {
        let home = FileManager.default.homeDirectoryForCurrentUser.path
        if path.hasPrefix(home) {
            return "~" + path.dropFirst(home.count)
        }
        return path
    }
}

extension String {
    var wordCount: Int {
        components(separatedBy: .whitespacesAndNewlines).filter { !$0.isEmpty }.count
    }

    var lineCount: Int {
        guard !isEmpty else { return 1 }
        return components(separatedBy: .newlines).count
    }

    var estimatedReadingMinutes: Int {
        max(1, Int(ceil(Double(wordCount) / Double(Constants.wordsPerMinute))))
    }

    var firstMarkdownHeading: String? {
        for line in components(separatedBy: .newlines) {
            let trimmed = line.trimmingCharacters(in: .whitespaces)
            guard trimmed.hasPrefix("#") else { continue }
            var level = 0
            for character in trimmed where character == "#" {
                level += 1
            }
            guard level >= 1, level <= 6 else { continue }
            let titleStart = trimmed.index(trimmed.startIndex, offsetBy: level)
            let title = trimmed[titleStart...]
                .trimmingCharacters(in: .whitespaces)
            guard !title.isEmpty else { continue }
            return String(title)
        }
        return nil
    }
}

extension Notification.Name {
    static let preferencesDidChange = Notification.Name("preferencesDidChange")
    static let focusModeDidChange = Notification.Name("focusModeDidChange")
    static let viewModeDidChange = Notification.Name("viewModeDidChange")
}
