import AppKit
import SwiftUI

@MainActor
final class EditorViewModel: ObservableObject, EditorTextViewDelegate {
    @Published private(set) var snapshot: DocumentSnapshot
    @Published var statistics: DocumentStatistics
    @Published var viewMode: ViewMode
    @Published var findOptions = FindOptions()
    @Published var isFindPanelVisible = false
    @Published var findStatusMessage: String?
    @Published var errorMessage: String?

    private let documentService: DocumentService
    private let autoSaveService: AutoSaveService
    private let recoveryService: RecoveryService
    private let findReplaceService: FindReplaceService
    private let recentFilesService: RecentFilesService

    init(
        snapshot: DocumentSnapshot,
        documentService: DocumentService,
        autoSaveService: AutoSaveService,
        recoveryService: RecoveryService,
        findReplaceService: FindReplaceService,
        recentFilesService: RecentFilesService = .shared
    ) {
        self.snapshot = snapshot
        self.documentService = documentService
        self.autoSaveService = autoSaveService
        self.recoveryService = recoveryService
        self.findReplaceService = findReplaceService
        self.recentFilesService = recentFilesService
        statistics = DocumentStatistics.compute(from: snapshot.content)
        viewMode = snapshot.viewMode
    }

    var content: String {
        get { snapshot.content }
        set { updateContent(newValue) }
    }

    var displayTitle: String {
        snapshot.displayTitle
    }

    func loadFromURL(_ url: URL) {
        do {
            let loaded = try documentService.load(from: url)
            snapshot.fileURL = url
            snapshot.content = loaded
            snapshot.isDirty = false
            snapshot.cursorLocation = 0
            snapshot.selectionLength = 0
            snapshot.scrollOffset = 0
            statistics = DocumentStatistics.compute(from: loaded)
            recentFilesService.addRecentFile(url)
            recoveryService.saveRecoverySnapshot(from: snapshot)
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func saveAs(to url: URL) {
        do {
            try documentService.save(content: snapshot.content, to: url)
            snapshot.fileURL = url
            snapshot.isDirty = false
            recentFilesService.addRecentFile(url)
            recoveryService.removeRecoverySnapshot(for: snapshot.id)
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func duplicate(to url: URL) {
        guard let source = snapshot.fileURL else { return }
        do {
            try documentService.duplicate(source: source, destination: url)
            snapshot.fileURL = url
            snapshot.isDirty = false
            recentFilesService.addRecentFile(url)
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func rename(to url: URL) {
        guard let source = snapshot.fileURL else { return }
        do {
            try documentService.move(from: source, to: url)
            snapshot.fileURL = url
            snapshot.isDirty = false
            recentFilesService.addRecentFile(url)
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func toggleViewMode() {
        viewMode = viewMode == .editor ? .preview : .editor
        snapshot.viewMode = viewMode
        scheduleAutoSave()
    }

    func setViewMode(_ mode: ViewMode) {
        viewMode = mode
        snapshot.viewMode = mode
        scheduleAutoSave()
    }

    func saveImmediately() async {
        await autoSaveService.saveImmediately(snapshot: snapshot)
        if snapshot.fileURL != nil {
            snapshot.isDirty = false
        }
    }

    func closeDocument() async {
        await saveImmediately()
        autoSaveService.cancelSave(for: snapshot.id)
        if snapshot.fileURL != nil {
            recoveryService.removeRecoverySnapshot(for: snapshot.id)
        }
    }

    func showFindPanel() {
        isFindPanelVisible = true
    }

    func hideFindPanel() {
        isFindPanelVisible = false
    }

    func findNext() {
        do {
            guard let match = try findReplaceService.findNext(
                in: snapshot.content,
                from: snapshot.cursorLocation,
                options: findOptions
            ) else {
                findStatusMessage = "No matches found."
                return
            }
            applyMatch(match)
            findStatusMessage = nil
        } catch {
            findStatusMessage = error.localizedDescription
        }
    }

    func findPrevious() {
        do {
            guard let match = try findReplaceService.findPrevious(
                in: snapshot.content,
                from: snapshot.cursorLocation,
                options: findOptions
            ) else {
                findStatusMessage = "No matches found."
                return
            }
            applyMatch(match)
            findStatusMessage = nil
        } catch {
            findStatusMessage = error.localizedDescription
        }
    }

    func replaceCurrentMatch() {
        do {
            guard let match = try findReplaceService.findNext(
                in: snapshot.content,
                from: snapshot.cursorLocation,
                options: findOptions
            ) else {
                findStatusMessage = "No matches found."
                return
            }
            let updated = findReplaceService.replace(
                in: snapshot.content,
                match: match,
                replacement: findOptions.replacementText
            )
            updateContent(updated)
            snapshot.cursorLocation = match.range.location + (findOptions.replacementText as NSString).length
            findStatusMessage = nil
        } catch {
            findStatusMessage = error.localizedDescription
        }
    }

    func replaceAllMatches() {
        do {
            let updated = try findReplaceService.replaceAll(in: snapshot.content, options: findOptions)
            updateContent(updated)
            findStatusMessage = "All matches replaced."
        } catch {
            findStatusMessage = error.localizedDescription
        }
    }

    // MARK: - EditorTextViewDelegate

    func editorTextDidChange(_ text: String) {
        updateContent(text)
    }

    func editorSelectionDidChange(location: Int, length: Int) {
        mutateSnapshot {
            $0.cursorLocation = location
            $0.selectionLength = length
        }
        scheduleAutoSave()
    }

    func editorScrollDidChange(offset: Double) {
        mutateSnapshot {
            $0.scrollOffset = offset
        }
        scheduleAutoSave()
    }

    private func mutateSnapshot(_ mutation: (inout DocumentSnapshot) -> Void) {
        mutation(&snapshot)
        objectWillChange.send()
    }

    private func updateContent(_ text: String) {
        mutateSnapshot {
            $0.content = text
            $0.isDirty = true
        }
        statistics = DocumentStatistics.compute(from: text)
        scheduleAutoSave()
    }

    private func scheduleAutoSave() {
        autoSaveService.scheduleSave(for: snapshot)
    }

    private func applyMatch(_ match: FindMatch) {
        mutateSnapshot {
            $0.cursorLocation = match.range.location
            $0.selectionLength = match.range.length
        }
    }
}
