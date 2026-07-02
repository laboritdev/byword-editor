# Code signing and notarization

LabWord must be **signed** and **notarized** by Apple to install without the "damaged" Gatekeeper error.

## Quick fix (unsigned builds)

If you already installed via Homebrew and see **"LabWord is damaged"**:

```bash
brew uninstall --cask labword
xattr -cr /Applications/LabWord.app   # if the app is still there
brew install --cask labword
```

Or for a direct download:

```bash
xattr -cr /Applications/LabWord.app
open /Applications/LabWord.app
```

## Apple Developer setup

1. Enroll in the [Apple Developer Program](https://developer.apple.com/programs/)
2. Create a **Developer ID Application** certificate
3. Export as `.p12` for CI

Add these repository secrets in **laboritdev/labword → Settings → Secrets**:

| Secret | Description |
|--------|-------------|
| `MACOS_BUILD_CERTIFICATE` | Base64-encoded `.p12` |
| `MACOS_P12_PASSWORD` | Password for the `.p12` |
| `APPLE_ID` | Apple ID email |
| `APPLE_APP_PASSWORD` | App-specific password |
| `APPLE_TEAM_ID` | Team ID |

## Local signing

```bash
export CODESIGN_IDENTITY="Developer ID Application: Your Name (TEAMID)"
./Scripts/build-app.sh
```

## After notarization is configured

Users can install cleanly:

```bash
brew tap laboritdev/tap
brew install --cask labword
```
