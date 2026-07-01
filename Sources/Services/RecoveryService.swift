import Foundation
import os

final class RecoveryService {
    private let logger = Logger(subsystem: Constants.appName, category: "RecoveryService")
    private let fileManager = FileManager.default

    private var recoveryDirectory: URL {
        let appSupport = fileManager.urls(for: .applicationSupportDirectory, in: .userDomainMask).first
            ?? fileManager.temporaryDirectory
        let directory = appSupport
            .appendingPathComponent(Constants.appName, isDirectory: true)
            .appendingPathComponent(Constants.recoveryDirectoryName, isDirectory: true)
        try? fileManager.createDirectory(at: directory, withIntermediateDirectories: true)
        return directory
    }

    func saveRecoverySnapshot(from snapshot: DocumentSnapshot) {
        let recovery = RecoverySnapshot(
            recoveryID: snapshot.id,
            fileURL: snapshot.fileURL,
            content: snapshot.content,
            cursorLocation: snapshot.cursorLocation,
            selectionLength: snapshot.selectionLength,
            scrollOffset: snapshot.scrollOffset,
            viewMode: snapshot.viewMode,
            savedAt: .now
        )
        let fileURL = recoveryDirectory.appendingPathComponent("\(snapshot.id.uuidString).json")
        do {
            let data = try JSONEncoder().encode(recovery)
            try data.write(to: fileURL, options: .atomic)
        } catch {
            logger.error("Recovery save failed: \(error.localizedDescription)")
        }
    }

    func loadRecoverySnapshot(for recoveryID: UUID) -> RecoverySnapshot? {
        let fileURL = recoveryDirectory.appendingPathComponent("\(recoveryID.uuidString).json")
        guard let data = try? Data(contentsOf: fileURL) else { return nil }
        return try? JSONDecoder().decode(RecoverySnapshot.self, from: data)
    }

    func removeRecoverySnapshot(for recoveryID: UUID) {
        let fileURL = recoveryDirectory.appendingPathComponent("\(recoveryID.uuidString).json")
        try? fileManager.removeItem(at: fileURL)
    }

    func allRecoverySnapshots() -> [RecoverySnapshot] {
        guard let files = try? fileManager.contentsOfDirectory(
            at: recoveryDirectory,
            includingPropertiesForKeys: nil
        ) else {
            return []
        }
        return files.compactMap { url -> RecoverySnapshot? in
            guard url.pathExtension == "json",
                  let data = try? Data(contentsOf: url) else { return nil }
            return try? JSONDecoder().decode(RecoverySnapshot.self, from: data)
        }
    }
}
