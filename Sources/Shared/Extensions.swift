import AppKit
import Foundation

extension URL {
    var isSupportedTextFile: Bool {
        Constants.supportedExtensions.contains(pathExtension.lowercased())
    }

    var displayName: String {
        deletingPathExtension().lastPathComponent
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
}

extension Notification.Name {
    static let preferencesDidChange = Notification.Name("preferencesDidChange")
    static let focusModeDidChange = Notification.Name("focusModeDidChange")
    static let viewModeDidChange = Notification.Name("viewModeDidChange")
}
