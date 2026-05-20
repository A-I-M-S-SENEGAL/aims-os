#!/bin/bash
# =============================================================================
# AIMS OS — derived branding asset generator
# =============================================================================
# Reads the source assets:
#     branding/source/aims_circle.png            (563×563 RGBA — round logo)
#     branding/source/logo-aims.png              (1164×214 RGBA — wordmark)
#     branding/source/aims-os-maroon-lattice.svg (1400×980 — wallpaper pattern)
#
# Produces every PNG the build process needs (wallpapers, Plymouth assets,
# GRUB background, GNOME application icons, GDM banner, Calamares wallpaper)
# and writes them under branding/generated/.
#
# Runs INSIDE the aims-os-builder container (where ImageMagick 6,
# librsvg2-bin and optipng live). Invoke from the host via:
#     docker run --rm --platform linux/arm64 \
#         -v "$PWD:/build:delegated" \
#         aims-os-builder:arm64 bash /build/branding/generate-assets.sh
#
# The generated/ directory is NOT in git — it is reproducible from the
# source assets and this script. Anyone with the repo can regenerate
# every asset deterministically.
# =============================================================================

set -euo pipefail

# -----------------------------------------------------------------------------
# Brand palette — single source of truth
# -----------------------------------------------------------------------------
COLOR_BRAND_PRIMARY="#803018"   # logo strokes — extracted from the source PNG
COLOR_BRAND_ACCENT="#A0392E"    # lighter terracotta — UI accents, progress bar
COLOR_BG_CREAM="#F5EFE7"        # cream — used for boot chain (Plymouth, GRUB)
COLOR_BG_MAROON="#600000"       # deep maroon — lattice wallpaper base, matches SVG
COLOR_TEXT_DARK="#1A1A1A"       # primary text on cream
COLOR_TEXT_MUTED="#666666"      # secondary text

# Wallpaper-only tuning: the logo is overlaid at reduced opacity so the
# maroon lattice still shows through and the disc feels embedded in the
# design rather than stuck on top. 1.0 = fully opaque (Plymouth/GRUB use
# the unmodified logo; this knob only affects compose_pattern_with_logo).
LOGO_OPACITY_ON_WALLPAPER="0.70"

# -----------------------------------------------------------------------------
# Paths
# -----------------------------------------------------------------------------
REPO_ROOT="${REPO_ROOT:-/build}"
SRC_DIR="${REPO_ROOT}/branding/source"
OUT_DIR="${REPO_ROOT}/branding/generated"

LOGO_CIRCLE="${SRC_DIR}/aims_circle.png"
LOGO_WORDMARK="${SRC_DIR}/logo-aims.png"
WALLPAPER_SVG="${SRC_DIR}/aims-os-maroon-lattice.svg"

# -----------------------------------------------------------------------------
# Logging
# -----------------------------------------------------------------------------
BANNER='\033[1;35m[aims-os/branding]\033[0m'
log()  { printf '%b %s\n' "${BANNER}" "$*"; }
fail() { printf '%b \033[1;31mERROR:\033[0m %s\n' "${BANNER}" "$*" >&2; exit 1; }

# -----------------------------------------------------------------------------
# Pre-flight
# -----------------------------------------------------------------------------
command -v convert       >/dev/null || fail "ImageMagick not in PATH (apt install imagemagick)"
command -v rsvg-convert  >/dev/null || fail "rsvg-convert not in PATH (apt install librsvg2-bin)"
[[ -f "${LOGO_CIRCLE}"   ]]         || fail "missing ${LOGO_CIRCLE}"
[[ -f "${LOGO_WORDMARK}" ]]         || fail "missing ${LOGO_WORDMARK}"
[[ -f "${WALLPAPER_SVG}" ]]         || fail "missing ${WALLPAPER_SVG}"

# Read source dimensions so we know what we're starting from.
src_circle_dim="$(identify -format '%wx%h' "${LOGO_CIRCLE}")"
src_wordmark_dim="$(identify -format '%wx%h' "${LOGO_WORDMARK}")"
log "source circle:   ${src_circle_dim}"
log "source wordmark: ${src_wordmark_dim}"
log "source pattern:  $(basename "${WALLPAPER_SVG}")"

