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
        switch self {
        case .systemSerif:
            if let font = NSFont(name: "New York", size: size) {
                return font
            }
            return NSFont.systemFont(ofSize: size, weight: .regular)
        case .systemMono:
            return NSFont.monospacedSystemFont(ofSize: size, weight: .regular)
        case .newYork:
            if let font = NSFont(name: "New York", size: size) {
                return font
            }
            return NSFont.systemFont(ofSize: size, weight: .regular)
        case .menlo:
            if let font = NSFont(name: "Menlo", size: size) {
                return font
            }
            return NSFont.monospacedSystemFont(ofSize: size, weight: .regular)
        case .sfMono:
            if let font = NSFont(name: "SF Mono", size: size) {
                return font
            }
            return NSFont.monospacedSystemFont(ofSize: size, weight: .regular)
        }
    }
}

struct EditorPreferences: Codable, Equatable {
    var fontFamily: FontFamily
    var fontSize: CGFloat
    var lineHeight: CGFloat
    var columnWidth: CGFloat
    var horizontalMargin: CGFloat
    var appearanceMode: AppearanceMode
    var showWordCount: Bool
    var showStatusBar: Bool

    static let `default` = EditorPreferences(
        fontFamily: .systemSerif,
        fontSize: Constants.defaultFontSize,
        lineHeight: Constants.defaultLineHeight,
        columnWidth: Constants.defaultColumnWidth,
        horizontalMargin: Constants.defaultHorizontalMargin,
        appearanceMode: .system,
        showWordCount: true,
        showStatusBar: true
    )

    private enum CodingKeys: String, CodingKey {
        case fontFamily, fontSize, lineHeight, columnWidth
        case horizontalMargin, appearanceMode, showWordCount, showStatusBar
    }

    init(
        fontFamily: FontFamily,
        fontSize: CGFloat,
        lineHeight: CGFloat,
        columnWidth: CGFloat,
        horizontalMargin: CGFloat,
        appearanceMode: AppearanceMode,
        showWordCount: Bool,
        showStatusBar: Bool
    ) {
        self.fontFamily = fontFamily
        self.fontSize = fontSize
        self.lineHeight = lineHeight
        self.columnWidth = columnWidth
        self.horizontalMargin = horizontalMargin
        self.appearanceMode = appearanceMode
        self.showWordCount = showWordCount
        self.showStatusBar = showStatusBar
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        fontFamily = try container.decode(FontFamily.self, forKey: .fontFamily)
        fontSize = try container.decode(CGFloat.self, forKey: .fontSize)
        lineHeight = try container.decode(CGFloat.self, forKey: .lineHeight)
        columnWidth = try container.decode(CGFloat.self, forKey: .columnWidth)
        horizontalMargin = try container.decode(CGFloat.self, forKey: .horizontalMargin)
        appearanceMode = try container.decode(AppearanceMode.self, forKey: .appearanceMode)
        showWordCount = try container.decode(Bool.self, forKey: .showWordCount)
        showStatusBar = try container.decode(Bool.self, forKey: .showStatusBar)
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
}
