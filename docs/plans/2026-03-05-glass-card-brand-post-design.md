# Design: Glass Card Brand Post

## Overview

Update `brand-post` to use the real `tahoe.webp` wallpaper as the background and replace the solid white card with a bold glassmorphism panel that blurs and tints the wallpaper behind it.

## Background

Replace the generated Shepards gradient in `add_title_post` with `tahoe.webp` scaled and center-cropped to 1200×630. The same image is used in `add_gradient_bg` (brand-screenshot), which remains unchanged for now.

## Glass Card

Current: white fill, `#d5daea` 1px stroke.

New pipeline:
1. Scale `tahoe.webp` to 1200×630 → `tmp_bg`
2. Create a blurred copy of `tmp_bg` (`-blur 0x18`) → `tmp_bg_blur`
3. Mask-crop `tmp_bg_blur` to the card shape (1040×450, r=20 rounded rect) → blurred card backing
4. Overlay `rgba(5,15,40,0.58)` dark tint on the blurred backing
5. Stroke border: `rgba(255,255,255,0.20)` 1px

## Text

Flip title color from `#0d1b2a` (dark navy) to white (`#ffffff`). The dark glass card requires light text for contrast.

## Branding Pill

No change. The existing `rgba(0,0,0,0.42)` pill with white text already reads well on a dark background.

## Files Changed

- `branding/lib.sh` — `add_title_post` function only
