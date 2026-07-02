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

enum ColorTheme: String, Codable, CaseIterable, Identifiable {
    case classic
    case sepia
    case paper

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .classic: "Classic"
        case .sepia: "Sepia"
        case .paper: "Paper"
        }
    }
}

enum SyntaxHighlightMode: String, Codable, CaseIterable, Identifiable {
    case off
    case subtle
    case full

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .off: "Off"
        case .subtle: "Subtle"
        case .full: "Full"
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
    let syntaxMarker: NSColor
    let taskChecked: NSColor
    let selection: NSColor

    static func colors(
        for scheme: ColorScheme,
        theme: ColorTheme = .classic,
        syntaxMode: SyntaxHighlightMode = .subtle
    ) -> EditorColorsNS {
        let palette = basePalette(for: scheme, theme: theme)
        return palette.adjusted(for: syntaxMode)
    }

    private static func basePalette(for scheme: ColorScheme, theme: ColorTheme) -> EditorColorsNS {
        switch (scheme, theme) {
        case (.dark, .classic):
            return EditorColorsNS(
                background: rgb(0.088, 0.087, 0.085),
                text: rgb(0.925, 0.918, 0.905),
                heading: rgb(0.98, 0.975, 0.965),
                bold: rgb(0.98, 0.975, 0.965),
                italic: rgb(0.84, 0.835, 0.82),
                link: rgb(0.52, 0.72, 0.96),
                code: rgb(0.80, 0.795, 0.78),
                codeBlockBackground: rgb(0.11, 0.109, 0.107),
                blockquote: rgb(0.55, 0.545, 0.53),
                listMarker: rgb(0.38, 0.375, 0.37),
                horizontalRule: rgb(0.22, 0.218, 0.215),
                syntaxMarker: rgb(0.38, 0.375, 0.37),
                taskChecked: rgb(0.48, 0.76, 0.54),
                selection: rgb(0.28, 0.48, 0.78, alpha: 0.32)
            )
        case (.dark, .sepia):
            return EditorColorsNS(
                background: rgb(0.15, 0.13, 0.11),
                text: rgb(0.88, 0.84, 0.78),
                heading: rgb(0.94, 0.90, 0.84),
                bold: rgb(0.94, 0.90, 0.84),
                italic: rgb(0.78, 0.74, 0.68),
                link: rgb(0.58, 0.74, 0.90),
                code: rgb(0.74, 0.70, 0.64),
                codeBlockBackground: rgb(0.19, 0.17, 0.15),
                blockquote: rgb(0.60, 0.56, 0.50),
                listMarker: rgb(0.50, 0.46, 0.42),
                horizontalRule: rgb(0.36, 0.32, 0.28),
                syntaxMarker: rgb(0.50, 0.46, 0.42),
                taskChecked: rgb(0.58, 0.76, 0.52),
                selection: rgb(0.30, 0.48, 0.68, alpha: 0.36)
            )
        case (.dark, .paper):
            return EditorColorsNS(
                background: rgb(0.10, 0.10, 0.11),
                text: rgb(0.90, 0.90, 0.92),
                heading: rgb(0.96, 0.96, 0.98),
                bold: rgb(0.96, 0.96, 0.98),
                italic: rgb(0.82, 0.82, 0.86),
                link: rgb(0.42, 0.66, 0.96),
                code: rgb(0.84, 0.56, 0.46),
                codeBlockBackground: rgb(0.15, 0.15, 0.17),
                blockquote: rgb(0.54, 0.54, 0.58),
                listMarker: rgb(0.46, 0.46, 0.50),
                horizontalRule: rgb(0.32, 0.32, 0.36),
                syntaxMarker: rgb(0.46, 0.46, 0.50),
                taskChecked: rgb(0.50, 0.78, 0.54),
                selection: rgb(0.24, 0.44, 0.76, alpha: 0.38)
            )
        case (_, .classic):
            return EditorColorsNS(
                background: rgb(0.978, 0.972, 0.956),
                text: rgb(0.20, 0.19, 0.18),
                heading: rgb(0.12, 0.11, 0.10),
                bold: rgb(0.12, 0.11, 0.10),
                italic: rgb(0.30, 0.28, 0.26),
                link: rgb(0.22, 0.46, 0.78),
                code: rgb(0.36, 0.34, 0.32),
                codeBlockBackground: rgb(0.958, 0.952, 0.936),
                blockquote: rgb(0.48, 0.46, 0.44),
                listMarker: rgb(0.54, 0.52, 0.50),
                horizontalRule: rgb(0.78, 0.76, 0.74),
                syntaxMarker: rgb(0.68, 0.66, 0.64),
                taskChecked: rgb(0.28, 0.58, 0.36),
                selection: rgb(0.30, 0.55, 0.90, alpha: 0.24)
            )
        case (_, .sepia):
            return EditorColorsNS(
                background: rgb(0.96, 0.93, 0.86),
                text: rgb(0.30, 0.26, 0.22),
                heading: rgb(0.22, 0.18, 0.14),
                bold: rgb(0.22, 0.18, 0.14),
                italic: rgb(0.38, 0.34, 0.30),
                link: rgb(0.26, 0.44, 0.68),
                code: rgb(0.42, 0.38, 0.34),
                codeBlockBackground: rgb(0.92, 0.89, 0.82),
                blockquote: rgb(0.52, 0.48, 0.42),
                listMarker: rgb(0.56, 0.52, 0.46),
                horizontalRule: rgb(0.76, 0.72, 0.66),
                syntaxMarker: rgb(0.68, 0.62, 0.56),
                taskChecked: rgb(0.32, 0.56, 0.34),
                selection: rgb(0.32, 0.52, 0.78, alpha: 0.22)
            )
        case (_, .paper):
            return EditorColorsNS(
                background: rgb(0.992, 0.990, 0.984),
                text: rgb(0.14, 0.14, 0.16),
                heading: rgb(0.08, 0.08, 0.10),
                bold: rgb(0.08, 0.08, 0.10),
                italic: rgb(0.24, 0.24, 0.27),
                link: rgb(0.18, 0.46, 0.86),
                code: rgb(0.72, 0.32, 0.22),
                codeBlockBackground: rgb(0.968, 0.966, 0.960),
                blockquote: rgb(0.44, 0.44, 0.47),
                listMarker: rgb(0.50, 0.50, 0.53),
                horizontalRule: rgb(0.80, 0.80, 0.82),
                syntaxMarker: rgb(0.66, 0.66, 0.68),
                taskChecked: rgb(0.24, 0.54, 0.32),
                selection: rgb(0.28, 0.52, 0.88, alpha: 0.22)
            )
        }
    }

