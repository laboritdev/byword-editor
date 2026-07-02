import LabWordCore
import SwiftUI

@main
struct LabWordApp: App {
    @StateObject private var appState = AppState()
    @NSApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate

    var body: some Scene {
        LabWordScenes(appState: appState, appDelegate: appDelegate)
    }
}
