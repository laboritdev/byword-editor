import BywordEditorCore
import SwiftUI

@main
struct BywordEditorApp: App {
    @StateObject private var appState = AppState()
    @NSApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate

    var body: some Scene {
        BywordEditorScenes(appState: appState, appDelegate: appDelegate)
    }
}
