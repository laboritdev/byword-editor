# Homebrew tap

Install LabWord from the Laborit tap:

```bash
brew tap laboritdev/tap
brew trust laboritdev/tap
brew install --cask labword
```

| Cask | Description |
|------|-------------|
| `labword` | Minimalist Markdown editor for macOS by Laborit |

Releases from [laboritdev/labword](https://github.com/laboritdev/labword) update `labword` automatically when `HOMEBREW_TAP_TOKEN` is configured in that repository.

Manual tap update:

```bash
cp packaging/homebrew/Casks/labword.rb ../homebrew-tap/Casks/
```