mkdir -p \
    "${OUT_DIR}/wallpapers" \
    "${OUT_DIR}/plymouth" \
    "${OUT_DIR}/grub" \
    "${OUT_DIR}/icons" \
    "${OUT_DIR}/gdm" \
    "${OUT_DIR}/calamares"

# -----------------------------------------------------------------------------
# Helpers
# -----------------------------------------------------------------------------

# compose_centered <canvas_w> <canvas_h> <bg_color> <logo_path> <logo_size> <output>
#
# Produces an RGB canvas of canvas_w × canvas_h filled with bg_color, with
# the logo (rescaled to logo_size square while preserving its alpha) placed
# at the geometric center.
compose_centered() {
    local cw="$1" ch="$2" bg="$3" logo="$4" lsize="$5" out="$6"

    convert -size "${cw}x${ch}" "canvas:${bg}" \
        \( "${logo}" -resize "${lsize}x${lsize}" \) \
        -gravity center -compose over -composite \
        -strip "${out}"
    optipng -quiet -o2 "${out}" 2>/dev/null || true
}

# resize_keep_alpha <input> <size> <output>
resize_keep_alpha() {
    local in="$1" size="$2" out="$3"
    convert "${in}" -resize "${size}x${size}" -strip "${out}"
}

# compose_pattern_with_logo <canvas_w> <canvas_h> <logo_size> <output>
#
# Renders the maroon-lattice SVG at canvas_w width preserving the pattern's
# native aspect (no stretch — diamonds stay square), centre-crops vertically
# to canvas_h, and stamps the AIMS circle logo at the geometric centre at
# the requested size. The SVG is 1400×980 (aspect 1.43) and our targets are
# 16:9 (aspect 1.78), so the rendered SVG overflows vertically — the centre
# crop keeps the visually-richest band of the lattice. Background colour
# (#600000) matches the SVG's base fill, so the edges blend if the picture
# is later letterboxed by the compositor.
compose_pattern_with_logo() {
    local cw="$1" ch="$2" lsize="$3" out="$4"
    local tmp_bg tmp_logo
    tmp_bg="$(mktemp --suffix=.png)"
    tmp_logo="$(mktemp --suffix=.png)"

    rsvg-convert -w "${cw}" -b "${COLOR_BG_MAROON}" \
        "${WALLPAPER_SVG}" -o "${tmp_bg}"

    # Resize the logo and dim its alpha channel uniformly so both the
    # white disc and the inked Africa silhouette go translucent together.
    convert "${LOGO_CIRCLE}" -resize "${lsize}x${lsize}" \
        -alpha set -channel A \
        -evaluate multiply "${LOGO_OPACITY_ON_WALLPAPER}" +channel \
        "${tmp_logo}"

    convert "${tmp_bg}" \
        -background "${COLOR_BG_MAROON}" \
        -gravity center -extent "${cw}x${ch}" \
        "${tmp_logo}" \
        -gravity center -compose over -composite \
        -strip "${out}"

    rm -f "${tmp_bg}" "${tmp_logo}"
    optipng -quiet -o2 "${out}" 2>/dev/null || true
}

# -----------------------------------------------------------------------------
# 1. Wallpapers
#    1080p + 4K, maroon-lattice pattern background, logo centred. 320 px on
#    1080p was tuned for the cream wallpaper and still looks balanced on the
#    busier maroon pattern; the logo's terracotta + cream palette has enough
#    contrast against #600000 to stay legible without an outline.
# -----------------------------------------------------------------------------
log "generating wallpapers ..."
compose_pattern_with_logo 1920 1080 320 \
    "${OUT_DIR}/wallpapers/aims-os-default-1080p.png"
compose_pattern_with_logo 3840 2160 640 \
    "${OUT_DIR}/wallpapers/aims-os-default-4k.png"

# -----------------------------------------------------------------------------
# 2. Plymouth boot splash
#    A static circle at high res (Plymouth's script rotates it at runtime).
#    Plymouth's image-loading code dislikes alpha quirks, so we paint the
#    logo over an opaque cream square instead of keeping it transparent.
# -----------------------------------------------------------------------------
log "generating Plymouth assets ..."
compose_centered 400 400 "${COLOR_BG_CREAM}" "${LOGO_CIRCLE}" 360 \
    "${OUT_DIR}/plymouth/aims-circle.png"

