import AppKit
import SwiftUI

@MainActor
final class FocusModeManager: ObservableObject {
    static let shared = FocusModeManager()

    @Published var isFocusModeEnabled = false

    private init() {}

    func toggle() {
        isFocusModeEnabled.toggle()
        NotificationCenter.default.post(name: .focusModeDidChange, object: nil)
        if isFocusModeEnabled {
            NSApp.keyWindow?.toggleFullScreen(nil)
        } else if NSApp.keyWindow?.styleMask.contains(.fullScreen) == true {
            NSApp.keyWindow?.toggleFullScreen(nil)
        }
    }
}
