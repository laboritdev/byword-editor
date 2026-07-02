import AppKit
import SwiftUI

@MainActor
final class EditorViewModel: ObservableObject, EditorTextViewDelegate {
    @Published private(set) var snapshot: DocumentSnapshot
    @Published private(set) var editorText: String
    @Published private(set) var editorRevision: Int = 0
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
        editorText = snapshot.content
        statistics = DocumentStatistics.compute(from: snapshot.content)
        viewMode = snapshot.viewMode
    }

    var content: String {
        get { editorText }
        set {
            updateContent(
                newValue,
                cursorLocation: snapshot.cursorLocation,
                selectionLength: snapshot.selectionLength
            )
        }
    }

    func ensureIntroDemoIfNeeded() {
        guard snapshot.fileURL == nil else { return }
        guard editorText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
        guard PreferencesStore.shared.preferences.showIntroDemo else { return }
        applyLoadedContent(IntroDemoContent.content, fileURL: nil, isDirty: false)
    }

    var displayTitle: String {
        snapshot.displayTitle
    }

    func loadFromURL(_ url: URL) {
        do {
            let loaded = try documentService.load(from: url)
            applyLoadedContent(loaded, fileURL: url, isDirty: false)
            recentFilesService.addRecentFile(url)
            recoveryService.saveRecoverySnapshot(from: snapshot)
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func reloadFromURLIfNeeded() {
        guard let url = snapshot.fileURL else { return }
        guard snapshot.content.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
        loadFromURL(url)
    }

    private func applyLoadedContent(_ loaded: String, fileURL: URL?, isDirty: Bool) {
        blockDocument = BlockDocument(markdown: loaded)
        editorText = blockDocument.markdown
        editorRevision += 1
        mutateSnapshot {
            $0.fileURL = fileURL
            $0.content = editorText
            $0.isDirty = isDirty
            $0.cursorLocation = 0
            $0.selectionLength = 0
            $0.scrollOffset = 0
        }
        statistics = DocumentStatistics.compute(from: editorText)
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
        guard let result = TaskListService.toggleCheckbox(in: editorText, at: location) else {
            return nil
        }

        blockDocument.applyEditedMarkdown(result.text)
        let markdown = blockDocument.markdown
        editorText = markdown
        mutateSnapshot {
            $0.content = markdown
            $0.cursorLocation = result.cursorLocation
            $0.selectionLength = 0
            $0.isDirty = true
        }
        statistics = DocumentStatistics.compute(from: markdown)
        scheduleAutoSave()
        return TaskListEditResult(text: markdown, cursorLocation: result.cursorLocation)
    }

    func handleListContinuation(at location: Int, text: String) -> TaskListEditResult? {
        guard let cursor = blockDocument.handleEnter(at: location, in: text) else {
            return nil
        }
        commitBlockDocument(cursor: cursor)
        return TaskListEditResult(text: blockDocument.markdown, cursorLocation: cursor)
    }

    private func commitBlockDocument(cursor: Int) {
        editorText = blockDocument.markdown
        editorRevision += 1
        mutateSnapshot {
            $0.content = editorText
            $0.cursorLocation = cursor
            $0.selectionLength = 0
            $0.isDirty = true
        }
        statistics = DocumentStatistics.compute(from: editorText)
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
            updateContent(updated, cursorLocation: match.range.location + (findOptions.replacementText as NSString).length)
            findStatusMessage = nil
        } catch {
            findStatusMessage = error.localizedDescription
        }
    }

    func replaceAllMatches() {
        do {
            let updated = try findReplaceService.replaceAll(in: snapshot.content, options: findOptions)
            updateContent(updated, cursorLocation: snapshot.cursorLocation)
            findStatusMessage = "All matches replaced."
        } catch {
            findStatusMessage = error.localizedDescription
        }
    }

    // MARK: - EditorTextViewDelegate

    func editorTextDidChange(_ text: String, location: Int, selectionLength: Int) {
        updateContent(text, cursorLocation: location, selectionLength: selectionLength)
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
        var updated = snapshot
        mutation(&updated)
        snapshot = updated
    }

    private func updateContent(
        _ text: String,
        cursorLocation: Int,
        selectionLength: Int = 0
    ) {
        blockDocument.applyEditedMarkdown(text)
        let markdown = blockDocument.markdown
        let cursor = markdown == text
            ? cursorLocation
            : DocumentStructureService.mapCursor(from: text, to: markdown, cursor: cursorLocation)

        editorText = markdown
        mutateSnapshot {
            $0.content = markdown
            $0.cursorLocation = cursor
            $0.selectionLength = selectionLength
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
