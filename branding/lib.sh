#!/usr/bin/env bash

# Round corners of an image in-place to match Hyprland rounding = 6.
# Args: <file.png>
round_corners() {
  local file="$1" r=6
  local tmp
  tmp=$(mktemp /tmp/rounded_XXXXXX.png)
  trap 'rm -f "$tmp"' RETURN
  magick "$file" \
    \( +clone -alpha extract \
       -draw "fill black polygon 0,0 0,$r $r,0 fill white circle $r,$r $r,0" \
       \( +clone -flip \) -compose Multiply -composite \
       \( +clone -flop \) -compose Multiply -composite \
    \) \
    -alpha off -compose CopyOpacity -composite \
    "$tmp"
  mv "$tmp" "$file"
}

# Composite a pastel gradient background behind a shadow-padded image.
# Args: <input.png> <output.png>
add_gradient_bg() {
  local input="$1" output="$2"
  local shadowfile
  shadowfile=$(mktemp /tmp/screenshot_XXXXXX.png)
  trap 'rm -f "$shadowfile"' RETURN

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
      "0,0 #131521  ${w},0 #131521  ${hw},0 #2d2f5e  ${hw},${hh} #1a1b2e  0,${h} #1e2030  ${w},${h} #24283b" \
    -blur 0x50 \
    "$shadowfile" -gravity center -composite \
    "$output"
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
  local gap=10  pad_y=8
  local pad_x=$pad_y
  local name="Hery Nirintsoa"  font_size=17

  local tmp_avatar tmp_disc tmp_ring tmp_text tmp_brand tmp_out
  tmp_avatar=$(mktemp /tmp/av_XXXXXX.png)
  tmp_disc=$(mktemp /tmp/disc_XXXXXX.png)
  tmp_ring=$(mktemp /tmp/ring_XXXXXX.png)
  tmp_text=$(mktemp /tmp/text_XXXXXX.png)
  tmp_brand=$(mktemp /tmp/brand_XXXXXX.png)

  _branding_cleanup() {
    rm -f "$tmp_avatar" "$tmp_disc" "$tmp_ring" "$tmp_text" "$tmp_brand" "$tmp_out"
  }

  magick "$avatar_src" \
    -resize "${size}x${size}^" -gravity center -extent "${size}x${size}" \
    \( +clone -alpha extract \
       -fill black -colorize 100 \
       -fill white -draw "circle ${half_s},${half_s} ${half_s},1" \
    \) \
    -alpha off -compose CopyOpacity -composite \
    "$tmp_avatar" || { _branding_cleanup; return 1; }

  magick -size "${total}x${total}" xc: \
    -sparse-color Shepards \
      "0,0 #7aa2f7  ${total},${total} #bb9af7" \
    -blur 0x6 \
    \( +clone -alpha extract \
       -fill black -colorize 100 \
       -fill white -draw "circle ${half_t},${half_t} ${half_t},1" \
    \) \
    -alpha off -compose CopyOpacity -composite \
    "$tmp_disc" || { _branding_cleanup; return 1; }

  magick "$tmp_disc" "$tmp_avatar" -gravity center -compose Over -composite "$tmp_ring" \
    || { _branding_cleanup; return 1; }
  rm -f "$tmp_avatar" "$tmp_disc"

  magick -background none -fill white \
    -font "JetBrainsMono-NF-Bold" -pointsize "$font_size" \
    label:"$name" "$tmp_text" || { _branding_cleanup; return 1; }

  local text_w text_h
  text_w=$(magick identify -format "%w" "$tmp_text") || { _branding_cleanup; return 1; }
  text_h=$(magick identify -format "%h" "$tmp_text") || { _branding_cleanup; return 1; }

  local strip_w=$(( pad_x + total + gap + text_w + pad_x ))
  local strip_h=$(( total + pad_y * 2 ))
  local text_x=$(( pad_x + total + gap ))
  local text_y=$(( (strip_h - text_h) / 2 ))
  local pill_r=$(( strip_h / 2 ))

  magick -size "${strip_w}x${strip_h}" xc:none \
    "$tmp_ring" -geometry "+${pad_x}+${pad_y}" -composite \
    "$tmp_text" -geometry "+${text_x}+${text_y}" -composite \
    "$tmp_brand" || { _branding_cleanup; return 1; }
  rm -f "$tmp_ring" "$tmp_text"

  tmp_out=$(mktemp /tmp/branded_XXXXXX.png)
  local extend=$(( strip_h + 16 ))
  magick "$file" -gravity South -background '#1a1b2e' -splice "0x${extend}" "$file"
  magick "$file" "$tmp_brand" -gravity SouthEast -geometry "+12+8" -composite "$tmp_out" \
    || { _branding_cleanup; return 1; }
  mv "$tmp_out" "$file"
  rm -f "$tmp_brand"
}

