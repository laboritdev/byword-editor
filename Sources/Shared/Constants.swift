import Foundation

public enum Constants {
    static let supportedExtensions: Set<String> = ["md", "markdown", "txt"]
    static let autoSaveDelay: TimeInterval = 1.0
    static let sessionFileName = "session.json"
    static let recoveryDirectoryName = "Recovery"
    static let recentFilesKey = "recentFiles"
    static let maxRecentFiles = 20
    static let wordsPerMinute = 200
    static let defaultFontSize: CGFloat = 16
    static let defaultLineHeight: CGFloat = 1.6
    static let defaultColumnWidth: CGFloat = 680
    static let defaultHorizontalMargin: CGFloat = 80
    static let appName = "BywordEditor"
}
