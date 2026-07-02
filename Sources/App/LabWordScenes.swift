import AppKit
import SwiftUI

public struct LabWordScenes: Scene {
    @ObservedObject private var appState: AppState
    private let appDelegate: AppDelegate

    public init(appState: AppState, appDelegate: AppDelegate) {
        self.appState = appState
        self.appDelegate = appDelegate
    }

    public var body: some Scene {
        WindowGroup(id: Constants.documentWindowSceneID, for: UUID.self) { $documentID in
            DocumentSceneView(documentID: documentID, appState: appState, appDelegate: appDelegate)
        }
        .defaultSize(width: 900, height: 700)
        .commands {
            AppCommands(appState: appState)
        }
        .handlesExternalEvents(matching: Set(arrayLiteral: "*"))

        Settings {
            PreferencesView()
        }
    }
}

private struct DocumentSceneView: View {
    let documentID: UUID?
    @ObservedObject var appState: AppState
    let appDelegate: AppDelegate
    @Environment(\.openWindow) private var openWindow
    @State private var fallbackDocumentID: UUID?

    var body: some View {
        Group {
            if let viewModel = resolvedViewModel {
                DocumentWindowRoot(viewModel: viewModel)
                    .focusedValue(\.activeEditor, viewModel)
                    .onDrop(of: [.fileURL], isTargeted: nil) { providers in
                        handleDrop(providers: providers)
                    }
            } else {
                ProgressView("Opening…")
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
        .onAppear {
            appDelegate.appState = appState
            bootstrapDocumentIfNeeded()
        }
        .onChange(of: documentID) { _, _ in
            bootstrapDocumentIfNeeded()
        }
        .onOpenURL { url in
            if let document = appState.openDocument(at: url) {
                openWindow(id: Constants.documentWindowSceneID, value: document.snapshot.id)
            }
        }
    }

    private var resolvedViewModel: EditorViewModel? {
        if let documentID {
            return appState.resolveDocument(forWindow: documentID)
        }
        if let fallbackDocumentID {
            return appState.resolveDocument(forWindow: fallbackDocumentID)
        }
        if appState.documents.count == 1 {
            return appState.documents.first
        }
        return nil
    }

    private func bootstrapDocumentIfNeeded() {
        if documentID != nil {
            return
        }
        if appState.documents.count == 1 {
            return
        }
        if fallbackDocumentID == nil {
            let document = appState.createUntitledDocument()
            fallbackDocumentID = document.snapshot.id
        }
    }

    private func handleDrop(providers: [NSItemProvider]) -> Bool {
        guard let provider = providers.first else { return false }
        provider.loadItem(forTypeIdentifier: "public.file-url", options: nil) { item, _ in
            guard let data = item as? Data,
                  let url = URL(dataRepresentation: data, relativeTo: nil),
                  url.isSupportedTextFile else { return }
            Task { @MainActor in
                if let document = appState.openDocument(at: url) {
                    openWindow(id: Constants.documentWindowSceneID, value: document.snapshot.id)
                }
            }
        }
        return true
    }
}

@MainActor
public final class AppDelegate: NSObject, NSApplicationDelegate {
    public override init() {
        super.init()
    }

    public weak var appState: AppState?

    public func applicationDidFinishLaunching(_ notification: Notification) {
        NSApp.setActivationPolicy(.regular)
        NSApp.activate(ignoringOtherApps: true)
    }

    public func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        true
    }

    public func applicationWillTerminate(_ notification: Notification) {
        appState?.saveSession()
    }
}
