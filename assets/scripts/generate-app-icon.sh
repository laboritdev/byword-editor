#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
SOURCE="${1:-$ROOT/source/text-by-laborit-icon-1024.png}"
FILL_PERCENT="${2:-92}"
ICONSET="$ROOT/icons/AppIcon.iconset"
APPICONSET="$ROOT/icons/AppIcon.appiconset"
MASTER="$ROOT/source/app-icon-master-1024.png"
DOCK="$ROOT/icons/AppIcon-dock.png"
DESKTOP_ICONS="$(cd "$ROOT/../apps/desktop/resources/icons" && pwd)"
PREPARE_SCRIPT="$ROOT/scripts/prepare-dock-icon.py"
VENV="${TMPDIR:-/tmp}/labword-icon-venv"

if [[ ! -f "$SOURCE" ]]; then
  echo "error: source icon not found at $SOURCE" >&2
  exit 1
fi

if [[ ! -x "$VENV/bin/python3" ]]; then
  python3 -m venv "$VENV"
  "$VENV/bin/pip" install pillow -q
fi

echo "Preparing full-bleed dock icon (fill ${FILL_PERCENT}%)..."
"$VENV/bin/python3" "$PREPARE_SCRIPT" "$SOURCE" "$DOCK" --fill-percent "$FILL_PERCENT"
cp "$DOCK" "$MASTER"

mkdir -p "$ICONSET" "$APPICONSET"

write_icon() {
  local name="$1"
  local size="$2"
  sips -s format png -z "$size" "$size" "$MASTER" --out "$ICONSET/$name" >/dev/null
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

iconutil --convert icns --output "$ROOT/icons/AppIcon.icns" "$ICONSET"
cp "$MASTER" "$ROOT/icons/AppIcon.png"

for dest in "$DESKTOP_ICONS" "$(cd "$ROOT/.." && pwd)/Resources"; do
  mkdir -p "$dest"
  cp -R "$ICONSET" "$dest/AppIcon.iconset"
  cp -R "$APPICONSET" "$dest/AppIcon.appiconset"
  cp "$ROOT/icons/AppIcon.icns" "$dest/AppIcon.icns"
  cp "$MASTER" "$dest/AppIcon.png"
  cp "$DOCK" "$dest/AppIcon-dock.png"
done

WEB_PUBLIC="$(cd "$ROOT/../apps/web/public" && pwd)"
sips -s format png -z 32 32 "$MASTER" --out "$WEB_PUBLIC/favicon.png" >/dev/null
sips -s format png -z 180 180 "$MASTER" --out "$WEB_PUBLIC/apple-touch-icon.png" >/dev/null

cp "$MASTER" "$ROOT/../packaging/icon/app-icon-master-1024.png"

echo "Updated:"
echo "  $MASTER"
echo "  $DOCK"
echo "  $ROOT/icons/AppIcon.icns"
