import AppKit
import SwiftUI

struct MarkdownEditorView: View {
    @ObservedObject var viewModel: EditorViewModel
    @ObservedObject private var preferencesStore = PreferencesStore.shared
    @ObservedObject private var focusMode = FocusModeManager.shared
    @Environment(\.colorScheme) private var colorScheme

    private let renderer = MarkdownRenderer()

    var body: some View {
        VStack(spacing: 0) {
            if viewModel.isFindPanelVisible && !focusMode.isFocusModeEnabled {
                FindReplacePanel(viewModel: viewModel)
            }

            ZStack {
                editorColors.background.ignoresSafeArea()

                if viewModel.viewMode == .editor {
                    editorView
                } else {
                    MarkdownPreviewView(html: renderer.renderHTML(from: viewModel.content))
                }
            }

            if preferencesStore.preferences.showStatusBar && !focusMode.isFocusModeEnabled {
                statusBar
            }
        }
        .preferredColorScheme(preferencesStore.preferences.appearanceMode.colorScheme)
        .alert("Error", isPresented: errorBinding) {
            Button("OK") { viewModel.errorMessage = nil }
        } message: {
            Text(viewModel.errorMessage ?? "")
        }
    }

    private var editorView: some View {
        NSTextViewRepresentable(
            text: Binding(
                get: { viewModel.content },
                set: { viewModel.content = $0 }
            ),
            configuration: editorConfiguration,
            cursorLocation: viewModel.snapshot.cursorLocation,
            selectionLength: viewModel.snapshot.selectionLength,
            scrollOffset: viewModel.snapshot.scrollOffset,
            delegate: viewModel
        )
    }

    private var statusBar: some View {
        HStack {
            if preferencesStore.preferences.showWordCount {
                Text(viewModel.statistics.statusText)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            Spacer()
            Text(viewModel.viewMode == .editor ? "Editor" : "Preview")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 6)
        .background(.bar)
    }

    private var editorConfiguration: EditorConfiguration {
        let prefs = preferencesStore.preferences
        let colors = EditorColors.colors(for: resolvedColorScheme)
        return EditorConfiguration(
            font: prefs.fontFamily.nsFont(size: prefs.fontSize),
            textColor: NSColor(colors.text),
            backgroundColor: NSColor(colors.background),
            lineHeight: prefs.lineHeight,
            horizontalMargin: prefs.horizontalMargin,
            columnWidth: prefs.columnWidth,
            syntaxColors: EditorColorsNS(from: colors, colorScheme: resolvedColorScheme)
        )
    }

    private var editorColors: EditorColors {
        EditorColors.colors(for: resolvedColorScheme)
    }

    private var resolvedColorScheme: ColorScheme {
        preferencesStore.preferences.appearanceMode.colorScheme ?? colorScheme
    }

    private var errorBinding: Binding<Bool> {
        Binding(
            get: { viewModel.errorMessage != nil },
            set: { if !$0 { viewModel.errorMessage = nil } }
        )
    }
}

struct DocumentWindowView: View {
    @ObservedObject var viewModel: EditorViewModel
    @ObservedObject private var focusMode = FocusModeManager.shared

    var body: some View {
        MarkdownEditorView(viewModel: viewModel)
            .frame(minWidth: 640, minHeight: 480)
            .toolbar {
                if !focusMode.isFocusModeEnabled {
                    ToolbarItemGroup(placement: .primaryAction) {
                        Button {
                            viewModel.toggleViewMode()
                        } label: {
                            Label(
                                viewModel.viewMode == .editor ? "Preview" : "Editor",
                                systemImage: viewModel.viewMode == .editor ? "eye" : "pencil"
                            )
                        }
                        .help("Toggle Preview")

                        Button {
                            FocusModeManager.shared.toggle()
                        } label: {
                            Label("Focus", systemImage: "arrow.up.left.and.arrow.down.right")
                        }
                        .help("Focus Mode")
                    }
                }
            }
            .navigationTitle(viewModel.displayTitle)
    }
}
