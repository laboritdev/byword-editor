import AppKit
import SwiftUI

@MainActor
enum AboutPanel {
    static func show() {
        let alert = NSAlert()
        alert.messageText = Constants.appName
        alert.informativeText = """
        Version \(BuildInfo.fullVersion)

        Minimalist Markdown editor for macOS.
        """
        alert.alertStyle = .informational
        alert.addButton(withTitle: "OK")
        if let icon = NSApp.applicationIconImage {
            alert.icon = icon
        }
        alert.runModal()
    }
}
