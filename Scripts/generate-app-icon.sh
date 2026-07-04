#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
SOURCE="${1:-$ROOT/packaging/icon/text-by-laborit-icon-1024.png}"
ZOOM_PERCENT="${2:-130}"
ICONSET="$ROOT/Resources/AppIcon.iconset"
APPICONSET="$ROOT/Resources/AppIcon.appiconset"
MASTER="$ROOT/packaging/icon/app-icon-master-1024.png"
WORK="$(mktemp -d)"

cleanup() { rm -rf "$WORK"; }
trap cleanup EXIT

if [[ ! -f "$SOURCE" ]]; then
  echo "error: source icon not found at $SOURCE" >&2
  exit 1
fi

echo "Generating square app icon (zoom ${ZOOM_PERCENT}%) from ${SOURCE}..."

sips -c 1024 1024 "$SOURCE" --out "$WORK/base.png" >/dev/null
ZOOMED_SIZE=$((1024 * ZOOM_PERCENT / 100))
sips -z "$ZOOMED_SIZE" "$ZOOMED_SIZE" "$WORK/base.png" --out "$WORK/zoomed.png" >/dev/null
sips -c 1024 1024 "$WORK/zoomed.png" --out "$MASTER" >/dev/null

mkdir -p "$ICONSET" "$APPICONSET"

write_icon() {
  local name="$1"
  local size="$2"
  sips -z "$size" "$size" "$MASTER" --out "$ICONSET/$name" >/dev/null
  cp "$ICONSET/$name" "$APPICONSET/$name"
}

write_icon "icon_16x16.png" 16
write_icon "icon_16x16@2x.png" 32
write_icon "icon_32x32.png" 32
write_icon "icon_32x32@2x.png" 64
write_icon "icon_128x128.png" 128
write_icon "icon_128x128@2x.png" 256
write_icon "icon_256x256.png" 256
write_icon "icon_256x256@2x.png" 512
write_icon "icon_512x512.png" 512
write_icon "icon_512x512@2x.png" 1024

iconutil --convert icns --output "$ROOT/Resources/AppIcon.icns" "$ICONSET"

echo "Updated:"
echo "  $MASTER"
echo "  $ICONSET"
echo "  $APPICONSET"
echo "  $ROOT/Resources/AppIcon.icns"
