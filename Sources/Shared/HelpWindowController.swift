import AppKit
import SwiftUI

@MainActor
final class HelpWindowController: NSWindowController, NSWindowDelegate {
    static let shared = HelpWindowController()

    private init() {
        let window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 480, height: 520),
            styleMask: [.titled, .closable, .resizable],
            backing: .buffered,
            defer: false
        )
        window.title = "\(Constants.appName) Help"
        window.isReleasedWhenClosed = false
        super.init(window: window)
        window.delegate = self
        contentViewController = NSHostingController(rootView: HelpView())
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        nil
    }

    func present() {
        guard let window else { return }
        window.center()
        showWindow(nil)
        window.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
    }
}
