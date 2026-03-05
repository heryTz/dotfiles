# Branding CLI Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Refactor screenshot branding into `branding/lib.sh`, add a `brand-post` CLI for generating 1200×630 social media post images, and wire `rofi-screenshot` to use the shared lib.

**Architecture:** Extract the four ImageMagick functions from `rofi/rofi-screenshot` into `branding/lib.sh`. Add a new `add_title_post` function to lib. Create two thin CLI scripts (`brand-post`, `brand-screenshot`) in `branding/`. Update `rofi/rofi-screenshot` and `rofi/rofi-screenshot-debug` to source the lib instead of defining their own functions.

**Tech Stack:** Bash, ImageMagick (`magick`), Inter-Bold font, JetBrainsMono-NF-Bold font, swappy, grim, notify-send.

---

### Task 1: Create `branding/lib.sh` with extracted functions

**Files:**
- Create: `branding/lib.sh`

**Step 1: Create the file**

```bash
mkdir -p ~/.config/branding
```

Create `~/.config/branding/lib.sh` with this exact content:

```bash
#!/usr/bin/env bash

# Round corners of an image in-place to match Hyprland rounding = 6.
# Args: <file.png>
round_corners() {
  local file="$1" r=6
  magick "$file" \
    \( +clone -alpha extract \
       -draw "fill black polygon 0,0 0,$r $r,0 fill white circle $r,$r $r,0" \
       \( +clone -flip \) -compose Multiply -composite \
       \( +clone -flop \) -compose Multiply -composite \
    \) \
    -alpha off -compose CopyOpacity -composite \
    "$file"
}

# Composite a pastel gradient background behind a shadow-padded image.
# Args: <input.png> <output.png>
add_gradient_bg() {
  local input="$1" output="$2"
  local shadowfile
  shadowfile=$(mktemp /tmp/screenshot_XXXXXX.png)

  magick \
    \( "$input" -bordercolor none -border 30 \) \
    \( +clone -background black -shadow 80x20+0+15 \) \
    +swap -background none -layers merge +repage \
    "$shadowfile"

  local sw sh w h hw hh padding=10
  sw=$(magick identify -format "%w" "$shadowfile")
  sh=$(magick identify -format "%h" "$shadowfile")
  w=$((sw + padding * 2))
  h=$((sh + padding * 2))
  hw=$((w / 2))
  hh=$((h / 2))
  magick -size "${w}x${h}" xc: \
    -sparse-color Shepards \
      "0,0 #e8f4fc  ${w},0 #b3d9f0  ${hw},0 #6ab8e4  ${hw},${hh} #3a9acf  0,${h} #1e7ab5  ${w},${h} #0d5a8a" \
    -blur 0x50 \
    "$shadowfile" -gravity center -composite \
    "$output"

  rm "$shadowfile"
}

# Composite a branded signature (circular avatar + name) onto the bottom-right.
# Args: <file.png>
add_branding() {
  local file="$1"
  local avatar_src="$HOME/.config/rofi/profile.png"
  local size=36
  local border=2
  local total=$((size + border * 2))
  local half_t=$((total / 2))
  local half_s=$((size / 2))
  local gap=10  pad_y=12
  local pad_x=$pad_y
  local name="Hery Nirintsoa"  font_size=17

  local tmp_avatar tmp_disc tmp_ring tmp_text tmp_brand
  tmp_avatar=$(mktemp /tmp/av_XXXXXX.png)
  tmp_disc=$(mktemp /tmp/disc_XXXXXX.png)
  tmp_ring=$(mktemp /tmp/ring_XXXXXX.png)
  tmp_text=$(mktemp /tmp/text_XXXXXX.png)
  tmp_brand=$(mktemp /tmp/brand_XXXXXX.png)

  magick "$avatar_src" \
    -resize "${size}x${size}^" -gravity center -extent "${size}x${size}" \
    \( +clone -alpha extract \
       -fill black -colorize 100 \
       -fill white -draw "circle ${half_s},${half_s} ${half_s},0" \
    \) \
    -alpha off -compose CopyOpacity -composite \
    "$tmp_avatar"

  magick -size "${total}x${total}" xc: \
    -sparse-color Shepards \
      "0,0 #c8e8fa  ${total},0 #7ec5ec  0,${total} #4aa8d8  ${total},${total} #2080b8" \
    -blur 0x6 \
    \( +clone -alpha extract \
       -fill black -colorize 100 \
       -fill white -draw "circle ${half_t},${half_t} ${half_t},0" \
    \) \
    -alpha off -compose CopyOpacity -composite \
    "$tmp_disc"

  magick "$tmp_disc" "$tmp_avatar" -gravity center -compose Over -composite "$tmp_ring"
  rm "$tmp_avatar" "$tmp_disc"

  magick -background none -fill white \
    -font "JetBrainsMono-NF-Bold" -pointsize "$font_size" \
    label:"$name" "$tmp_text"
  local text_w text_h
  text_w=$(magick identify -format "%w" "$tmp_text")
  text_h=$(magick identify -format "%h" "$tmp_text")

  local strip_w=$(( pad_x + total + gap + text_w + pad_x ))
  local strip_h=$(( total + pad_y * 2 ))
  local text_x=$(( pad_x + total + gap ))
  local text_y=$(( (strip_h - text_h) / 2 ))
  local pill_r=$(( strip_h / 2 ))

  magick -size "${strip_w}x${strip_h}" xc:none \
    -fill "rgba(0,0,0,0.42)" \
    -draw "roundrectangle 0,0 $((strip_w - 1)),$((strip_h - 1)) ${pill_r},${pill_r}" \
    "$tmp_ring" -geometry "+${pad_x}+${pad_y}" -composite \
    "$tmp_text" -geometry "+${text_x}+${text_y}" -composite \
    "$tmp_brand"
  rm "$tmp_ring" "$tmp_text"

  magick "$file" "$tmp_brand" -gravity SouthEast -geometry "+12+12" -composite "$file"
  rm "$tmp_brand"
}

# Generate a 1200x630 branded post image with centered title text.
# Args: <text> <output.png>
add_title_post() {
  local text="$1" output="$2"
  local w=1200 h=630
  local hw=$((w / 2)) hh=$((h / 2))
  local font_size=72
  local tmp_text tmp_canvas
  tmp_text=$(mktemp /tmp/title_XXXXXX.png)
  tmp_canvas=$(mktemp /tmp/canvas_XXXXXX.png)

  # Gradient canvas
  magick -size "${w}x${h}" xc: \
    -sparse-color Shepards \
      "0,0 #e8f4fc  ${w},0 #b3d9f0  ${hw},0 #6ab8e4  ${hw},${hh} #3a9acf  0,${h} #1e7ab5  ${w},${h} #0d5a8a" \
    -blur 0x50 \
    "$tmp_canvas"

  # Render title text with word-wrap at ~22 chars per line
  # Use pango for proper word-wrap with Inter Bold
  magick -size "$((w - 160))x$((h - 100))" \
    -background none \
    -fill white \
    -font "Inter-Bold" \
    -pointsize "$font_size" \
    -gravity center \
    caption:"$text" \
    "$tmp_text"

  # Composite text onto canvas centered
  magick "$tmp_canvas" "$tmp_text" -gravity center -composite "$output"
  rm "$tmp_text" "$tmp_canvas"

  # Add branding pill
  add_branding "$output"
}
```

