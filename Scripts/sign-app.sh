#!/usr/bin/env bash
set -euo pipefail

APP_BUNDLE="${1:?Usage: $0 <path-to.app>}"
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
ENTITLEMENTS="$ROOT/packaging/entitlements/BywordEditor.entitlements"

if [[ ! -d "$APP_BUNDLE" ]]; then
  echo "error: app bundle not found at $APP_BUNDLE" >&2
  exit 1
fi

resolve_sign_identity() {
  if [[ -n "${CODESIGN_IDENTITY:-}" ]]; then
    echo "$CODESIGN_IDENTITY"
    return
  fi

  security find-identity -v -p codesigning 2>/dev/null \
    | awk -F'"' '/Developer ID Application/ { print $2; exit }'
}

SIGN_IDENTITY="$(resolve_sign_identity || true)"

if [[ -n "$SIGN_IDENTITY" ]]; then
  echo "Signing with Developer ID: $SIGN_IDENTITY"
  codesign --force --deep --timestamp --options runtime \
    --entitlements "$ENTITLEMENTS" \
    --sign "$SIGN_IDENTITY" \
    "$APP_BUNDLE"
else
  echo "No Developer ID certificate found; applying ad-hoc signature."
  echo "Users will still need to bypass Gatekeeper until the app is notarized."
  codesign --force --deep --sign - "$APP_BUNDLE"
fi

codesign --verify --verbose=2 "$APP_BUNDLE"

if [[ -n "$SIGN_IDENTITY" \
   && -n "${APPLE_ID:-}" \
   && -n "${APPLE_APP_SPECIFIC_PASSWORD:-}" \
   && -n "${APPLE_TEAM_ID:-}" ]]; then
  ZIP_PATH="${APP_BUNDLE}.zip"
  echo "Submitting for Apple notarization…"
  ditto -c -k --keepParent "$APP_BUNDLE" "$ZIP_PATH"
  xcrun notarytool submit "$ZIP_PATH" \
    --apple-id "$APPLE_ID" \
    --password "$APPLE_APP_SPECIFIC_PASSWORD" \
    --team-id "$APPLE_TEAM_ID" \
    --wait
  xcrun stapler staple "$APP_BUNDLE"
  rm -f "$ZIP_PATH"
  echo "Notarization complete."
fi

spctl --assess --type execute --verbose=4 "$APP_BUNDLE" || true
