#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
APP_BUNDLE="${1:?Usage: $0 <path-to-app-bundle>}"
ENTITLEMENTS="$ROOT/packaging/entitlements/LabWord.entitlements"

if [[ ! -d "$APP_BUNDLE" ]]; then
  echo "error: app bundle not found at $APP_BUNDLE" >&2
  exit 1
fi

IDENTITY="${CODESIGN_IDENTITY:--}"

if [[ "$IDENTITY" == "-" ]]; then
  echo "Signing ad-hoc (no CODESIGN_IDENTITY set)…"
  codesign --force --deep --sign - "$APP_BUNDLE"
else
  echo "Signing with identity: $IDENTITY"
  if [[ -f "$ENTITLEMENTS" ]]; then
    codesign --force --deep --sign "$IDENTITY" --entitlements "$ENTITLEMENTS" --options runtime "$APP_BUNDLE"
  else
    codesign --force --deep --sign "$IDENTITY" --options runtime "$APP_BUNDLE"
  fi
fi

codesign --verify --deep --strict --verbose=2 "$APP_BUNDLE" || true
spctl --assess --type execute --verbose=4 "$APP_BUNDLE" || true