    private func adjusted(for syntaxMode: SyntaxHighlightMode) -> EditorColorsNS {
        switch syntaxMode {
        case .full:
            return self
        case .subtle:
            let faintMarker = blend(text, toward: background, amount: 0.78)
            return EditorColorsNS(
                background: background,
                text: text,
                heading: heading,
                bold: text,
                italic: text,
                link: link,
                code: blend(text, toward: code, amount: 0.12),
                codeBlockBackground: codeBlockBackground,
                blockquote: blend(text, toward: blockquote, amount: 0.35),
                listMarker: faintMarker,
                horizontalRule: blend(text, toward: background, amount: 0.88),
                syntaxMarker: faintMarker,
                taskChecked: taskChecked,
                selection: selection
            )
        case .off:
            return EditorColorsNS(
                background: background,
                text: text,
                heading: text,
                bold: text,
                italic: text,
                link: text,
                code: text,
                codeBlockBackground: background,
                blockquote: text,
                listMarker: text,
                horizontalRule: horizontalRule,
                syntaxMarker: text,
                taskChecked: text,
                selection: selection
            )
        }
    }

    private static func rgb(_ red: CGFloat, _ green: CGFloat, _ blue: CGFloat, alpha: CGFloat = 1) -> NSColor {
        EditorColorFactory.rgb(red: red, green: green, blue: blue, alpha: alpha)
    }

    private func blend(_ base: NSColor, toward other: NSColor, amount: CGFloat) -> NSColor {
        let left = base.editorFixed
        let right = other.editorFixed
        let ratio = min(max(amount, 0), 1)
        return EditorColorFactory.rgb(
            red: left.redComponent + (right.redComponent - left.redComponent) * ratio,
            green: left.greenComponent + (right.greenComponent - left.greenComponent) * ratio,
            blue: left.blueComponent + (right.blueComponent - left.blueComponent) * ratio
        )
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

    static func colors(
        for scheme: ColorScheme,
        theme: ColorTheme = .classic,
        syntaxMode: SyntaxHighlightMode = .subtle
    ) -> EditorColors {
        let native = EditorColorsNS.colors(for: scheme, theme: theme, syntaxMode: syntaxMode)
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
            selection: Color(nsColor: native.selection)
        )
    }
}
