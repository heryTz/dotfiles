#!/usr/bin/env bash

# Palette: mirrors OG_COLOR in the portfolio's src/server/og-assets.ts, so
# branded images match the OG cards and banners herynirintsoa.com already ships.
# Monochrome base plus a single gold accent; there is deliberately no second hue.
BRAND_BG="#0a0a0b"       # background
BRAND_SURFACE="#161618"  # card, used for the footer band
BRAND_LIFT="#202023"     # neutral backdrop lift, keeps drop shadows readable
BRAND_FG="#f4f4f5"       # foreground
BRAND_GOLD="#f0c238"     # accent (dark-mode gold)
BRAND_GOLD_DEEP="#daa216" # accent, light-mode gold; shades the avatar ring
BRAND_GRAD_HI="#1f1f24"  # post background gradient, lit corner
BRAND_GRAD_MID="#141417" # post background gradient, midpoint

# Fonts, matching the site. Two engines, two spellings: ImageMagick wants the
# hyphenated name, pango wants a descriptor. ImageMagick falls back silently on
# an unknown -font, so a typo renders in the wrong face rather than failing.
BRAND_FONT_IM="Geist-Mono-Bold"  # badge name, via ImageMagick label:
BRAND_FONT_PANGO="Geist Bold"    # post headline, via pango markup

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
      "0,0 $BRAND_BG  ${w},0 $BRAND_BG  ${hw},0 $BRAND_LIFT  ${hw},${hh} #1c1c1f  0,${h} $BRAND_BG  ${w},${h} $BRAND_SURFACE" \
    -blur 0x50 \
    "$shadowfile" -gravity center -composite \
    "$output"
}

# Composite a branded signature (circular avatar + name) onto the bottom-right.
# Args: <file.png>
add_branding() {
  local file="$1"
  local avatar_src="$HOME/.config/rofi/avatar.png"

  # Scale the badge with the canvas so it reads the same on a 2560px screenshot
  # as on a post. Post width is the reference, so posts are unchanged at 1.0.
  # Held as permille because bash has no float arithmetic.
  local ref_w=1200
  local img_w
  img_w=$(magick identify -format "%w" "$file") || return 1
  local scale=$(( img_w * 1000 / ref_w ))
  (( scale < 1000 )) && scale=1000
  (( scale > 2600 )) && scale=2600

  local size=$(( 56 * scale / 1000 ))
  local border=$(( 3 * scale / 1000 ))
  (( border < 2 )) && border=2
  local total=$((size + border * 2))
  local half_t=$((total / 2))
  local half_s=$((size / 2))
  local gap=$(( 14 * scale / 1000 ))
  local pad_y=$(( 12 * scale / 1000 ))
  local pad_x=$pad_y
  local name="Hery Nirintsoa"
  local font_size=$(( 26 * scale / 1000 ))

  # Circle masks are drawn oversized and downscaled, so the avatar and ring
  # edges land antialiased instead of stair-stepped. Drawing them at final
  # size leaves visibly jagged pixels, more so as size grows.
  local ss=4

  # The ring is synthetic, so it can always take the full 4x.
  local total_hi=$((total * ss))
  local half_t_hi=$((total_hi / 2))
  local blur_hi=$(( 6 * scale * ss / 1000 ))

  # The avatar cannot: oversampling past the source resolution would upscale
  # the photo and soften it. Cap the mask at the source's own width.
  local avatar_w
  avatar_w=$(magick identify -format "%w" "$avatar_src") || return 1
  local size_hi=$((size * ss))
  (( size_hi > avatar_w )) && size_hi=$avatar_w
  (( size_hi < size )) && size_hi=$size
  local half_s_hi=$((size_hi / 2))

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
    -resize "${size_hi}x${size_hi}^" -gravity center -extent "${size_hi}x${size_hi}" \
    \( +clone -alpha extract \
       -fill black -colorize 100 \
       -fill white -draw "circle ${half_s_hi},${half_s_hi} ${half_s_hi},1" \
    \) \
    -alpha off -compose CopyOpacity -composite \
    -filter Catrom -resize "${size}x${size}" \
    "$tmp_avatar" || { _branding_cleanup; return 1; }

  magick -size "${total_hi}x${total_hi}" xc: \
    -sparse-color Shepards \
      "0,0 $BRAND_GOLD  ${total_hi},${total_hi} $BRAND_GOLD_DEEP" \
    -blur 0x${blur_hi} \
    \( +clone -alpha extract \
       -fill black -colorize 100 \
       -fill white -draw "circle ${half_t_hi},${half_t_hi} ${half_t_hi},1" \
    \) \
    -alpha off -compose CopyOpacity -composite \
    -filter Catrom -resize "${total}x${total}" \
    "$tmp_disc" || { _branding_cleanup; return 1; }

  magick "$tmp_disc" "$tmp_avatar" -gravity center -compose Over -composite "$tmp_ring" \
    || { _branding_cleanup; return 1; }
  rm -f "$tmp_avatar" "$tmp_disc"

  magick -background none -fill "$BRAND_FG" \
    -font "$BRAND_FONT_IM" -pointsize "$font_size" \
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
  local extend=$(( strip_h + 24 * scale / 1000 ))
  local off_x=$(( 18 * scale / 1000 ))
  local off_y=$(( 12 * scale / 1000 ))
  magick "$file" -gravity South -background "$BRAND_SURFACE" -splice "0x${extend}" "$file"
  magick "$file" "$tmp_brand" -gravity SouthEast -geometry "+${off_x}+${off_y}" -composite "$tmp_out" \
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
  # Wrap words in *...* for the gold accent. * is not an XML char
  # so it survives escaping, then the last sed pass converts it to span tags.
  local safe_text
  safe_text=$(printf '%s' "$text" | \
    sed -e 's/&/\&amp;amp;/g' \
        -e 's/</\&amp;lt;/g' \
        -e 's/>/\&amp;gt;/g' \
        -e "s/\*\([^*]*\)\*/<span foreground='${BRAND_GOLD}'>\1<\/span>/g")

  # --- Geometry constants ---
  local text_w=1000
  local font_size=44

  # --- Pango markup: text only (quote bar drawn separately) ---
  local pango_markup
  pango_markup="<span font='${BRAND_FONT_PANGO} ${font_size}' foreground='${BRAND_FG}'>${safe_text}</span>"

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
  # Near-black gradients band badly once a social platform re-encodes the upload
  # to JPEG, so a light gray noise layer is overlaid to break up the quantisation
  # steps. Keep the noise in sRGB: desaturating it (-colorspace Gray, -modulate
  # 100,0) writes a grayscale background, and compositing the gold text onto a
  # grayscale base silently strips the accent and the emoji to gray.
  magick -size "${w}x${h}" xc: \
    -sparse-color Shepards \
      "0,0 $BRAND_BG  ${w},${h} $BRAND_GRAD_HI  $((w/2)),$((h/2)) $BRAND_GRAD_MID" \
    -blur 0x40 \
    \( +clone -fill '#808080' -colorize 100 -attenuate 0.9 +noise Gaussian \) \
    -compose Overlay -composite -colorspace sRGB -type TrueColor \
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
    -fill "$BRAND_GOLD" \
    -draw "rectangle ${bar_x},${bar_y} $((bar_x + bar_w - 1)),${bar_y2}" \
    "$output" || return 1

  # Step 6: branding badge
  add_branding "$output"
}
