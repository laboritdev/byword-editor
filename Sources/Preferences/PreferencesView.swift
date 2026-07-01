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
                    Slider(value: $store.preferences.fontSize, in: 12...28, step: 1)
                    Text("\(Int(store.preferences.fontSize)) pt")
                        .monospacedDigit()
                        .frame(width: 48, alignment: .trailing)
                }

                HStack {
                    Text("Line Height")
                    Slider(value: $store.preferences.lineHeight, in: 1.2...2.4, step: 0.1)
                    Text(String(format: "%.1f", store.preferences.lineHeight))
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
            }

            Section("Appearance") {
                Picker("Theme", selection: $store.preferences.appearanceMode) {
                    ForEach(AppearanceMode.allCases) { mode in
                        Text(mode.displayName).tag(mode)
                    }
                }
                .pickerStyle(.segmented)
            }

            Section("Status") {
                Toggle("Show word count", isOn: $store.preferences.showWordCount)
                Toggle("Show status bar", isOn: $store.preferences.showStatusBar)
            }
        }
        .formStyle(.grouped)
        .frame(width: 420, height: 360)
        .padding()
    }
}