# Ray ring — 12 short terracotta dashes arranged on a 600×600 canvas
# around an empty 440×440 center (so the logo will fit inside cleanly).
# Plymouth's refresh callback rotates this image around its centre; the
# logo sprite renders ON TOP and stays motionless. Coordinates below are
# computed for canvas center (300,300), inner radius 220, outer radius 280.
convert -size 600x600 xc:transparent \
    -stroke "${COLOR_BRAND_PRIMARY}" -strokewidth 10 -fill none \
    -draw "stroke-linecap round
           line 300,80  300,20
           line 410,110 440,58
           line 491,190 543,160
           line 520,300 580,300
           line 491,410 543,440
           line 410,490 440,542
           line 300,520 300,580
           line 190,490 160,542
           line 109,410 58,440
           line 80,300  20,300
           line 109,190 58,160
           line 190,110 160,58" \
    -strip "${OUT_DIR}/plymouth/ray-ring.png"
optipng -quiet -o2 "${OUT_DIR}/plymouth/ray-ring.png" 2>/dev/null || true

# Optional secondary progress bar (kept for potential future use)
convert -size 600x4 "xc:${COLOR_BRAND_ACCENT}" \
    -strip "${OUT_DIR}/plymouth/progress-bar-fg.png"
convert -size 600x4 "xc:#E6D8C8" \
    -strip "${OUT_DIR}/plymouth/progress-bar-bg.png"

# -----------------------------------------------------------------------------
# 3. GRUB background
#    1920×1080 maroon-lattice base composed in four passes:
#      1. rasterise the SVG pattern at the canvas width (preserving aspect),
#         centre-crop to 1080 so the diamonds stay square
#      2. multiply a soft radial vignette — corners drop ~30% in luminance,
#         the centre stays at full intensity. This frames the boot menu
#         naturally without an explicit panel
#      3. anchor the AIMS circle logo top-left
#      4. render "AIMS OS 1.0" + "Live & Install Media" in cream beside it
#         using DejaVu (the wordmark PNG already contains its own circle and
#         its inks are dark, so it would duplicate the logo AND vanish on
#         maroon — we render the text fresh instead, in colours we control)
#
#    Net effect: a calm, balanced top band (branding) → empty middle (where
#    the menu lives). Everything else is intentionally negative space.
# -----------------------------------------------------------------------------
log "generating GRUB background ..."
GRUB_BG_TMP="$(mktemp --suffix=.png)"
GRUB_VIGN_TMP="$(mktemp --suffix=.png)"

# Pass 1 — rasterise + centre-crop the lattice
rsvg-convert -w 1920 -b "${COLOR_BG_MAROON}" \
    "${WALLPAPER_SVG}" -o "${GRUB_BG_TMP}"

# Pass 2 — build a soft radial-gradient vignette (white centre, light-grey
# edges) and multiply-blend it onto the lattice so the corners read
# slightly deeper-maroon without going pitch black.
convert -size 1920x1080 radial-gradient:'#FFFFFF'-'#B0B0B0' \
    "${GRUB_VIGN_TMP}"

# Pass 3+4 — composite logo, then stamp the wordmark text we control.
convert "${GRUB_BG_TMP}" \
    -background "${COLOR_BG_MAROON}" \
    -gravity center -extent 1920x1080 \
    "${GRUB_VIGN_TMP}" -compose multiply -composite \
    -compose over \
    \
    \( "${LOGO_CIRCLE}" -resize 160x160 \) -gravity northwest -geometry +110+88 -composite \
    \
    -font "DejaVu-Sans-Bold" -pointsize 56 -fill "#F5EFE7" \
        -gravity northwest -annotate +300+108 "AIMS OS 1.0" \
    -font "DejaVu-Sans"      -pointsize 22 -fill "#E6D8C8" \
        -gravity northwest -annotate +302+180 "Live & Install Media" \
    \
    -strip "${OUT_DIR}/grub/background.png"

