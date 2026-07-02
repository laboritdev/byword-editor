# LabWord

A fast, elegant, minimalist Markdown editor for macOS by [Laborit](https://laborit.com.br).

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
Sources/          LabWordCore library (MVVM layers)
  App/            App state, commands, scenes
  Editor/         NSTextView editor, syntax highlighting, find/replace
  Preview/        HTML preview
  Preferences/    Minimal settings
  Services/       Document I/O, auto-save, export, session
  Models/         Document and preference models
  Shared/         Constants, extensions, focus mode
Entry/            Thin executable with @main only
Tests/            Swift Testing unit tests for services
Info.plist        Document types for app bundle
.specs/           Spec-driven project docs
```

## Install

### Homebrew

```bash
brew tap laboritdev/tap
brew trust laboritdev/tap
brew install --cask labword
```

If macOS shows **"damaged and can't be opened"**, see [packaging/SIGNING.md](packaging/SIGNING.md). Temporary fix:

```bash
xattr -cr /Applications/LabWord.app
open /Applications/LabWord.app
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
# Output: dist/LabWord-1.0.0-macos-arm64.zip
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

Inside the app: **Help → LabWord Help** (⌘H) shows keyboard shortcuts and `make` commands.

```bash
xcrun swift build
```

For a full macOS app experience (menus, document association, `.app` bundle):

```bash
make release-local
open dist/LabWord.app
```

Or open in Xcode:

```bash
make xcode
```

Select the **LabWord** scheme, then **Product → Run** (⌘R).

## Run (CLI binary)

```bash
xcrun swift run LabWord
```

## Tests

```bash
xcrun swift test
```

Uses [Swift Testing](https://github.com/swiftlang/swift-testing) with `@testable import LabWordCore`.

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
- **LabWordCore**: library target with all application logic
- **LabWord**: executable entry point (`Entry/Entry.swift`)
