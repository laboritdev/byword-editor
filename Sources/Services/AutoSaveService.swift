import Foundation
import os

@MainActor
final class AutoSaveService {
    private let documentService: DocumentService
    private let recoveryService: RecoveryService
    private var pendingTasks: [UUID: Task<Void, Never>] = [:]
    private let logger = Logger(subsystem: Constants.appName, category: "AutoSaveService")

    init(documentService: DocumentService, recoveryService: RecoveryService) {
        self.documentService = documentService
        self.recoveryService = recoveryService
    }

    func scheduleSave(for snapshot: DocumentSnapshot) {
        pendingTasks[snapshot.id]?.cancel()
        let snapshotCopy = snapshot
        pendingTasks[snapshot.id] = Task { [weak self] in
            try? await Task.sleep(for: .seconds(Constants.autoSaveDelay))
            guard !Task.isCancelled else { return }
            await self?.performSave(snapshot: snapshotCopy)
        }
    }

    func saveImmediately(snapshot: DocumentSnapshot) async {
        pendingTasks[snapshot.id]?.cancel()
        pendingTasks[snapshot.id] = nil
        await performSave(snapshot: snapshot)
    }

    func cancelSave(for documentID: UUID) {
        pendingTasks[documentID]?.cancel()
        pendingTasks[documentID] = nil
    }

    private func performSave(snapshot: DocumentSnapshot) async {
        recoveryService.saveRecoverySnapshot(from: snapshot)
        guard let fileURL = snapshot.fileURL else { return }
        let content = snapshot.content
        do {
            try documentService.save(content: content, to: fileURL)
            logger.debug("Saved \(fileURL.path, privacy: .public)")
        } catch {
            logger.error("Auto-save failed: \(error.localizedDescription)")
        }
    }
}
