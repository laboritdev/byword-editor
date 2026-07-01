import SwiftUI

enum AppearanceMode: String, Codable, CaseIterable, Identifiable {
    case system
    case light
    case dark

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .system: "System"
        case .light: "Light"
        case .dark: "Dark"
        }
    }

    var colorScheme: ColorScheme? {
        switch self {
        case .system: nil
        case .light: .light
        case .dark: .dark
        }
    }
}

struct EditorColors: Equatable {
    let background: Color
    let text: Color
    let heading: Color
    let bold: Color
    let italic: Color
    let link: Color
    let code: Color
    let codeBlockBackground: Color
    let blockquote: Color
    let listMarker: Color
    let horizontalRule: Color
    let selection: Color

    static func colors(for scheme: ColorScheme) -> EditorColors {
        if scheme == .dark {
            return EditorColors(
                background: Color(red: 0.11, green: 0.11, blue: 0.12),
                text: Color(red: 0.88, green: 0.88, blue: 0.90),
                heading: Color(red: 0.95, green: 0.95, blue: 0.97),
                bold: Color(red: 0.95, green: 0.95, blue: 0.97),
                italic: Color(red: 0.82, green: 0.82, blue: 0.86),
                link: Color(red: 0.40, green: 0.65, blue: 0.95),
                code: Color(red: 0.85, green: 0.55, blue: 0.45),
                codeBlockBackground: Color(red: 0.16, green: 0.16, blue: 0.18),
                blockquote: Color(red: 0.55, green: 0.55, blue: 0.60),
                listMarker: Color(red: 0.50, green: 0.50, blue: 0.55),
                horizontalRule: Color(red: 0.35, green: 0.35, blue: 0.38),
                selection: Color(red: 0.25, green: 0.45, blue: 0.75).opacity(0.35)
            )
        }
        return EditorColors(
            background: Color(red: 0.98, green: 0.98, blue: 0.97),
            text: Color(red: 0.15, green: 0.15, blue: 0.17),
            heading: Color(red: 0.08, green: 0.08, blue: 0.10),
            bold: Color(red: 0.08, green: 0.08, blue: 0.10),
            italic: Color(red: 0.25, green: 0.25, blue: 0.28),
            link: Color(red: 0.15, green: 0.45, blue: 0.85),
            code: Color(red: 0.75, green: 0.30, blue: 0.20),
            codeBlockBackground: Color(red: 0.94, green: 0.94, blue: 0.93),
            blockquote: Color(red: 0.45, green: 0.45, blue: 0.48),
            listMarker: Color(red: 0.55, green: 0.55, blue: 0.58),
            horizontalRule: Color(red: 0.78, green: 0.78, blue: 0.80),
            selection: Color(red: 0.30, green: 0.55, blue: 0.90).opacity(0.25)
        )
    }
}
