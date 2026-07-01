import AppKit
import Foundation

@MainActor
final class RecentFilesService {
    static let shared = RecentFilesService()

    private let storageKey = Constants.recentFilesKey
    private let maxCount = Constants.maxRecentFiles

    private init() {}

    var recentFiles: [URL] {
        guard let paths = UserDefaults.standard.stringArray(forKey: storageKey) else {
            return []
        }
        return paths.compactMap { path in
            let url = URL(fileURLWithPath: path)
            return FileManager.default.fileExists(atPath: url.path) ? url : nil
        }
    }

    func addRecentFile(_ url: URL) {
        var files = recentFiles.filter { $0 != url }
        files.insert(url, at: 0)
        if files.count > maxCount {
            files = Array(files.prefix(maxCount))
        }
        UserDefaults.standard.set(files.map(\.path), forKey: storageKey)
        NSDocumentController.shared.noteNewRecentDocumentURL(url)
    }

    func clearRecentFiles() {
        UserDefaults.standard.removeObject(forKey: storageKey)
    }
}
