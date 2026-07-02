import Foundation

enum EditorPanel: String, Equatable, CaseIterable, Identifiable {
    case find
    case preferences
    case help
    case formattingHints

    var id: String { rawValue }

    var title: String {
        switch self {
        case .find: "Find"
        case .preferences: "Preferences"
        case .help: "Help"
        case .formattingHints: "Formatting"
        }
    }
}
