import AppKit
import SwiftUI

struct HelpView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                header

                ForEach(HelpReference.appSections, id: \.title) { section in
                    shortcutSection(title: section.title, shortcuts: section.shortcuts)
                }

                developerSection
            }
            .padding(24)
        }
        .frame(width: 480, height: 520)
        .background(Color(nsColor: .windowBackgroundColor))
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("BywordEditor Help")
                .font(.title2.weight(.semibold))
            Text("Keyboard shortcuts and developer commands.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
    }

    private func shortcutSection(title: String, shortcuts: [HelpShortcut]) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.headline)

            VStack(spacing: 0) {
                ForEach(shortcuts) { item in
                    HStack {
                        Text(item.action)
                        Spacer()
                        Text(item.shortcut)
                            .font(.system(.body, design: .monospaced))
                            .foregroundStyle(.secondary)
                    }
                    .padding(.vertical, 6)

                    if item.id != shortcuts.last?.id {
                        Divider()
                    }
                }
            }
            .padding(.horizontal, 12)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color(nsColor: .controlBackgroundColor))
            )
        }
    }

    private var developerSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Development")
                .font(.headline)

            Text("Run these commands in the project directory from Terminal.")
                .font(.caption)
                .foregroundStyle(.secondary)

            VStack(spacing: 0) {
                ForEach(Array(HelpReference.developerCommands.enumerated()), id: \.offset) { index, item in
                    HStack(alignment: .top) {
                        Text(item.command)
                            .font(.system(.body, design: .monospaced))
                            .frame(width: 120, alignment: .leading)
                        Text(item.description)
                            .foregroundStyle(.secondary)
                        Spacer()
                    }
                    .padding(.vertical, 6)

                    if index < HelpReference.developerCommands.count - 1 {
                        Divider()
                    }
                }
            }
            .padding(.horizontal, 12)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color(nsColor: .controlBackgroundColor))
            )
        }
    }
}
