import AppKit
import Foundation

enum FontFamily: String, Codable, CaseIterable, Identifiable {
    case systemSerif
    case systemMono
    case newYork
    case menlo
    case sfMono

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .systemSerif: "System Serif"
        case .systemMono: "System Mono"
        case .newYork: "New York"
        case .menlo: "Menlo"
        case .sfMono: "SF Mono"
        }
    }

    func nsFont(size: CGFloat) -> NSFont {
        let font: NSFont
        switch self {
        case .systemSerif:
            font = Self.serifFont(size: size)
        case .systemMono:
            font = Self.monoFont(size: size)
        case .newYork:
            if let newYork = NSFont(name: "New York", size: size) {
                font = newYork
            } else {
                font = Self.serifFont(size: size)
            }
        case .menlo:
            if let menlo = NSFont(name: "Menlo", size: size) {
                font = menlo
            } else {
                font = NSFont.monospacedSystemFont(ofSize: size, weight: .regular)
            }
        case .sfMono:
            if let sfMono = NSFont(name: "SF Mono", size: size) {
                font = sfMono
            } else {
                font = NSFont.monospacedSystemFont(ofSize: size, weight: .regular)
            }
        }
        return EditorFont.withCascade(font)
    }

    private static func serifFont(size: CGFloat) -> NSFont {
        for name in ["New York", "Iowan Old Style", "Georgia", "Palatino", "Times New Roman"] {
            if let font = NSFont(name: name, size: size) {
                return font
            }
        }
        if let descriptor = NSFont.systemFont(ofSize: size).fontDescriptor.withDesign(.serif) {
            return NSFont(descriptor: descriptor, size: size) ?? NSFont.systemFont(ofSize: size, weight: .light)
        }
        return NSFont.systemFont(ofSize: size, weight: .light)
    }

    private static func monoFont(size: CGFloat) -> NSFont {
        for name in ["Menlo", "SF Mono", "SFMono-Regular", "Monaco"] {
            if let font = NSFont(name: name, size: size) {
                return font
            }
        }
        return NSFont.monospacedSystemFont(ofSize: size, weight: .regular)
    }
}

struct EditorPreferences: Codable, Equatable {
    var fontFamily: FontFamily
    var fontSize: CGFloat
    var lineHeight: CGFloat
    var columnWidth: CGFloat
    var horizontalMargin: CGFloat
    var appearanceMode: AppearanceMode
    var colorTheme: ColorTheme
    var syntaxHighlightMode: SyntaxHighlightMode
    var centerColumn: Bool
    var showWordCount: Bool
    var showStatusBar: Bool
    var showIntroDemo: Bool

    static let `default` = EditorPreferences(
        fontFamily: .systemMono,
        fontSize: Constants.defaultFontSize,
        lineHeight: Constants.defaultLineHeight,
        columnWidth: Constants.defaultColumnWidth,
        horizontalMargin: Constants.defaultHorizontalMargin,
        appearanceMode: .system,
        colorTheme: .classic,
        syntaxHighlightMode: .subtle,
        centerColumn: true,
        showWordCount: true,
        showStatusBar: true,
        showIntroDemo: true
    )

    private enum CodingKeys: String, CodingKey {
        case fontFamily, fontSize, lineHeight, columnWidth
        case horizontalMargin, appearanceMode, colorTheme, syntaxHighlightMode
        case centerColumn, showWordCount, showStatusBar, showIntroDemo
    }

    init(
        fontFamily: FontFamily,
        fontSize: CGFloat,
        lineHeight: CGFloat,
        columnWidth: CGFloat,
        horizontalMargin: CGFloat,
        appearanceMode: AppearanceMode,
        colorTheme: ColorTheme,
        syntaxHighlightMode: SyntaxHighlightMode,
        centerColumn: Bool,
        showWordCount: Bool,
        showStatusBar: Bool,
        showIntroDemo: Bool = true
    ) {
        self.fontFamily = fontFamily
        self.fontSize = fontSize
        self.lineHeight = lineHeight
        self.columnWidth = columnWidth
        self.horizontalMargin = horizontalMargin
        self.appearanceMode = appearanceMode
        self.colorTheme = colorTheme
        self.syntaxHighlightMode = syntaxHighlightMode
        self.centerColumn = centerColumn
        self.showWordCount = showWordCount
        self.showStatusBar = showStatusBar
        self.showIntroDemo = showIntroDemo
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        fontFamily = try container.decode(FontFamily.self, forKey: .fontFamily)
        fontSize = try container.decode(CGFloat.self, forKey: .fontSize)
        lineHeight = try container.decode(CGFloat.self, forKey: .lineHeight)
        columnWidth = try container.decode(CGFloat.self, forKey: .columnWidth)
        horizontalMargin = try container.decode(CGFloat.self, forKey: .horizontalMargin)
        appearanceMode = try container.decode(AppearanceMode.self, forKey: .appearanceMode)
        colorTheme = try container.decodeIfPresent(ColorTheme.self, forKey: .colorTheme) ?? .classic
        syntaxHighlightMode = try container.decodeIfPresent(
            SyntaxHighlightMode.self,
            forKey: .syntaxHighlightMode
        ) ?? .subtle
        centerColumn = try container.decodeIfPresent(Bool.self, forKey: .centerColumn) ?? true
        showWordCount = try container.decode(Bool.self, forKey: .showWordCount)
        showStatusBar = try container.decode(Bool.self, forKey: .showStatusBar)
        showIntroDemo = try container.decodeIfPresent(Bool.self, forKey: .showIntroDemo) ?? true
    }
}

@MainActor
final class PreferencesStore: ObservableObject {
    static let shared = PreferencesStore()

    @Published var preferences: EditorPreferences {
        didSet {
            save()
            NotificationCenter.default.post(name: .preferencesDidChange, object: nil)
        }
    }

    private let storageKey = "editorPreferences"

    private init() {
        if let data = UserDefaults.standard.data(forKey: storageKey),
           let decoded = try? JSONDecoder().decode(EditorPreferences.self, from: data) {
            preferences = decoded
        } else {
            preferences = .default
        }
    }

    private func save() {
        if let data = try? JSONEncoder().encode(preferences) {
            UserDefaults.standard.set(data, forKey: storageKey)
        }
    }

    func increaseFontSize() {
        let next = min(preferences.fontSize + Constants.fontSizeStep, Constants.maximumFontSize)
        guard next != preferences.fontSize else { return }
        preferences.fontSize = next
    }

    func decreaseFontSize() {
        let next = max(preferences.fontSize - Constants.fontSizeStep, Constants.minimumFontSize)
        guard next != preferences.fontSize else { return }
        preferences.fontSize = next
    }
}
