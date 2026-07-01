# Code signing and notarization

BywordEditor must be **signed** and **notarized** by Apple to install without the "damaged" Gatekeeper error.

## Immediate workaround (unsigned builds)

If you already installed via Homebrew and see **"BywordEditor is damaged"**:

```bash
brew uninstall --cask byword-editor
xattr -cr /Applications/BywordEditor.app   # if the app is still there
```

For a manual download:

```bash
xattr -cr /Applications/BywordEditor.app
open /Applications/BywordEditor.app
```

Or: **System Settings → Privacy & Security → Open Anyway** after the first blocked launch.

This is only acceptable for internal/testing builds.

## Become a recognized Apple developer

1. Enroll in the [Apple Developer Program](https://developer.apple.com/programs/) (**USD 99/year**, org or individual).
2. In [Certificates, Identifiers & Profiles](https://developer.apple.com/account/resources/certificates/list):
   - Create **Developer ID Application** certificate (for apps outside the Mac App Store).
   - Download and install the `.cer` in Keychain Access.
3. Create an **app-specific password** at [appleid.apple.com](https://appleid.apple.com) → Sign-In and Security → App-Specific Passwords.
4. Note your **Team ID** (Apple Developer account → Membership details).

After that, Xcode/macOS will show your name as a verified developer when the app is signed and notarized.

## Local signed + notarized build

```bash
export CODESIGN_IDENTITY="Developer ID Application: Your Name (TEAMID)"
export APPLE_ID="you@company.com"
export APPLE_APP_SPECIFIC_PASSWORD="xxxx-xxxx-xxxx-xxxx"
export APPLE_TEAM_ID="TEAMID"

make release-local VERSION=1.0.1
```

## GitHub Actions (automatic releases)

Add these repository secrets in **laboritdev/byword-editor → Settings → Secrets**:

| Secret | Description |
|--------|-------------|
| `MACOS_BUILD_CERTIFICATE` | Base64-encoded `.p12` export of Developer ID Application cert |
| `MACOS_P12_PASSWORD` | Password used when exporting the `.p12` |
| `APPLE_ID` | Apple ID email |
| `APPLE_APP_PASSWORD` | App-specific password |
| `APPLE_TEAM_ID` | 10-character Team ID |

Export certificate to base64:

```bash
base64 -i Certificates.p12 | pbcopy
```

The release workflow imports the certificate, signs the app, notarizes it, then uploads the zip.

## Re-release after signing is configured

```bash
git tag -d v1.0.1
git push origin :refs/tags/v1.0.1
git tag v1.0.1
git push origin v1.0.1
```

Users then run:

```bash
brew update
brew reinstall --cask byword-editor
```
