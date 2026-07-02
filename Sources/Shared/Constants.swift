import Foundation

public enum Constants {
    static let supportedExtensions: Set<String> = ["md", "markdown", "txt"]
    static let autoSaveDelay: TimeInterval = 1.0
    static let sessionFileName = "session.json"
    static let recoveryDirectoryName = "Recovery"
    static let recentFilesKey = "recentFiles"
    static let maxRecentFiles = 20
    static let wordsPerMinute = 200
    static let defaultFontSize: CGFloat = 19
    static let minimumFontSize: CGFloat = 12
    static let maximumFontSize: CGFloat = 28
    static let fontSizeStep: CGFloat = 1
    static let defaultLineHeight: CGFloat = 1.55
    static let defaultColumnWidth: CGFloat = 580
    static let defaultHorizontalMargin: CGFloat = 72
    static let appName = "LabWord"
    static let appBundleName = "LabWord"
    static let documentWindowSceneID = "document"
}
