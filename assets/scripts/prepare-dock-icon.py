#!/usr/bin/env python3
"""Prepare a macOS / Electron dock icon (full-bleed, opaque).

For Electron `app.dock.setIcon()` the PNG must:
- Fill the entire 1024×1024 canvas (no transparent margins)
- Use an opaque background edge-to-edge (macOS rounds corners itself)
- Keep artwork large enough to read in the Dock

Do NOT pre-apply a squircle alpha mask for dock icons — transparent corners
render as a dark square in Electron.

Usage:
    prepare-dock-icon.py input.png output.png
    prepare-dock-icon.py input.png output.png --fill-percent 100
"""

from __future__ import annotations

import argparse
import sys
from pathlib import Path

from PIL import Image

CANVAS = 1024
# Match the macOS Dock background so a full-bleed square icon blends in.
BACKGROUND = (0, 0, 0)


def prepare_dock_icon(source_path: Path, output_path: Path, fill_percent: int) -> None:
    source = Image.open(source_path).convert("RGBA")
    if source.size != (CANVAS, CANVAS):
        source = source.resize((CANVAS, CANVAS), Image.Resampling.LANCZOS)

    fill = int(CANVAS * fill_percent / 100)
    artwork = source.resize((fill, fill), Image.Resampling.LANCZOS)

    canvas = Image.new("RGB", (CANVAS, CANVAS), BACKGROUND)
    offset = (CANVAS - fill) // 2

    # Composite RGBA artwork over the dark plate (ignore prior outer padding).
    plate = Image.new("RGBA", (CANVAS, CANVAS), (*BACKGROUND, 255))
    plate.paste(artwork, (offset, offset), artwork)
    canvas = plate.convert("RGB")

    output_path.parent.mkdir(parents=True, exist_ok=True)
    canvas.save(output_path, "PNG")
    print(f"prepared {output_path} (RGB {CANVAS}x{CANVAS}, fill={fill_percent}%)")


def main() -> int:
    parser = argparse.ArgumentParser(description="Prepare full-bleed macOS dock icon.")
    parser.add_argument("input", type=Path)
    parser.add_argument("output", type=Path)
    parser.add_argument("--fill-percent", type=int, default=100)
    args = parser.parse_args()

    if not args.input.is_file():
        print(f"error: input not found: {args.input}", file=sys.stderr)
        return 1

    prepare_dock_icon(args.input, args.output, args.fill_percent)
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
