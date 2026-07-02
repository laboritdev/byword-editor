import AppKit
import SwiftUI
import UniformTypeIdentifiers

@MainActor
public final class AppState: ObservableObject {
    @Published private(set) var documents: [EditorViewModel] = []

    let documentService = DocumentService()
    let recoveryService = RecoveryService()
    let sessionService = SessionService()
    let findReplaceService = FindReplaceService()
    let exportService = ExportService()
    let printService = PrintService()
    let renderer = MarkdownRenderer()
    lazy var autoSaveService = AutoSaveService(
        documentService: documentService,
        recoveryService: recoveryService
    )

    public init() {
        restoreSessionIfNeeded()
    }

    func document(with id: UUID) -> EditorViewModel? {
        documents.first { $0.snapshot.id == id }
    }

    func createUntitledDocument(id: UUID? = nil) -> EditorViewModel {
        if let id, let existing = document(with: id) {
            return existing
        }
        let content = IntroDemoContent.initialContent(
            showIntroDemo: PreferencesStore.shared.preferences.showIntroDemo
        )
        let snapshot = DocumentSnapshot(id: id ?? UUID(), content: content)
        let viewModel = makeViewModel(snapshot: snapshot)
        documents.append(viewModel)
        saveSession()
        return viewModel
    }

    func resolveDocument(forWindow documentID: UUID) -> EditorViewModel {
        if let existing = document(with: documentID) {
            return existing
        }
        return createUntitledDocument(id: documentID)
    }

    func openDocument(at url: URL) -> EditorViewModel? {
        if let existing = documents.first(where: { $0.snapshot.fileURL == url }) {
            return existing
        }
        let snapshot = DocumentSnapshot(fileURL: url)
        let viewModel = makeViewModel(snapshot: snapshot)
        viewModel.loadFromURL(url)
        documents.append(viewModel)
        return viewModel
    }

    func openDocumentFromRecovery(_ recovery: RecoverySnapshot) -> EditorViewModel {
        let snapshot = DocumentSnapshot(
            id: recovery.recoveryID,
            fileURL: recovery.fileURL,
            content: recovery.content,
            cursorLocation: recovery.cursorLocation,
            selectionLength: recovery.selectionLength,
            scrollOffset: recovery.scrollOffset,
            viewMode: recovery.viewMode,
            isDirty: recovery.fileURL == nil
        )
        let viewModel = makeViewModel(snapshot: snapshot)
        documents.append(viewModel)
        return viewModel
    }

    func closeDocument(_ viewModel: EditorViewModel) async {
        await viewModel.closeDocument()
        documents.removeAll { $0.snapshot.id == viewModel.snapshot.id }
        saveSession()
    }

    func saveSession() {
        let snapshots = documents.map(\.snapshot)
        sessionService.saveSession(documents: snapshots)
        for snapshot in snapshots {
            recoveryService.saveRecoverySnapshot(from: snapshot)
        }
    }

    func restoreSessionIfNeeded() {
        guard let session = sessionService.loadSession(), let first = session.documents.first else {
            _ = createUntitledDocument()
            return
        }

        if let recovery = recoveryService.loadRecoverySnapshot(for: first.recoveryID) {
            _ = openDocumentFromRecovery(recovery)
        } else if let fileURL = first.fileURL {
            _ = openDocument(at: fileURL)
        } else {
            _ = createUntitledDocument()
        }
    }

    func exportDocument(_ viewModel: EditorViewModel, format: ExportFormat) {
        let panel = NSSavePanel()
        panel.allowedContentTypes = [UTType(filenameExtension: format.fileExtension) ?? .data]
        panel.nameFieldStringValue = "\(viewModel.displayTitle).\(format.fileExtension)"
        panel.begin { [weak self] response in
            guard response == .OK, let url = panel.url, let self else { return }
            do {
                try self.exportService.export(content: viewModel.content, format: format, to: url)
            } catch {
                viewModel.errorMessage = error.localizedDescription
            }
        }
    }

    func printDocument(_ viewModel: EditorViewModel) {
        printService.print(content: viewModel.content, title: viewModel.displayTitle, renderer: renderer)
    }

    private func makeViewModel(snapshot: DocumentSnapshot) -> EditorViewModel {
        EditorViewModel(
            snapshot: snapshot,
            documentService: documentService,
            autoSaveService: autoSaveService,
            recoveryService: recoveryService,
            findReplaceService: findReplaceService
        )
    }
}

struct DocumentWindowRoot: View {
    @ObservedObject var viewModel: EditorViewModel

    var body: some View {
        DocumentWindowView(viewModel: viewModel)
    }
}
