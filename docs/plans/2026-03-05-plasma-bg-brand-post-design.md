# Design: Plasma Background for Brand Post

## Overview

Replace the `tahoe.webp` file reference in `add_title_post` with a fully generated plasma background that captures the deep blue-purple glass aesthetic of the Tahoe wallpaper.

## Background Generation

Pipeline:
1. `magick -size 1200x630 plasma:fractal` — fractal noise across full color range
2. `-blur 0x8` — soften into flowing bands
3. Apply a 1×256 CLUT gradient mapping plasma luminance to tahoe palette:
   - `#050a20` (deep near-black navy)
   - `#0d1a5a` (dark navy)
   - `#1a2fa0` (royal blue)
   - `#3a14aa` (blue-purple)
   - `#7a40d8` (light purple highlight)
4. `-blur 0x4` — final blend into silky waves

Each run produces a unique fluid texture. No external file dependency.

## Unchanged

- Glass card (blur-behind, dark tint, white border)
- White text
- Branding pill

## Files Changed

- `branding/lib.sh` — bg generation block in `add_title_post` only
