import Foundation

struct HelpShortcut: Identifiable, Equatable {
    let id = UUID()
    let action: String
    let shortcut: String
}

enum HelpReference {
    static let appSections: [(title: String, shortcuts: [HelpShortcut])] = [
        (
            "File",
            [
                HelpShortcut(action: "New Document", shortcut: "⌘N"),
                HelpShortcut(action: "Open…", shortcut: "⌘O"),
                HelpShortcut(action: "Save", shortcut: "⌘S"),
                HelpShortcut(action: "Save As…", shortcut: "⇧⌘S"),
                HelpShortcut(action: "Print…", shortcut: "⌘P"),
            ]
        ),
        (
            "Edit",
            [
                HelpShortcut(action: "Undo", shortcut: "⌘Z"),
                HelpShortcut(action: "Redo", shortcut: "⇧⌘Z"),
                HelpShortcut(action: "Find…", shortcut: "⌘F"),
                HelpShortcut(action: "Find Next", shortcut: "⌘G"),
                HelpShortcut(action: "Find Previous", shortcut: "⇧⌘G"),
            ]
        ),
        (
            "View",
            [
                HelpShortcut(action: "Toggle Preview", shortcut: "⌥⌘P"),
                HelpShortcut(action: "Focus Mode", shortcut: "⌃⌘F"),
                HelpShortcut(action: "Preferences…", shortcut: "⌘,"),
            ]
        ),
    ]

    static let developerCommands: [(command: String, description: String)] = [
        ("make help", "List all developer commands"),
        ("make run", "Build and launch the app"),
        ("make build", "Compile the project"),
        ("make test", "Run unit tests"),
        ("make xcode", "Open in Xcode for debugging"),
        ("make clean", "Remove build artifacts"),
    ]
}
