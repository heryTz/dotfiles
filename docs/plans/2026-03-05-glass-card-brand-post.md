# Glass Card Brand Post Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Update `add_title_post` in `branding/lib.sh` to use the real `tahoe.webp` as the background and replace the white card with a blur-behind glassmorphism panel with dark tint and white text.

**Architecture:** The `add_title_post` function in `lib.sh` builds the image in three layers: background, card, text. We replace the Shepards gradient with a resized `tahoe.webp`, then replace the white card with a blurred+tinted crop of the background masked to the card shape.

**Tech Stack:** Bash, ImageMagick (`magick` CLI)

---

### Task 1: Capture baseline output

**Files:**
- Read: `branding/lib.sh:130-181`

**Step 1: Generate current output to compare against**

```bash
~/.config/branding/brand-post --no-open -o /tmp/post_before.png "Glass card test"
```

Expected: A PNG saved at `/tmp/post_before.png` with a flat blue gradient bg and white card.

**Step 2: Open to confirm baseline**

```bash
swappy -f /tmp/post_before.png
```

---

### Task 2: Replace gradient background with tahoe.webp

**Files:**
- Modify: `branding/lib.sh:148-154`

**Step 1: Locate the bg generation block**

In `add_title_post`, find this section (around line 148):

```bash
# macOS Tahoe gradient background
local hw=$((w / 2)) hh=$((h / 2))
magick -size "${w}x${h}" xc: \
  -sparse-color Shepards \
    "0,0 #e8f4fc  ${w},0 #b3d9f0  ${hw},0 #6ab8e4  ${hw},${hh} #3a9acf  0,${h} #1e7ab5  ${w},${h} #0d5a8a" \
  -blur 0x50 \
  "$tmp_bg" || { return 1; }
```

**Step 2: Replace with tahoe.webp resize**

Replace the block above with:

```bash
# tahoe.webp background — scale and center-crop to canvas
local tahoe="$DIR/tahoe.webp"
magick "$tahoe" \
  -resize "${w}x${h}^" -gravity center -extent "${w}x${h}" \
  "$tmp_bg" || { return 1; }
```

Note: `$DIR` is already defined at the top of `brand-post` but NOT in `lib.sh`. The `add_title_post` function does not know its own file location. Pass the branding dir path instead by adding a local at the top of the function:

```bash
local tahoe
tahoe="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/tahoe.webp"
```

Add this line right after `local tmp_bg tmp_card tmp_text` near line 142.

**Step 3: Verify bg change only**

```bash
~/.config/branding/brand-post --no-open -o /tmp/post_bg.png "Glass card test"
```

Expected: tahoe.webp fills the background; card still white.

---

### Task 3: Replace white card with blur-behind glass panel

**Files:**
- Modify: `branding/lib.sh:156-162`

**Step 1: Add `tmp_bg_blur` to the temp file declarations**

Find the temp var block (~line 142):
```bash
local tmp_bg tmp_card tmp_text
```
Change to:
```bash
local tmp_bg tmp_bg_blur tmp_card tmp_text
```

And in the mktemp lines below, add:
```bash
tmp_bg_blur=$(mktemp /tmp/bg_blur_XXXXXX.png)
```

And add `"$tmp_bg_blur"` to the trap cleanup line:
```bash
trap 'rm -f "$tmp_bg" "$tmp_bg_blur" "$tmp_card" "$tmp_text"' RETURN
```

**Step 2: Replace white card generation block**

Find (~line 156):
```bash
# White card with subtle border and rounded corners
magick -size "${card_w}x${card_h}" xc:none \
  -fill white \
  -stroke "#d5daea" \
  -strokewidth 1 \
  -draw "roundrectangle 0,0 $((card_w - 1)),$((card_h - 1)) ${card_r},${card_r}" \
  "$tmp_card" || { return 1; }
```

Replace with this three-step glass panel pipeline:

```bash
# Glass card: blur the bg, crop to card shape, overlay dark tint + border
magick "$tmp_bg" -blur 0x18 "$tmp_bg_blur" || { return 1; }

magick "$tmp_bg_blur" \
  -gravity center \
  -crop "${card_w}x${card_h}+0+0" +repage \
  \( +clone -alpha extract \
     -fill black -colorize 100 \
     -fill white \
     -draw "roundrectangle 0,0 $((card_w - 1)),$((card_h - 1)) ${card_r},${card_r}" \
  \) \
  -alpha off -compose CopyOpacity -composite \
  \( -clone 0 \
     -fill "rgba(5,15,40,0.58)" \
     -draw "roundrectangle 0,0 $((card_w - 1)),$((card_h - 1)) ${card_r},${card_r}" \
  \) \
  -compose Over -composite \
  -fill none \
  -stroke "rgba(255,255,255,0.20)" \
  -strokewidth 1 \
  -draw "roundrectangle 0,0 $((card_w - 1)),$((card_h - 1)) ${card_r},${card_r}" \
  "$tmp_card" || { return 1; }
```

**Step 3: Test output with glass card**

```bash
~/.config/branding/brand-post --no-open -o /tmp/post_glass.png "Glass card test"
```

Expected: tahoe.webp bg, dark glassy card in center, white card still shows old text color (dark navy — not yet fixed).

---

### Task 4: Flip text color to white

**Files:**
- Modify: `branding/lib.sh:164-172`

**Step 1: Find text color**

Locate (~line 168):
```bash
-fill "#0d1b2a" \
```

**Step 2: Change to white**

```bash
-fill "#ffffff" \
```

**Step 3: Verify final output**

```bash
~/.config/branding/brand-post --no-open -o /tmp/post_final.png "Glass card test"
```

Expected: tahoe.webp bg, dark glass card, white title text, branding pill unchanged.

Open and inspect:
```bash
swappy -f /tmp/post_final.png
```

---

### Task 5: Commit

**Step 1: Stage and commit**

```bash
git -C ~/.config add branding/lib.sh
git -C ~/.config commit -m "$(cat <<'EOF'
feat: glass card brand-post with tahoe.webp background

Replace flat Shepards gradient with real tahoe.webp and swap the
white card for a blur-behind dark-tinted glassmorphism panel.

Co-Authored-By: Claude Sonnet 4.6 <noreply@anthropic.com>
EOF
)"
```
