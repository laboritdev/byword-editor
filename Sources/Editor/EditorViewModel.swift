import AppKit
import SwiftUI

@MainActor
final class EditorViewModel: ObservableObject, EditorTextViewDelegate {
    @Published private(set) var snapshot: DocumentSnapshot
    @Published var statistics: DocumentStatistics
    @Published var viewMode: ViewMode
    @Published var findOptions = FindOptions()
    @Published var activePanel: EditorPanel?
    @Published var findStatusMessage: String?
    @Published var errorMessage: String?
    @Published private(set) var saveFeedback: String?

    var isFindPanelVisible: Bool {
        activePanel == .find
    }

    private let documentService: DocumentService
    private let autoSaveService: AutoSaveService
    private let recoveryService: RecoveryService
    private let findReplaceService: FindReplaceService
    private let recentFilesService: RecentFilesService
    private var blockDocument: BlockDocument

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
        blockDocument = BlockDocument(markdown: snapshot.content)
        statistics = DocumentStatistics.compute(from: snapshot.content)
        viewMode = snapshot.viewMode
    }

    var content: String {
        get { blockDocument.markdown }
        set { updateContent(newValue) }
    }

    var displayTitle: String {
        snapshot.displayTitle
    }

    func loadFromURL(_ url: URL) {
        do {
            let loaded = try documentService.load(from: url)
            blockDocument = BlockDocument(markdown: loaded)
            mutateSnapshot {
                $0.fileURL = url
                $0.content = blockDocument.markdown
                $0.isDirty = false
                $0.cursorLocation = 0
                $0.selectionLength = 0
                $0.scrollOffset = 0
            }
            statistics = DocumentStatistics.compute(from: blockDocument.markdown)
            recentFilesService.addRecentFile(url)
            recoveryService.saveRecoverySnapshot(from: snapshot)
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func saveAs(to url: URL) {
        do {
            try documentService.save(content: snapshot.content, to: url)
            mutateSnapshot {
                $0.fileURL = url
                $0.isDirty = false
            }
            recentFilesService.addRecentFile(url)
            recoveryService.removeRecoverySnapshot(for: snapshot.id)
            showSaveFeedback("Saved to \(url.lastPathComponent)")
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func duplicate(to url: URL) {
        guard let source = snapshot.fileURL else { return }
        do {
            try documentService.duplicate(source: source, destination: url)
            mutateSnapshot {
                $0.fileURL = url
                $0.isDirty = false
            }
            recentFilesService.addRecentFile(url)
            showSaveFeedback("Saved to \(url.lastPathComponent)")
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func rename(to url: URL) {
        guard let source = snapshot.fileURL else { return }
        do {
            try documentService.move(from: source, to: url)
            mutateSnapshot {
                $0.fileURL = url
                $0.isDirty = false
            }
            recentFilesService.addRecentFile(url)
            showSaveFeedback("Renamed to \(url.lastPathComponent)")
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func toggleViewMode() {
        viewMode = viewMode == .editor ? .preview : .editor
        mutateSnapshot { $0.viewMode = viewMode }
        scheduleAutoSave()
    }

    func setViewMode(_ mode: ViewMode) {
        viewMode = mode
        mutateSnapshot { $0.viewMode = mode }
        scheduleAutoSave()
    }

    func saveImmediately() async {
        guard snapshot.fileURL != nil else { return }
        await autoSaveService.saveImmediately(snapshot: snapshot)
        mutateSnapshot { $0.isDirty = false }
        showSaveFeedback("Saved")
    }

    var needsSavePanel: Bool {
        snapshot.fileURL == nil
    }

    func closeDocument() async {
        await saveImmediately()
        autoSaveService.cancelSave(for: snapshot.id)
        if snapshot.fileURL != nil {
            recoveryService.removeRecoverySnapshot(for: snapshot.id)
        }
    }

    func showPanel(_ panel: EditorPanel) {
        activePanel = panel
    }

    func dismissPanel() {
        activePanel = nil
    }

    func showFindPanel() {
        showPanel(.find)
    }

    func hideFindPanel() {
        if activePanel == .find {
            dismissPanel()
        }
    }

    func insertTaskListItem(checked: Bool = false) {
        guard let cursor = blockDocument.insertTaskItem(at: snapshot.cursorLocation, checked: checked) else {
            return
        }
        commitBlockDocument(cursor: cursor)
    }

    func toggleTaskCheckbox(at location: Int) -> TaskListEditResult? {
        guard let cursor = blockDocument.toggleTaskCheckbox(at: location) else {
            return nil
        }
        commitBlockDocument(cursor: cursor)
        return TaskListEditResult(text: blockDocument.markdown, cursorLocation: cursor)
    }

    func handleListContinuation(at location: Int, text: String) -> TaskListEditResult? {
        guard let cursor = blockDocument.handleEnter(at: location, in: text) else {
            return nil
        }
        commitBlockDocument(cursor: cursor)
        return TaskListEditResult(text: blockDocument.markdown, cursorLocation: cursor)
    }

    private func commitBlockDocument(cursor: Int) {
        mutateSnapshot {
            $0.content = blockDocument.markdown
            $0.cursorLocation = cursor
            $0.selectionLength = 0
            $0.isDirty = true
        }
        statistics = DocumentStatistics.compute(from: blockDocument.markdown)
        scheduleAutoSave()
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
            mutateSnapshot {
                $0.cursorLocation = match.range.location + (findOptions.replacementText as NSString).length
            }
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
        let previousCursor = snapshot.cursorLocation
        blockDocument.applyEditedMarkdown(text)
        let markdown = blockDocument.markdown
        let cursor = markdown == text
            ? previousCursor
            : DocumentStructureService.mapCursor(from: text, to: markdown, cursor: previousCursor)

        mutateSnapshot {
            $0.content = markdown
            $0.cursorLocation = cursor
            $0.isDirty = true
        }
        statistics = DocumentStatistics.compute(from: markdown)
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

    private func showSaveFeedback(_ message: String) {
        saveFeedback = message
        Task { @MainActor in
            try? await Task.sleep(for: .seconds(2.5))
            if saveFeedback == message {
                saveFeedback = nil
            }
        }
    }
}