**Step 2: Make it non-executable (it's sourced, not run directly)**

```bash
chmod 644 ~/.config/branding/lib.sh
```

**Step 3: Verify the file was created**

```bash
head -5 ~/.config/branding/lib.sh
```
Expected: `#!/usr/bin/env bash`

**Step 4: Commit**

```bash
cd ~/.config
git add branding/lib.sh
git commit -m "feat: add branding/lib.sh with shared ImageMagick functions"
```

---

### Task 2: Create `branding/brand-screenshot` CLI

**Files:**
- Create: `branding/brand-screenshot`

**Step 1: Create the file**

Create `~/.config/branding/brand-screenshot` with this content:

```bash
#!/usr/bin/env bash

set -euo pipefail

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$DIR/lib.sh"

usage() {
  echo "Usage: brand-screenshot <input.png> <output.png>"
  exit 1
}

[[ $# -ne 2 ]] && usage

input="$1"
output="$2"

[[ ! -f "$input" ]] && { echo "Error: input file not found: $input"; exit 1; }

tmpfile=$(mktemp /tmp/screenshot_XXXXXX.png)
cp "$input" "$tmpfile"

round_corners "$tmpfile"
add_gradient_bg "$tmpfile" "$output"
rm "$tmpfile"
add_branding "$output"
```

**Step 2: Make it executable**

```bash
chmod +x ~/.config/branding/brand-screenshot
```

**Step 3: Smoke test with the existing debug screenshot**

```bash
~/.config/branding/brand-screenshot ~/.config/rofi/debug_screenshot.png /tmp/test_brand.png
```
Expected: no errors, `/tmp/test_brand.png` exists and looks identical to the current debug screenshot output.

**Step 4: Commit**

```bash
cd ~/.config
git add branding/brand-screenshot
git commit -m "feat: add brand-screenshot CLI wrapping lib.sh"
```

---

### Task 3: Create `branding/brand-post` CLI

**Files:**
- Create: `branding/brand-post`

**Step 1: Create the file**

Create `~/.config/branding/brand-post` with this content:

```bash
#!/usr/bin/env bash

set -euo pipefail

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$DIR/lib.sh"

usage() {
  cat <<EOF
Usage: brand-post [OPTIONS] "Title text"

Options:
  -o <path>    Output file (default: ~/Pictures/Posts/post_<timestamp>.png)
  --no-open    Skip opening result in swappy
  -h, --help   Show this help

Title must be 66 characters or fewer.
EOF
  exit 1
}

output=""
no_open=false
title=""

while [[ $# -gt 0 ]]; do
  case "$1" in
    -o) output="$2"; shift 2 ;;
    --no-open) no_open=true; shift ;;
    -h|--help) usage ;;
    -*) echo "Unknown option: $1"; usage ;;
    *) title="$1"; shift ;;
  esac
done

[[ -z "$title" ]] && { echo "Error: title text is required."; usage; }

if [[ ${#title} -gt 66 ]]; then
  echo "Error: title is ${#title} characters (max 66)."
  exit 1
fi

if [[ -z "$output" ]]; then
  mkdir -p ~/Pictures/Posts
  output=~/Pictures/Posts/post_$(date +%Y%m%d_%H%M%S).png
fi

tmpfile=$(mktemp /tmp/post_XXXXXX.png)
add_title_post "$title" "$tmpfile"

if $no_open; then
  cp "$tmpfile" "$output"
  [[ -f "$output" ]] && notify-send "Post image saved" "$output"
else
  swappy -f "$tmpfile" -o "$output"
  [[ -f "$output" ]] && notify-send "Post image saved" "$output"
fi

rm -f "$tmpfile"
```

**Step 2: Make it executable**

```bash
chmod +x ~/.config/branding/brand-post
```

**Step 3: Test title validation**

```bash
~/.config/branding/brand-post "This title is way too long and exceeds the sixty six character maximum limit here"
```
Expected: `Error: title is 83 characters (max 66).` and exit code 1.

**Step 4: Test post generation (no-open to skip swappy)**

```bash
~/.config/branding/brand-post --no-open -o /tmp/test_post.png "My Neovim Setup: Plugins, Themes and Workflows"
```
Expected: no errors, `/tmp/test_post.png` exists. Open it with `imv /tmp/test_post.png` or `feh /tmp/test_post.png` to visually verify.

**Step 5: Commit**

```bash
cd ~/.config
git add branding/brand-post
git commit -m "feat: add brand-post CLI for generating branded post images"
```

---

### Task 4: Update `rofi/rofi-screenshot` to source `branding/lib.sh`

**Files:**
- Modify: `rofi/rofi-screenshot`

**Step 1: Replace the inline function definitions with a source line**

At the top of `rofi/rofi-screenshot`, replace the four function bodies (`round_corners`, `add_gradient_bg`, `add_branding`, and the `edit` function is fine to keep) with:

```bash
#!/usr/bin/env bash

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$DIR/../branding/lib.sh"
```

Keep the `edit` function in place (it's rofi-specific, not in lib). Keep everything from line 124 onward (`edit`, main `case` block) unchanged.

**Step 2: Verify sourcing works**

```bash
bash -n ~/.config/rofi/rofi-screenshot
```
Expected: no errors.

**Step 3: Quick function availability check**

```bash
bash -c 'source ~/.config/rofi/rofi-screenshot; type round_corners'
```
Expected: `round_corners is a function`

**Step 4: Commit**

```bash
cd ~/.config
git add rofi/rofi-screenshot
git commit -m "refactor: source branding/lib.sh in rofi-screenshot"
```

---

### Task 5: Update `rofi/rofi-screenshot-debug` to source `branding/lib.sh`

**Files:**
- Modify: `rofi/rofi-screenshot-debug`

**Step 1: Replace the source line**

The current file sources `rofi-screenshot` to get the functions. Change it to source `lib.sh` directly:

```bash
#!/usr/bin/env bash

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$DIR/../branding/lib.sh"

file="$DIR/debug_screenshot.png"

tmpfile=$(mktemp /tmp/screenshot_XXXXXX.png)
win=$(hyprctl activewindow -j | jq -r '"\\(.at[0]),\\(.at[1]) \\(.size[0])x\\(.size[1])"')
grim -g "$win" "$tmpfile"

round_corners "$tmpfile"
add_gradient_bg "$tmpfile" "$file"
rm "$tmpfile"
add_branding "$file"
echo "Debug screenshot saved to: $file"
```

**Step 2: Verify syntax**

```bash
bash -n ~/.config/rofi/rofi-screenshot-debug
```
Expected: no errors.

**Step 3: Commit**

```bash
cd ~/.config
git add rofi/rofi-screenshot-debug
git commit -m "refactor: source branding/lib.sh in rofi-screenshot-debug"
```

---

### Task 6: End-to-end verification

**Step 1: Run the debug screenshot to confirm rofi pipeline still works**

```bash
~/.config/rofi/rofi-screenshot-debug
```
Expected: `Debug screenshot saved to: ~/.config/rofi/debug_screenshot.png` and the image looks correct (gradient bg, avatar pill).

**Step 2: Run brand-post with a real title**

```bash
~/.config/branding/brand-post --no-open -o /tmp/final_post.png "How I Built a Screenshot Branding Tool With ImageMagick"
```
Open `/tmp/final_post.png` visually. Verify:
- 1200×630 canvas
- Blue gradient background
- White Inter Bold title, centered, wraps naturally
- Avatar + name pill at bottom-right

**Step 3: Run brand-screenshot standalone**

```bash
grim /tmp/raw.png
~/.config/branding/brand-screenshot /tmp/raw.png /tmp/branded.png
```
Expected: `/tmp/branded.png` has rounded corners, gradient bg, branding pill.

**Step 4: Final commit if any fixes were needed**

```bash
cd ~/.config
git add -p
git commit -m "fix: end-to-end branding pipeline verification fixes"
```
