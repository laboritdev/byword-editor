import AppKit
import SwiftUI

@MainActor
enum EditorAppearance {
    static func resolvedColorScheme(
        appearanceMode: AppearanceMode,
        environment: ColorScheme
    ) -> ColorScheme {
        switch appearanceMode {
        case .light:
            return .light
        case .dark:
            return .dark
        case .system:
            return isDarkEffectiveAppearance ? .dark : .light
        }
    }

    static var isDarkEffectiveAppearance: Bool {
        Self.isDark(NSApp.effectiveAppearance)
    }

    nonisolated static func isDark(_ appearance: NSAppearance) -> Bool {
        appearance.bestMatch(from: [.darkAqua, .aqua]) == .darkAqua
    }
}