rm -f "${GRUB_BG_TMP}" "${GRUB_VIGN_TMP}"
optipng -quiet -o2 "${OUT_DIR}/grub/background.png" 2>/dev/null || true

# ---- Selected-item highlight (9-patch pixmap) ------------------------------
# Modern GRUB themes (Pop!_OS, Vimix, Tela) don't paint a panel behind the
# whole menu. Instead they ship a 9-patch under the *selected* row only:
# centre + four edges are 1×1 tiles GRUB tiles to fit the row width/height,
# the four corners are tiny rounded-quarter-disc PNGs that give the
# highlight its rounded look. Result is a soft terracotta pill that follows
# whichever menu entry is currently focused.
#
# Layout: corner R = 8 px, fill is terracotta at 78 % opacity so the lattice
# stays faintly visible through the highlight (the row feels "lit", not
# "stamped on top").
log "generating GRUB selection pixmaps ..."
SELECT_COLOR='rgba(160,57,46,0.78)'

# Centre + four straight edges — solid terracotta, GRUB will tile them.
for piece in c n s e w; do
    convert -size 1x1 "xc:${SELECT_COLOR}" \
        -strip "${OUT_DIR}/grub/select_${piece}.png"
done

# Four 8×8 corners — quarter-disc fills the *inside* corner, the
# outside-corner pixels stay transparent so the highlight looks rounded.
# `circle CX,CY PX,PY` in ImageMagick: centre then a point on the perimeter
# (radius = distance between the two points = 8 here).
convert -size 8x8 xc:transparent -fill "${SELECT_COLOR}" \
    -draw 'circle 8,8 0,8' -strip "${OUT_DIR}/grub/select_nw.png"
convert -size 8x8 xc:transparent -fill "${SELECT_COLOR}" \
    -draw 'circle 0,8 8,8' -strip "${OUT_DIR}/grub/select_ne.png"
convert -size 8x8 xc:transparent -fill "${SELECT_COLOR}" \
    -draw 'circle 8,0 8,8' -strip "${OUT_DIR}/grub/select_sw.png"
convert -size 8x8 xc:transparent -fill "${SELECT_COLOR}" \
    -draw 'circle 0,0 8,8' -strip "${OUT_DIR}/grub/select_se.png"

for f in c n s e w nw ne sw se; do
    optipng -quiet -o2 "${OUT_DIR}/grub/select_${f}.png" 2>/dev/null || true
done

# -----------------------------------------------------------------------------
# 4. GDM login screen background (same as wallpaper for now)
# -----------------------------------------------------------------------------
log "generating GDM background ..."
cp "${OUT_DIR}/wallpapers/aims-os-default-1080p.png" "${OUT_DIR}/gdm/background.png"

# -----------------------------------------------------------------------------
# 5. Calamares welcome-screen wallpaper
#    Calamares displays productWallpaper on the welcome page. We reuse the
#    1080p desktop wallpaper so the installer feels like the rest of AIMS OS
#    instead of jumping to a different visual world. The Calamares branding
#    deploy step picks this up from branding/generated/calamares/.
# -----------------------------------------------------------------------------
log "generating Calamares wallpaper ..."
cp "${OUT_DIR}/wallpapers/aims-os-default-1080p.png" \
   "${OUT_DIR}/calamares/aims-os-wallpaper.png"

# -----------------------------------------------------------------------------
# 6. Application launcher icons (sizes per freedesktop icon-theme spec)
# -----------------------------------------------------------------------------
log "generating app icons ..."
for size in 16 24 32 48 64 96 128 256 512; do
    mkdir -p "${OUT_DIR}/icons/${size}x${size}"
    resize_keep_alpha "${LOGO_CIRCLE}" "${size}" \
        "${OUT_DIR}/icons/${size}x${size}/aims-os-logo.png"
done

# -----------------------------------------------------------------------------
# 7. Inventory & summary
# -----------------------------------------------------------------------------
log "done — generated assets:"
( cd "${OUT_DIR}" && find . -type f -name '*.png' | sort | while read -r f; do
    dim="$(identify -format '%wx%h' "${f}")"
    size="$(du -h "${f}" | cut -f1)"
    printf '  %-50s %s  %s\n' "${f#./}" "${dim}" "${size}"
done )
