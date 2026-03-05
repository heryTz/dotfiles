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
      "0,0 #e8f4fc  ${w},0 #b3d9f0  ${hw},0 #6ab8e4  ${hw},${hh} #3a9acf  0,${h} #1e7ab5  ${w},${h} #0d5a8a" \
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
      "0,0 #c8e8fa  ${total},0 #7ec5ec  0,${total} #4aa8d8  ${total},${total} #2080b8" \
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
    -fill "rgba(0,0,0,0.42)" \
    -draw "roundrectangle 0,0 $((strip_w - 1)),$((strip_h - 1)) ${pill_r},${pill_r}" \
    "$tmp_ring" -geometry "+${pad_x}+${pad_y}" -composite \
    "$tmp_text" -geometry "+${text_x}+${text_y}" -composite \
    "$tmp_brand" || { _branding_cleanup; return 1; }
  rm -f "$tmp_ring" "$tmp_text"

  tmp_out=$(mktemp /tmp/branded_XXXXXX.png)
  magick "$file" "$tmp_brand" -gravity SouthEast -geometry "+12+12" -composite "$tmp_out" \
    || { _branding_cleanup; return 1; }
  mv "$tmp_out" "$file"
  rm -f "$tmp_brand"
}

# Generate a 1200x630 branded post image with centered title text in a card.
# Args: <text> <output.png>
add_title_post() {
  local text="$1" output="$2"
  local w=1200 h=630
  local font_size=60
  # Escape for Pango XML markup; guard leading @ from ImageMagick
  local safe_text="$text"
  safe_text="${safe_text//&/&amp;}"
  safe_text="${safe_text//</&lt;}"
  safe_text="${safe_text//>/&gt;}"
  [[ "$safe_text" == @* ]] && safe_text=" $safe_text"

  local card_w=1040 card_h=450 card_r=20
  local card_x=$(( (w - card_w) / 2 ))
  local card_y=$(( (h - card_h) / 2 ))

  local tmp_bg tmp_bg_blur tmp_card tmp_text
  trap 'rm -f "$tmp_bg" "$tmp_bg_blur" "$tmp_card" "$tmp_text"' RETURN
  tmp_bg=$(mktemp /tmp/bg_XXXXXX.png)
  tmp_bg_blur=$(mktemp /tmp/bg_blur_XXXXXX.png)
  tmp_card=$(mktemp /tmp/card_XXXXXX.png)
  tmp_text=$(mktemp /tmp/title_XXXXXX.png)

  # Screenshot-style Shepards gradient background
  local hw=$((w / 2)) hh=$((h / 2))
  magick -size "${w}x${h}" xc: \
    -sparse-color Shepards \
      "0,0 #e8f4fc  ${w},0 #b3d9f0  ${hw},0 #6ab8e4  ${hw},${hh} #3a9acf  0,${h} #1e7ab5  ${w},${h} #0d5a8a" \
    -blur 0x50 \
    "$tmp_bg" || { return 1; }

  # Glass card: blur bg, mask to card shape, dark tint + white border
  magick "$tmp_bg" -blur 0x18 "$tmp_bg_blur" || { return 1; }

  magick "$tmp_bg_blur" \
    -crop "${card_w}x${card_h}+${card_x}+${card_y}" +repage \
    \( +clone -alpha extract \
       -fill black -colorize 100 \
       -fill white \
       -draw "roundrectangle 0,0 $((card_w - 1)),$((card_h - 1)) ${card_r},${card_r}" \
    \) \
    -alpha off -compose CopyOpacity -composite \
    -fill "rgba(5,15,40,0.58)" \
    -draw "roundrectangle 0,0 $((card_w - 1)),$((card_h - 1)) ${card_r},${card_r}" \
    -fill none \
    -stroke "rgba(255,255,255,0.20)" \
    -strokewidth 2 \
    -draw "roundrectangle 0,0 $((card_w - 1)),$((card_h - 1)) ${card_r},${card_r}" \
    "$tmp_card" || { return 1; }

  # White text inside glass card — pango for emoji/fallback font support
  magick -size "$((card_w - 120))x$((card_h - 80))" \
    -background none \
    -define pango:align=center \
    pango:"<span font='Inter Bold ${font_size}' foreground='white'>${safe_text}</span>" \
    "$tmp_text" || { return 1; }

  # Composite: bg + card + text (text centered inside card)
  local txt_w txt_h txt_x txt_y
  txt_w=$(magick identify -format "%w" "$tmp_text") || { return 1; }
  txt_h=$(magick identify -format "%h" "$tmp_text") || { return 1; }
  txt_x=$(( card_x + (card_w - txt_w) / 2 ))
  txt_y=$(( card_y + (card_h - txt_h) / 2 ))
  magick "$tmp_bg" \
    "$tmp_card" -geometry "+${card_x}+${card_y}" -composite \
    "$tmp_text" -geometry "+${txt_x}+${txt_y}" -composite \
    "$output" || { return 1; }

  add_branding "$output"
}
