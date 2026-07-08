#!/usr/bin/env python3
"""Shape a square icon for macOS Dock / .icns.

macOS ships icon PNGs verbatim — it does not apply a squircle mask for
third-party dock icons. The source must be RGBA with transparent corners
outside Apple's squircle silhouette (radius ~228 px on a 1024 canvas).

Usage:
    shape-macos-icon.py input.png output.png
    shape-macos-icon.py input.png output.png --safe-percent 82
"""

from __future__ import annotations

import argparse
import math
import sys
from pathlib import Path

from PIL import Image, ImageDraw

CANVAS = 1024
RADIUS = 228
SUPERELLIPSE_N = 5


def rounded_rect_mask(size: int, radius: int) -> Image.Image:
    mask = Image.new("L", (size, size), 0)
    ImageDraw.Draw(mask).rounded_rectangle((0, 0, size, size), radius=radius, fill=255)
    return mask


def superellipse_mask(size: int, exponent: float = SUPERELLIPSE_N) -> Image.Image:
    mask = Image.new("L", (size, size), 0)
    pixels = mask.load()
    half = size / 2.0
    for y in range(size):
        ny = abs(y - half + 0.5) / half
        for x in range(size):
            nx = abs(x - half + 0.5) / half
            if nx**exponent + ny**exponent <= 1.0:
                pixels[x, y] = 255
    return mask


def fit_artwork(source: Image.Image, safe_percent: int) -> Image.Image:
    inner = int(CANVAS * safe_percent / 100)
    artwork = source.convert("RGBA")
    if artwork.size != (inner, inner):
        artwork = artwork.resize((inner, inner), Image.Resampling.LANCZOS)

    canvas = Image.new("RGBA", (CANVAS, CANVAS), (0, 0, 0, 0))
    offset = (CANVAS - inner) // 2
    canvas.paste(artwork, (offset, offset), artwork)
    return canvas


def shape_icon(source_path: Path, output_path: Path, safe_percent: int) -> None:
    source = Image.open(source_path)
    if source.size != (CANVAS, CANVAS):
        source = source.resize((CANVAS, CANVAS), Image.Resampling.LANCZOS)

    fitted = fit_artwork(source, safe_percent)
    mask = superellipse_mask(CANVAS)

    shaped = Image.new("RGBA", (CANVAS, CANVAS), (0, 0, 0, 0))
    shaped.paste(fitted, (0, 0), mask)
    output_path.parent.mkdir(parents=True, exist_ok=True)
    shaped.save(output_path, "PNG")
    print(
        f"shaped {output_path} "
        f"(RGBA {CANVAS}x{CANVAS}, safe={safe_percent}%, squircle n={SUPERELLIPSE_N})"
    )


def main() -> int:
    parser = argparse.ArgumentParser(description="Apply macOS squircle mask to an app icon.")
    parser.add_argument("input", type=Path)
    parser.add_argument("output", type=Path)
    parser.add_argument("--safe-percent", type=int, default=82)
    args = parser.parse_args()

    if not args.input.is_file():
        print(f"error: input not found: {args.input}", file=sys.stderr)
        return 1

    shape_icon(args.input, args.output, args.safe_percent)
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
