# BywordEditor

**Vision:** A fast, elegant, minimalist Markdown editor for macOS where text is the sole focus.
**For:** Writers who want distraction-free local Markdown editing.
**Solves:** Bloated note apps and IDEs that distract from pure writing.

## Goals

- Open and edit local `.md`, `.markdown`, `.txt` files with near-instant startup
- Transparent auto-save with crash recovery and session restoration
- Native macOS feel with NSTextView-based editing and minimal UI chrome

## Tech Stack

**Core:**

- Platform: macOS 14+
- Language: Swift 6
- UI: SwiftUI + AppKit (NSTextView)
- Build: Swift Package Manager

**Key dependencies:**

- swift-markdown (preview and export)

## Scope

**v1 includes:**

- Local file editing with open/save/save-as/duplicate/move/rename
- Auto-save, session restore, crash recovery
- Markdown syntax highlighting (non-WYSIWYG)
- Optional HTML preview, find/replace, export (PDF/HTML/RTF), print
- Typography preferences, themes, focus mode, statistics

**Explicitly out of scope:**

- Note libraries, databases, cloud sync, Git, AI, plugins, collaboration

## Constraints

- MVVM architecture with clean separation
- No force unwraps, no warnings
- Unit tests for services
