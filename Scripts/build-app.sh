#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
APP_NAME="LabWord"
EXECUTABLE_NAME="LabWord"
VERSION="${1:-$(tr -d '[:space:]' < "$ROOT/VERSION")}"
ARCH="${2:-$(uname -m)}"
DIST_DIR="$ROOT/dist"
APP_BUNDLE="$DIST_DIR/${APP_NAME}.app"
APP_SLUG="LabWord"

cd "$ROOT"

echo "Building ${APP_NAME} ${VERSION} (${ARCH})…"

xcrun swift build -c release --product LabWord

BIN_DIR="$(xcrun swift build -c release --product LabWord --show-bin-path)"
BINARY="$BIN_DIR/${EXECUTABLE_NAME}"

if [[ ! -f "$BINARY" ]]; then
  echo "error: binary not found at $BINARY" >&2
  exit 1
fi

rm -rf "$APP_BUNDLE"
mkdir -p "$APP_BUNDLE/Contents/MacOS"
mkdir -p "$APP_BUNDLE/Contents/Resources"

cp "$ROOT/Info.plist" "$APP_BUNDLE/Contents/Info.plist"
/usr/libexec/PlistBuddy -c "Set :CFBundleShortVersionString ${VERSION}" "$APP_BUNDLE/Contents/Info.plist"
/usr/libexec/PlistBuddy -c "Set :CFBundleVersion ${VERSION}" "$APP_BUNDLE/Contents/Info.plist"

GIT_SHA="$(git -C "$ROOT" rev-parse --short HEAD 2>/dev/null || echo unknown)"
/usr/libexec/PlistBuddy -c "Set :LabWordGitRevision ${GIT_SHA}" "$APP_BUNDLE/Contents/Info.plist"

cp "$BINARY" "$APP_BUNDLE/Contents/MacOS/${EXECUTABLE_NAME}"
chmod +x "$APP_BUNDLE/Contents/MacOS/${EXECUTABLE_NAME}"

ICONSET="$ROOT/Resources/AppIcon.iconset"
ICNS="$ROOT/Resources/AppIcon.icns"
if [[ -d "$ICONSET" ]]; then
  iconutil --convert icns --output "$ICNS" "$ICONSET"
  cp "$ICNS" "$APP_BUNDLE/Contents/Resources/"
fi

chmod +x "$ROOT/Scripts/sign-app.sh"
"$ROOT/Scripts/sign-app.sh" "$APP_BUNDLE"

ZIP_NAME="${APP_SLUG}-${VERSION}-macos-${ARCH}.zip"
ZIP_PATH="$DIST_DIR/${ZIP_NAME}"

rm -f "$ZIP_PATH"
ditto -c -k --sequesterRsrc --keepParent "$APP_BUNDLE" "$ZIP_PATH"

SHA256="$(shasum -a 256 "$ZIP_PATH" | awk '{print $1}')"

echo ""
echo "Built: $ZIP_PATH"
echo "SHA256: $SHA256"
echo "$SHA256" > "$DIST_DIR/${ZIP_NAME}.sha256"
