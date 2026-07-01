# BywordEditor

A fast, elegant, minimalist Markdown editor for macOS inspired by the Byword philosophy.

## Philosophy

- Text is the protagonist
- Local Markdown files only
- No databases, sync, AI, plugins, or workspace features
- Transparent auto-save and session recovery
- Native macOS experience with NSTextView

## Requirements

- macOS 14+
- Swift 6 toolchain (Xcode 16+ recommended for running the GUI)

## Project layout

```
Sources/          BywordEditorCore library (MVVM layers)
  App/            App state, commands, scenes
  Editor/         NSTextView editor, syntax highlighting, find/replace
  Preview/        HTML preview
  Preferences/    Minimal settings
  Services/       Document I/O, auto-save, export, session
  Models/         Document and preference models
  Shared/         Constants, extensions, focus mode
Entry/            Thin executable with @main only
Tests/            Swift Testing unit tests for services
Info.plist        Document types for Xcode app bundle
.specs/           Spec-driven project docs
```

## Install

### Homebrew (recommended)

```bash
brew tap laboritdev/tap
brew trust laboritdev/tap
brew install --cask byword-editor
```

If macOS shows **"damaged and can't be opened"**, the build is not yet notarized. See [packaging/SIGNING.md](packaging/SIGNING.md). Temporary fix:

```bash
xattr -cr /Applications/BywordEditor.app
open /Applications/BywordEditor.app
```

## Release (maintainers)

1. Bump `VERSION` and `Info.plist` if needed
2. Commit and push to `main`
3. Create and push a tag:

```bash
git tag v1.0.0
git push origin v1.0.0
```

GitHub Actions builds the `.app`, uploads the zip to Releases, and updates the Homebrew cask (if `HOMEBREW_TAP_TOKEN` is configured).

Local release build:

```bash
make release-local VERSION=1.0.0
# Output: dist/BywordEditor-1.0.0-macos-arm64.zip
```

## Build (development)

```bash
make help     # list all developer commands
make run      # build and launch the app
make build    # compile only
make test     # run unit tests
make xcode    # open in Xcode
make clean    # remove build artifacts
```

Inside the app: **Help → BywordEditor Help** (⌘H) shows keyboard shortcuts and `make` commands.

```bash
xcrun swift build
```

The CLI build produces a command-line binary. For a full macOS app experience (menus, document association, `.app` bundle), use Xcode:

```bash
open Package.swift
```

In Xcode: select the **BywordEditor** scheme, then **Product → Run** (⌘R).

To attach document types and bundle metadata, add `Info.plist` to the executable target in Xcode (File → New → File from `Info.plist` at the repo root).

## Run (CLI binary)

```bash
xcrun swift run BywordEditor
```

## Tests

```bash
xcrun swift test
```

Uses [Swift Testing](https://github.com/swiftlang/swift-testing) with `@testable import BywordEditorCore`.

## Features

- `.md`, `.markdown`, `.txt` support
- Open via File menu, drag & drop, Finder, recent files
- Auto-save on idle, focus loss, and close
- Crash recovery with cursor and scroll restoration
- Markdown syntax highlighting (non-WYSIWYG)
- Optional HTML preview
- Find / replace with case, whole word, and regex
- Export to PDF, HTML, RTF
- Native print support
- Light / dark / system themes
- Focus mode
- Word count and reading time statistics

## Architecture

- **MVVM**: Views, ViewModels, Services, Models
- **BywordEditorCore**: library target with all application logic
- **BywordEditor**: executable entry point (`Entry/Entry.swift`)
