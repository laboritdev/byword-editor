# laboritdev/homebrew-tap

Homebrew tap for Laborit macOS applications.

## Usage

```bash
brew tap laboritdev/tap
brew install --cask byword-editor
```

## Available casks

| Cask | Description |
|------|-------------|
| `byword-editor` | Minimalist Markdown editor for macOS |

## Updating casks

Releases from [laboritdev/byword-editor](https://github.com/laboritdev/byword-editor) update `byword-editor` automatically when `HOMEBREW_TAP_TOKEN` is configured in that repository.

Manual update:

```bash
./Scripts/update-homebrew-cask.sh <version> <sha256> arm64
cp packaging/homebrew/Casks/byword-editor.rb ../homebrew-tap/Casks/
```
