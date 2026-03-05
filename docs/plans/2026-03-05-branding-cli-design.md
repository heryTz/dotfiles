# Branding CLI Design

## Overview

Refactor screenshot branding into a shared library and add a standalone `brand-post` CLI that generates a branded social media post image from a text title.

## Folder Structure

```
~/.config/
  branding/
    lib.sh              # shared functions
    brand-post          # CLI: generates a post image from title text
    brand-screenshot    # CLI: applies branding to a screenshot
  rofi/
    rofi-screenshot     # sources ../branding/lib.sh, calls brand-screenshot
    rofi-screenshot-debug  # sources ../branding/lib.sh
```

## `branding/lib.sh`

Extracted from `rofi/rofi-screenshot`. Exports:

- `round_corners <file>` — rounds image corners to match Hyprland rounding
- `add_gradient_bg <input> <output>` — composites shadow + macOS Tahoe blue gradient bg
- `add_branding <file>` — composites avatar + name pill at bottom-right
- `add_title_post <text> <output>` — generates a 1200×630 branded post image

## `brand-post` CLI

```
brand-post [OPTIONS] "Title text here"
  -o <path>     Output file (default: ~/Pictures/Posts/post_<timestamp>.png)
  --no-open     Skip opening in swappy
```

Behavior:
1. Validates title ≤ 66 chars — **errors and exits** if exceeded
2. Generates 1200×630 blue gradient canvas
3. Renders Inter Bold title, white, centered, multi-line (wraps ~22 chars/line, max 3 lines)
4. Composites avatar + name pill (bottom-right, same as screenshot branding)
5. Opens in swappy for optional edit, saves to output path
6. Sends desktop notification on save

## Visual Layout (1200×630)

```
┌─────────────────────────────────────────┐
│                                         │
│                                         │
│         Title Text Goes Here            │  Inter Bold ~72px, white, centered
│         Wraps to Multiple Lines         │
│                                         │
│                                [● Hery] │  existing branding pill, +12+12
└─────────────────────────────────────────┘
```

- Gradient: identical to `add_gradient_bg` (macOS Tahoe blue palette)
- Title text: white, subtle drop shadow for legibility
- No screenshot window — just gradient + title + branding pill

## `brand-screenshot` CLI

Thin wrapper around `lib.sh` functions:

```
brand-screenshot <input.png> <output.png>
```

Applies `round_corners`, `add_gradient_bg`, `add_branding` in sequence.

## `rofi/rofi-screenshot` Changes

- Sources `../branding/lib.sh` instead of defining functions inline
- Calls `brand-screenshot` for the branded screenshot modes
- No logic changes, just delegation
