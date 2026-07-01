import Foundation
import os

public final class SessionService {
    public init() {}
    private let logger = Logger(subsystem: Constants.appName, category: "SessionService")
    private let fileManager = FileManager.default

    private var sessionFileURL: URL {
        let appSupport = fileManager.urls(for: .applicationSupportDirectory, in: .userDomainMask).first
            ?? fileManager.temporaryDirectory
        let directory = appSupport.appendingPathComponent(Constants.appName, isDirectory: true)
        try? fileManager.createDirectory(at: directory, withIntermediateDirectories: true)
        return directory.appendingPathComponent(Constants.sessionFileName)
    }

    public func saveSession(documents: [DocumentSnapshot]) {
        let states = documents.map { snapshot in
            SessionDocumentState(
                fileURL: snapshot.fileURL,
                recoveryID: snapshot.id,
                cursorLocation: snapshot.cursorLocation,
                selectionLength: snapshot.selectionLength,
                scrollOffset: snapshot.scrollOffset,
                viewMode: snapshot.viewMode
            )
        }
        let session = SessionState(documents: states, savedAt: .now)
        do {
            let data = try JSONEncoder().encode(session)
            try data.write(to: sessionFileURL, options: .atomic)
        } catch {
            logger.error("Session save failed: \(error.localizedDescription)")
        }
    }

    public func loadSession() -> SessionState? {
        guard let data = try? Data(contentsOf: sessionFileURL) else { return nil }
        return try? JSONDecoder().decode(SessionState.self, from: data)
    }

    func clearSession() {
        try? fileManager.removeItem(at: sessionFileURL)
    }
}
