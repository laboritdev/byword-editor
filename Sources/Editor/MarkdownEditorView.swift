import AppKit
import SwiftUI

struct MarkdownEditorView: View {
    @ObservedObject var viewModel: EditorViewModel
    @ObservedObject private var preferencesStore = PreferencesStore.shared
    @ObservedObject private var focusMode = FocusModeManager.shared
    @Environment(\.colorScheme) private var colorScheme

    private let renderer = MarkdownRenderer()

    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                if viewModel.activePanel == .find && !focusMode.isFocusModeEnabled {
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

            if let panel = viewModel.activePanel,
               panel != .find,
               !focusMode.isFocusModeEnabled {
                overlay(for: panel)
            }
        }
        .preferredColorScheme(preferencesStore.preferences.appearanceMode.colorScheme)
        .onExitCommand {
            if viewModel.activePanel != nil {
                viewModel.dismissPanel()
            }
        }
        .alert("Error", isPresented: errorBinding) {
            Button("OK") { viewModel.errorMessage = nil }
        } message: {
            Text(viewModel.errorMessage ?? "")
        }
    }

    @ViewBuilder
    private func overlay(for panel: EditorPanel) -> some View {
        switch panel {
        case .find:
            EmptyView()
        case .preferences:
            EditorOverlayContainer(title: "Preferences", onDismiss: viewModel.dismissPanel) {
                PreferencesOverlayView()
            }
        case .help:
            EditorOverlayContainer(title: "Help", onDismiss: viewModel.dismissPanel) {
                HelpOverlayView()
            }
        case .formattingHints:
            EditorOverlayContainer(title: "Formatting", onDismiss: viewModel.dismissPanel) {
                HelpOverlayView(initialTab: .formatting)
            }
        }
    }

    private var editorView: some View {
        GeometryReader { geometry in
            NSTextViewRepresentable(
                text: Binding(
                    get: { viewModel.editorText },
                    set: { viewModel.content = $0 }
                ),
                configuration: editorConfiguration(containerWidth: geometry.size.width),
                cursorLocation: viewModel.snapshot.cursorLocation,
                selectionLength: viewModel.snapshot.selectionLength,
                scrollOffset: viewModel.snapshot.scrollOffset,
                delegate: viewModel,
                onToggleCheckbox: { viewModel.toggleTaskCheckbox(at: $0, in: $1) },
                onListContinuation: { viewModel.handleListContinuation(at: $0, text: $1) }
            )
        }
    }

    private var statusBar: some View {
        HStack(spacing: 16) {
            Text(viewModel.snapshot.fileLocationLabel)
                .font(.system(size: 11, weight: .medium, design: .monospaced))
                .foregroundStyle(editorColors.text.opacity(0.40))
                .lineLimit(1)
                .frame(maxWidth: .infinity, alignment: .leading)

            if preferencesStore.preferences.showWordCount {
                Text(viewModel.statistics.statusText)
                    .font(.system(size: 11, weight: .regular, design: .serif))
                    .foregroundStyle(editorColors.text.opacity(0.32))
                    .lineLimit(1)
            }

            Text(cursorStatusLabel)
                .font(.system(size: 11, weight: .regular, design: .monospaced))
                .foregroundStyle(editorColors.text.opacity(0.32))
                .lineLimit(1)

            Text(viewModel.saveFeedback ?? viewModel.snapshot.saveStateLabel)
                .font(.system(size: 11, weight: .medium, design: .default))
                .foregroundStyle(saveStateColor)
                .lineLimit(1)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 10)
        .background(editorColors.background)
    }

    private var cursorStatusLabel: String {
        EditorCursorPosition.from(
            text: viewModel.editorText,
            location: viewModel.snapshot.cursorLocation,
            selectionLength: viewModel.snapshot.selectionLength
        ).statusLabel
    }

    private var saveStateColor: Color {
        if viewModel.snapshot.fileURL == nil {
            return editorColors.text.opacity(viewModel.snapshot.isDirty ? 0.55 : 0.35)
        }
        return editorColors.text.opacity(viewModel.snapshot.isDirty ? 0.55 : 0.38)
    }

    private var editorColors: EditorColors {
        EditorColors.colors(
            for: resolvedColorScheme,
            theme: preferencesStore.preferences.colorTheme,
            syntaxMode: preferencesStore.preferences.syntaxHighlightMode
        )
    }

    private func editorConfiguration(containerWidth: CGFloat) -> EditorConfiguration {
        let prefs = preferencesStore.preferences
        let colors = EditorColorsNS.colors(
            for: resolvedColorScheme,
            theme: prefs.colorTheme,
            syntaxMode: prefs.syntaxHighlightMode
        )
        let horizontalMargin = prefs.centerColumn
            ? EditorTypography.centeredHorizontalMargin(
                containerWidth: containerWidth,
                columnWidth: prefs.columnWidth,
                minimumMargin: prefs.horizontalMargin
            )
            : prefs.horizontalMargin
        return EditorConfiguration(
            font: prefs.fontFamily.nsFont(size: prefs.fontSize),
            textColor: colors.text,
            backgroundColor: colors.background,
            lineHeight: prefs.lineHeight,
            horizontalMargin: horizontalMargin,
            columnWidth: prefs.columnWidth,
            syntaxColors: colors,
            syntaxHighlightMode: prefs.syntaxHighlightMode,
            isDarkMode: resolvedColorScheme == .dark,
            colorTheme: prefs.colorTheme
        )
    }

    private var resolvedColorScheme: ColorScheme {
        EditorAppearance.resolvedColorScheme(
            appearanceMode: preferencesStore.preferences.appearanceMode,
            environment: colorScheme
        )
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
    @ObservedObject private var preferencesStore = PreferencesStore.shared
    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        MarkdownEditorView(viewModel: viewModel)
            .frame(minWidth: 640, minHeight: 480)
            .background(editorBackground)
            .navigationTitle(viewModel.displayTitle)
            .toolbarBackground(editorBackground, for: .windowToolbar)
            .toolbarBackground(.visible, for: .windowToolbar)
            .toolbarColorScheme(resolvedColorScheme == .dark ? .dark : .light, for: .windowToolbar)
    }

    private var resolvedColorScheme: ColorScheme {
        EditorAppearance.resolvedColorScheme(
            appearanceMode: preferencesStore.preferences.appearanceMode,
            environment: colorScheme
        )
    }

    private var editorBackground: Color {
        EditorColors.colors(
            for: resolvedColorScheme,
            theme: preferencesStore.preferences.colorTheme,
            syntaxMode: preferencesStore.preferences.syntaxHighlightMode
        ).background
    }
}
