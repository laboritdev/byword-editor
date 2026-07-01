import AppKit
import SwiftUI
import UniformTypeIdentifiers

struct AppCommands: Commands {
    @FocusedValue(\.activeEditor) private var activeEditor
    @Environment(\.openWindow) private var openWindow
    @Environment(\.openSettings) private var openSettings
    let appState: AppState

    var body: some Commands {
        CommandGroup(replacing: .newItem) {
            Button("New Document") {
                let document = appState.createUntitledDocument()
                openWindow(value: document.snapshot.id)
            }
            .keyboardShortcut("n")

            Button("Open…") {
                openPanel()
            }
            .keyboardShortcut("o")

            Menu("Open Recent") {
                ForEach(RecentFilesService.shared.recentFiles, id: \.path) { url in
                    Button(url.lastPathComponent) {
                        if let document = appState.openDocument(at: url) {
                            openWindow(value: document.snapshot.id)
                        }
                    }
                }
            }
        }

        CommandGroup(after: .saveItem) {
            Button("Save") {
                Task { await activeEditor?.saveImmediately() }
            }
            .keyboardShortcut("s")

            Button("Save As…") {
                saveAs()
            }
            .keyboardShortcut("S", modifiers: [.command, .shift])

            Button("Duplicate…") {
                duplicate()
            }

            Divider()

            Button("Export as PDF…") {
                guard let editor = activeEditor else { return }
                appState.exportDocument(editor, format: .pdf)
            }

            Button("Export as HTML…") {
                guard let editor = activeEditor else { return }
                appState.exportDocument(editor, format: .html)
            }

            Button("Export as RTF…") {
                guard let editor = activeEditor else { return }
                appState.exportDocument(editor, format: .rtf)
            }
        }

        CommandGroup(replacing: .textEditing) {
            Button("Find…") {
                activeEditor?.showFindPanel()
            }
            .keyboardShortcut("f")

            Button("Find Next") {
                activeEditor?.findNext()
            }
            .keyboardShortcut("g")

            Button("Find Previous") {
                activeEditor?.findPrevious()
            }
            .keyboardShortcut("g", modifiers: [.command, .shift])
        }

        CommandMenu("View") {
            Button("Toggle Preview") {
                activeEditor?.toggleViewMode()
            }
            .keyboardShortcut("p", modifiers: [.command, .option])

            Button("Focus Mode") {
                FocusModeManager.shared.toggle()
            }
            .keyboardShortcut("f", modifiers: [.command, .control])
        }

        CommandGroup(replacing: .appSettings) {
            Button("Preferences…") {
                openSettings()
            }
            .keyboardShortcut(",")
        }

        CommandGroup(after: .printItem) {
            Button("Print…") {
                guard let editor = activeEditor else { return }
                appState.printDocument(editor)
            }
            .keyboardShortcut("p")
        }

        CommandGroup(replacing: .appVisibility) {
            Button("Hide BywordEditor") {
                NSApp.hide(nil)
            }

            Button("Hide Others") {
                NSApp.hideOtherApplications(nil)
            }
            .keyboardShortcut("h", modifiers: [.command, .option])

            Button("Show All") {
                NSApp.unhideAllApplications(nil)
            }
        }

        CommandGroup(replacing: .help) {
            Button("BywordEditor Help") {
                HelpWindowController.shared.present()
            }
            .keyboardShortcut("h")
        }
    }

    private func openPanel() {
        let panel = NSOpenPanel()
        panel.allowsMultipleSelection = false
        panel.canChooseDirectories = false
        panel.allowedContentTypes = [
            UTType(filenameExtension: "md") ?? .plainText,
            UTType(filenameExtension: "markdown") ?? .plainText,
            UTType(filenameExtension: "txt") ?? .plainText,
        ]
        panel.begin { response in
            guard response == .OK, let url = panel.url else { return }
            if let document = appState.openDocument(at: url) {
                openWindow(value: document.snapshot.id)
            }
        }
    }

    private func saveAs() {
        guard let editor = activeEditor else { return }
        let panel = NSSavePanel()
        panel.allowedContentTypes = [UTType(filenameExtension: "md") ?? .plainText]
        panel.nameFieldStringValue = "\(editor.displayTitle).md"
        panel.begin { response in
            guard response == .OK, let url = panel.url else { return }
            editor.saveAs(to: url)
        }
    }

    private func duplicate() {
        guard let editor = activeEditor, let source = editor.snapshot.fileURL else { return }
        let panel = NSSavePanel()
        panel.allowedContentTypes = [UTType(filenameExtension: source.pathExtension) ?? .plainText]
        panel.nameFieldStringValue = source.lastPathComponent
        panel.begin { response in
            guard response == .OK, let url = panel.url else { return }
            editor.duplicate(to: url)
        }
    }
}

private struct ActiveEditorKey: FocusedValueKey {
    typealias Value = EditorViewModel
}

extension FocusedValues {
    var activeEditor: EditorViewModel? {
        get { self[ActiveEditorKey.self] }
        set { self[ActiveEditorKey.self] = newValue }
    }
}
