import AppKit
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

struct EditorColorsNS: Equatable {
    let background: NSColor
    let text: NSColor
    let heading: NSColor
    let bold: NSColor
    let italic: NSColor
    let link: NSColor
    let code: NSColor
    let codeBlockBackground: NSColor
    let blockquote: NSColor
    let listMarker: NSColor
    let horizontalRule: NSColor

    static func colors(for scheme: ColorScheme) -> EditorColorsNS {
        if scheme == .dark {
            return EditorColorsNS(
                background: nsColor(red: 0.11, green: 0.11, blue: 0.12),
                text: nsColor(red: 0.88, green: 0.88, blue: 0.90),
                heading: nsColor(red: 0.95, green: 0.95, blue: 0.97),
                bold: nsColor(red: 0.95, green: 0.95, blue: 0.97),
                italic: nsColor(red: 0.82, green: 0.82, blue: 0.86),
                link: nsColor(red: 0.40, green: 0.65, blue: 0.95),
                code: nsColor(red: 0.85, green: 0.55, blue: 0.45),
                codeBlockBackground: nsColor(red: 0.16, green: 0.16, blue: 0.18),
                blockquote: nsColor(red: 0.55, green: 0.55, blue: 0.60),
                listMarker: nsColor(red: 0.50, green: 0.50, blue: 0.55),
                horizontalRule: nsColor(red: 0.35, green: 0.35, blue: 0.38)
            )
        }
        return EditorColorsNS(
            background: nsColor(red: 0.98, green: 0.98, blue: 0.97),
            text: nsColor(red: 0.15, green: 0.15, blue: 0.17),
            heading: nsColor(red: 0.08, green: 0.08, blue: 0.10),
            bold: nsColor(red: 0.08, green: 0.08, blue: 0.10),
            italic: nsColor(red: 0.25, green: 0.25, blue: 0.28),
            link: nsColor(red: 0.15, green: 0.45, blue: 0.85),
            code: nsColor(red: 0.75, green: 0.30, blue: 0.20),
            codeBlockBackground: nsColor(red: 0.94, green: 0.94, blue: 0.93),
            blockquote: nsColor(red: 0.45, green: 0.45, blue: 0.48),
            listMarker: nsColor(red: 0.55, green: 0.55, blue: 0.58),
            horizontalRule: nsColor(red: 0.78, green: 0.78, blue: 0.80)
        )
    }

    private static func nsColor(red: CGFloat, green: CGFloat, blue: CGFloat) -> NSColor {
        EditorColorFactory.rgb(red: red, green: green, blue: blue)
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
        let native = EditorColorsNS.colors(for: scheme)
        return EditorColors(
            background: Color(nsColor: native.background),
            text: Color(nsColor: native.text),
            heading: Color(nsColor: native.heading),
            bold: Color(nsColor: native.bold),
            italic: Color(nsColor: native.italic),
            link: Color(nsColor: native.link),
            code: Color(nsColor: native.code),
            codeBlockBackground: Color(nsColor: native.codeBlockBackground),
            blockquote: Color(nsColor: native.blockquote),
            listMarker: Color(nsColor: native.listMarker),
            horizontalRule: Color(nsColor: native.horizontalRule),
            selection: scheme == .dark
                ? Color(red: 0.25, green: 0.45, blue: 0.75).opacity(0.35)
                : Color(red: 0.30, green: 0.55, blue: 0.90).opacity(0.25)
        )
    }
}
