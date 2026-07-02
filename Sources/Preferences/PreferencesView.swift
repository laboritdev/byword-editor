import AppKit
import SwiftUI

struct PreferencesView: View {
    @ObservedObject private var store = PreferencesStore.shared

    var body: some View {
        Form {
            Section("Typography") {
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
                        .frame(width: 48, alignment: .trailing)
                }

                HStack {
                    Text("Line Height")
                    Slider(value: $store.preferences.lineHeight, in: 1.2...2.4, step: 0.05)
                    Text(String(format: "%.2f", store.preferences.lineHeight))
                        .monospacedDigit()
                        .frame(width: 48, alignment: .trailing)
                }

                HStack {
                    Text("Column Width")
                    Slider(value: $store.preferences.columnWidth, in: 480...960, step: 20)
                    Text("\(Int(store.preferences.columnWidth)) px")
                        .monospacedDigit()
                        .frame(width: 56, alignment: .trailing)
                }

                HStack {
                    Text("Side Margin")
                    Slider(value: $store.preferences.horizontalMargin, in: 24...160, step: 4)
                    Text("\(Int(store.preferences.horizontalMargin)) px")
                        .monospacedDigit()
                        .frame(width: 56, alignment: .trailing)
                }

                Toggle("Center writing column", isOn: $store.preferences.centerColumn)
            }

            Section("Appearance") {
                Picker("Mode", selection: $store.preferences.appearanceMode) {
                    ForEach(AppearanceMode.allCases) { mode in
                        Text(mode.displayName).tag(mode)
                    }
                }
                .pickerStyle(.segmented)

                Picker("Color Theme", selection: $store.preferences.colorTheme) {
                    ForEach(ColorTheme.allCases) { theme in
                        Text(theme.displayName).tag(theme)
                    }
                }

                Picker("Syntax Highlighting", selection: $store.preferences.syntaxHighlightMode) {
                    ForEach(SyntaxHighlightMode.allCases) { mode in
                        Text(mode.displayName).tag(mode)
                    }
                }
                .pickerStyle(.segmented)
            }

            Section("Status") {
                Toggle("Show word count", isOn: $store.preferences.showWordCount)
                Toggle("Show status bar", isOn: $store.preferences.showStatusBar)
            }

            Section("Documents") {
                Toggle("Show intro demo on new documents", isOn: $store.preferences.showIntroDemo)
            }
        }
        .formStyle(.grouped)
        .frame(width: 440, height: 520)
        .padding()
    }
}
