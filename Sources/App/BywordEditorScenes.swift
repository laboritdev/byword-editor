import AppKit
import SwiftUI

public struct BywordEditorScenes: Scene {
    @ObservedObject private var appState: AppState
    private let appDelegate: AppDelegate

    public init(appState: AppState, appDelegate: AppDelegate) {
        self.appState = appState
        self.appDelegate = appDelegate
    }

    public var body: some Scene {
        WindowGroup(for: UUID.self) { $documentID in
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
                    .onAppear {
                        if appState.documents.isEmpty {
                            _ = appState.createUntitledDocument()
                        }
                    }
            }
        }
        .onAppear {
            appDelegate.appState = appState
        }
        .onOpenURL { url in
            if let document = appState.openDocument(at: url) {
                openWindow(value: document.snapshot.id)
            }
        }
    }

    private var resolvedViewModel: EditorViewModel? {
        if let documentID, let viewModel = appState.document(with: documentID) {
            return viewModel
        }
        return appState.documents.first
    }

    private func handleDrop(providers: [NSItemProvider]) -> Bool {
        guard let provider = providers.first else { return false }
        provider.loadItem(forTypeIdentifier: "public.file-url", options: nil) { item, _ in
            guard let data = item as? Data,
                  let url = URL(dataRepresentation: data, relativeTo: nil),
                  url.isSupportedTextFile else { return }
            Task { @MainActor in
                if let document = appState.openDocument(at: url) {
                    openWindow(value: document.snapshot.id)
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
