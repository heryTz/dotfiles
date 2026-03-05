# Plasma Background Brand Post Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Replace the `tahoe.webp` file reference in `add_title_post` with a fully generated plasma+CLUT background that captures the deep blue-purple glass aesthetic.

**Architecture:** Remove the `tahoe` local variable and the `magick "$tahoe" -resize ...` call. Replace with a plasma generation pipeline: fractal plasma → blur → CLUT remap to tahoe palette → second blur. The CLUT is built inline as a 1×5 gradient strip. No external file dependency.

**Tech Stack:** Bash, ImageMagick (`magick` CLI)

---

### Task 1: Replace bg generation with plasma+CLUT pipeline

**Files:**
- Modify: `branding/lib.sh` (function `add_title_post`, bg section ~lines 143-154)

**Step 1: Read the current state of the function**

```bash
sed -n '130,160p' ~/.config/branding/lib.sh
```

Confirm you can see the `tahoe` local and the `magick "$tahoe" -resize ...` block.

**Step 2: Remove the `tahoe` local variable**

Find and remove these two lines (around line 143-144):
```bash
local tahoe
tahoe="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/tahoe.webp"
```

**Step 3: Replace the bg magick call**

Find:
```bash
# tahoe.webp background — scale and center-crop to canvas
magick "$tahoe" \
  -resize "${w}x${h}^" -gravity center -extent "${w}x${h}" \
  "$tmp_bg" || { return 1; }
```

Replace with:
```bash
# Plasma background inspired by macOS Tahoe — deep blue-purple fluid aesthetic
local tmp_clut
tmp_clut=$(mktemp /tmp/clut_XXXXXX.png)
trap 'rm -f "$tmp_bg" "$tmp_bg_blur" "$tmp_card" "$tmp_text" "$tmp_clut"' RETURN

magick -size 1x5 gradient: \
  \( -clone 0 -fill "#050a20" -colorize 100 \) \
  \( -clone 0 -fill "#0d1a5a" -colorize 100 \) \
  \( -clone 0 -fill "#1a2fa0" -colorize 100 \) \
  \( -clone 0 -fill "#3a14aa" -colorize 100 \) \
  \( -clone 0 -fill "#7a40d8" -colorize 100 \) \
  -delete 0 -append \
  -resize 1x256\! \
  "$tmp_clut" || { return 1; }

magick -size "${w}x${h}" plasma:fractal \
  -blur 0x8 \
  "$tmp_clut" -clut \
  -blur 0x4 \
  "$tmp_bg" || { return 1; }

rm -f "$tmp_clut"
```

**Step 4: Test the output**

```bash
~/.config/branding/brand-post --no-open -o /tmp/post_plasma.png "Glass card test"
```

Verify:
```bash
ls -lh /tmp/post_plasma.png
```

Expected: file created, no errors. Run a second time to confirm the bg varies between runs (plasma is random).

```bash
~/.config/branding/brand-post --no-open -o /tmp/post_plasma2.png "Glass card test"
```

The two files should differ in size slightly (different plasma noise).

**Step 5: Commit**

```bash
git -C ~/.config add branding/lib.sh
git -C ~/.config commit -m "$(cat <<'EOF'
feat: generate plasma+CLUT background inspired by Tahoe aesthetic

Replace tahoe.webp file reference with a generated plasma background
remapped to a deep blue-purple CLUT. No external file dependency.

Co-Authored-By: Claude Sonnet 4.6 <noreply@anthropic.com>
EOF
)"
```