# Generate a 1200x628 branded LinkedIn landscape post image.
# Args: <text> <output.png>
add_title_post() {
  local text="$1" output="$2"
  local w=1200 h=628

  # --- Pango markup: escape XML chars, then convert *word* to purple spans ---
  # ImageMagick's XML layer decodes entities before passing to pango markup,
  # so double-escaping is required: & -> &amp;amp;  < -> &amp;lt;  > -> &amp;gt;
  # Wrap words in *...* for purple highlight (#bb9af7). * is not an XML char
  # so it survives escaping, then the last sed pass converts it to span tags.
  local safe_text
  safe_text=$(printf '%s' "$text" | \
    sed -e 's/&/\&amp;amp;/g' \
        -e 's/</\&amp;lt;/g' \
        -e 's/>/\&amp;gt;/g' \
        -e "s/\*\([^*]*\)\*/<span foreground='#bb9af7'>\1<\/span>/g")

  # --- Geometry constants ---
  local text_w=1000
  local font_size=44

  # --- Pango markup: text only (quote bar drawn separately) ---
  local pango_markup
  pango_markup="<span font='Space Grotesk SemiBold ${font_size}' foreground='#c0caf5'>${safe_text}</span>"

  # --- Temp files ---
  local tmp_bg tmp_text
  tmp_bg=$(mktemp /tmp/post_bg_XXXXXX.png)
  tmp_text=$(mktemp /tmp/post_text_XXXXXX.png)
  trap 'rm -f "$tmp_bg" "$tmp_text"' RETURN

  # =========================================================
  # PHASE A: Render text to measure dimensions
  # =========================================================
  magick -size "${text_w}x1600" -background none \
    -define pango:align=left \
    pango:"${pango_markup}" \
    -trim +repage \
    "$tmp_text" || return 1

  local text_block_w text_block_h
  text_block_w=$(magick identify -format "%w" "$tmp_text") || return 1
  text_block_h=$(magick identify -format "%h" "$tmp_text") || return 1

  # =========================================================
  # PHASE B: Build background canvas
  # =========================================================
  magick -size "${w}x${h}" xc: \
    -sparse-color Shepards \
      "0,0 #1a1b2e  ${w},${h} #24283b  $((w/2)),$((h/2)) #1e2030" \
    -blur 0x40 \
    "$tmp_bg" || return 1

  # =========================================================
  # PHASE C: Composite text + quote bar onto background
  # =========================================================

  # Step 1: composite text centered
  magick "$tmp_bg" "$tmp_text" -gravity Center -composite "$output" || return 1

  # Step 2: draw thin vertical quote bar to the left of the text block
  local bar_w=3 bar_gap=32
  local bar_x=$(( (w - text_block_w) / 2 - bar_gap - bar_w ))
  local bar_y=$(( (h - text_block_h) / 2 ))
  local bar_y2=$(( bar_y + text_block_h - 1 ))
  magick "$output" \
    -fill '#7aa2f7' \
    -draw "rectangle ${bar_x},${bar_y} $((bar_x + bar_w - 1)),${bar_y2}" \
    "$output" || return 1

  # Step 6: branding badge
  add_branding "$output"
}
