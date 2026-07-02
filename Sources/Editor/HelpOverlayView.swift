import SwiftUI

enum HelpTab: String, CaseIterable, Identifiable {
    case shortcuts
    case formatting

    var id: String { rawValue }

    var title: String {
        switch self {
        case .shortcuts: "Shortcuts"
        case .formatting: "Formatting"
        }
    }
}

struct HelpOverlayView: View {
    @State private var selectedTab: HelpTab

    init(initialTab: HelpTab = .shortcuts) {
        _selectedTab = State(initialValue: initialTab)
    }

    var body: some View {
        VStack(spacing: 0) {
            Picker("Section", selection: $selectedTab) {
                ForEach(HelpTab.allCases) { tab in
                    Text(tab.title).tag(tab)
                }
            }
            .pickerStyle(.segmented)
            .padding(.horizontal, 20)
            .padding(.bottom, 12)

            ScrollView {
                switch selectedTab {
                case .shortcuts:
                    shortcutsContent
                case .formatting:
                    formattingContent
                }
            }
            .frame(maxHeight: 420)
        }
        .padding(.bottom, 16)
    }

    private var shortcutsContent: some View {
        VStack(alignment: .leading, spacing: 16) {
            ForEach(HelpReference.appSections, id: \.title) { section in
                VStack(alignment: .leading, spacing: 6) {
                    Text(section.title)
                        .font(.subheadline.weight(.semibold))
                    ForEach(section.shortcuts) { item in
                        HStack {
                            Text(item.action)
                            Spacer()
                            Text(item.shortcut)
                                .font(.system(.caption, design: .monospaced))
                                .foregroundStyle(.secondary)
                        }
                    }
                }
            }
        }
        .padding(.horizontal, 20)
    }

    private var formattingContent: some View {
        VStack(alignment: .leading, spacing: 16) {
            ForEach(FormattingHintsReference.sections, id: \.title) { section in
                VStack(alignment: .leading, spacing: 8) {
                    Text(section.title)
                        .font(.subheadline.weight(.semibold))
                    ForEach(section.hints) { hint in
                        VStack(alignment: .leading, spacing: 2) {
                            HStack {
                                Text(hint.title)
                                    .font(.caption.weight(.medium))
                                Spacer()
                                Text(hint.syntax)
                                    .font(.system(.caption, design: .monospaced))
                                    .foregroundStyle(.secondary)
                            }
                            Text(hint.description)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        .padding(.vertical, 2)
                    }
                }
            }
        }
        .padding(.horizontal, 20)
    }
}
