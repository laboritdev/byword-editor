import SwiftUI

struct PreferencesOverlayView: View {
    @ObservedObject private var store = PreferencesStore.shared
    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                Text("Choose the window theme and text width")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity)

                themePicker

                colorThemePicker

                Picker("Text Width", selection: textWidthBinding) {
                    ForEach(TextWidthPreset.allCases) { preset in
                        Text(preset.displayName).tag(preset)
                    }
                }
                .pickerStyle(.segmented)

                Picker("Font", selection: $store.preferences.fontFamily) {
                    ForEach(FontFamily.allCases) { family in
                        Text(family.displayName).tag(family)
                    }
                }

                HStack {
                    Text("Size")
                    Slider(
                        value: $store.preferences.fontSize,
                        in: Constants.minimumFontSize...Constants.maximumFontSize,
                        step: Constants.fontSizeStep
                    )
                    Text("\(Int(store.preferences.fontSize)) pt")
                        .monospacedDigit()
                        .frame(width: 44, alignment: .trailing)
                }

                Picker("Syntax", selection: $store.preferences.syntaxHighlightMode) {
                    ForEach(SyntaxHighlightMode.allCases) { mode in
                        Text(mode.displayName).tag(mode)
                    }
                }
                .pickerStyle(.segmented)

                Toggle("Show intro demo on new documents", isOn: $store.preferences.showIntroDemo)
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 20)
        }
    }

    private var themePicker: some View {
        HStack(spacing: 16) {
            themeButton(mode: .light, label: "Light", scheme: .light)
            themeButton(mode: .dark, label: "Dark", scheme: .dark)
        }
    }

    private var colorThemePicker: some View {
        HStack(spacing: 12) {
            ForEach(ColorTheme.allCases) { theme in
                colorThemeCard(theme: theme)
            }
        }
    }

    private func colorThemeCard(theme: ColorTheme) -> some View {
        let isSelected = store.preferences.colorTheme == theme
        let scheme = resolvedScheme(for: store.preferences.appearanceMode)
        let colors = EditorColors.colors(for: scheme, theme: theme, syntaxMode: .subtle)

        return Button {
            store.preferences.colorTheme = theme
        } label: {
            VStack(spacing: 6) {
                EditorThemePreview(colors: colors)
                    .frame(height: 64)
                    .overlay {
                        RoundedRectangle(cornerRadius: 8)
                            .strokeBorder(isSelected ? Color.accentColor : Color.primary.opacity(0.08), lineWidth: isSelected ? 2 : 1)
                    }
                Text(theme.displayName)
                    .font(.caption2)
                    .foregroundStyle(isSelected ? Color.accentColor : .secondary)
            }
        }
        .buttonStyle(.plain)
        .frame(maxWidth: .infinity)
    }

    private func themeButton(mode: AppearanceMode, label: String, scheme: ColorScheme) -> some View {
        let isSelected = store.preferences.appearanceMode == mode
        let colors = EditorColors.colors(
            for: scheme,
            theme: store.preferences.colorTheme,
            syntaxMode: .subtle
        )

        return Button {
            store.preferences.appearanceMode = mode
        } label: {
            VStack(spacing: 8) {
                EditorThemePreview(colors: colors)
                    .frame(height: 72)
                    .overlay {
                        RoundedRectangle(cornerRadius: 8)
                            .strokeBorder(isSelected ? Color.accentColor : Color.clear, lineWidth: 2.5)
                    }
                Text(label)
                    .font(.caption)
                    .foregroundStyle(isSelected ? Color.accentColor : .secondary)
            }
        }
        .buttonStyle(.plain)
        .frame(maxWidth: .infinity)
    }

    private func resolvedScheme(for mode: AppearanceMode) -> ColorScheme {
        mode.colorScheme ?? colorScheme
    }

    private var textWidthBinding: Binding<TextWidthPreset> {
        Binding(
            get: { TextWidthPreset.from(columnWidth: store.preferences.columnWidth) },
            set: { store.preferences.columnWidth = $0.columnWidth }
        )
    }
}

private struct EditorThemePreview: View {
    let colors: EditorColors

    var body: some View {
        RoundedRectangle(cornerRadius: 8)
            .fill(colors.background)
            .overlay {
                VStack(alignment: .leading, spacing: 5) {
                    HStack(spacing: 0) {
                        Text("# ")
                            .foregroundStyle(colors.text.opacity(0.35))
                        Text("Heading")
                            .foregroundStyle(colors.text)
                            .fontWeight(.semibold)
                    }
                    .font(.system(size: 9, design: .serif))

                    Text("Body text with **bold** and `code`.")
                        .font(.system(size: 8, design: .serif))
                        .foregroundStyle(colors.text.opacity(0.85))

                    HStack(spacing: 0) {
                        Text("- [x] ")
                            .foregroundStyle(colors.text.opacity(0.35))
                        Text("Done task")
                            .foregroundStyle(colors.text.opacity(0.45))
                            .strikethrough()
                    }
                    .font(.system(size: 8, design: .serif))
                }
                .padding(.horizontal, 10)
                .padding(.vertical, 8)
                .frame(maxWidth: .infinity, alignment: .leading)
            }
    }
}

enum TextWidthPreset: String, CaseIterable, Identifiable {
    case narrow
    case medium
    case wide

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .narrow: "Narrow"
        case .medium: "Medium"
        case .wide: "Wide"
        }
    }

    var columnWidth: CGFloat {
        switch self {
        case .narrow: 480
        case .medium: 640
        case .wide: 820
        }
    }

    static func from(columnWidth: CGFloat) -> TextWidthPreset {
        if columnWidth < 560 { return .narrow }
        if columnWidth < 730 { return .medium }
        return .wide
    }
}
