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
#    1080p + 4K, cream canvas, AIMS circle logo centred at 320 px (640 px
#    for 4K — same visual size at higher DPI). Cream is the calm,
#    text-friendly default for the desktop + GDM greeter + lock screen.
#    The maroon-lattice SVG is still used elsewhere (GRUB only, see step 3)
#    so the boot screen still carries the brand colour.
# -----------------------------------------------------------------------------
log "generating wallpapers ..."
compose_centered 1920 1080 "${COLOR_BG_CREAM}" "${LOGO_CIRCLE}" 320 \
    "${OUT_DIR}/wallpapers/aims-os-default-1080p.png"
compose_centered 3840 2160 "${COLOR_BG_CREAM}" "${LOGO_CIRCLE}" 640 \
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
# 3. GRUB background (v4 — hero centred on a soft radial gradient)
#
# Earlier versions stamped the maroon-lattice SVG behind the menu. The
# pattern was technically beautiful but visually busy on the boot screen
# — the diamonds competed with the menu entries for attention. We swap
# it for a hero-centred composition (the Pop!_OS / Sheffield school):
#
#   ┌────────────────────────────────────────────────────────────┐
#   │                                                            │
#   │                                                            │
#   │                   ◯ AIMS logo (280 px)                     │  ← upper-middle
#   │                                                            │
#   │                       AIMS OS                              │  ← DejaVu-Bold 72
#   │                  Live & Install Media                      │  ← DejaVu 28
#   │                                                            │
#   │           (boot_menu lives here at y ≈ 55 %)               │
#   │                                                            │
#   └────────────────────────────────────────────────────────────┘
#       background : radial gradient #500000 (centre) → #1A0000 (edges)
#
# Composition passes:
#   1. paint a 1920×1080 radial gradient from #500000 (centre) to #1A0000
#      (edges) — a calm "glow" under the brand area without any pattern
#   2. composite the AIMS logo PNG at 280 px, centred horizontally,
#      offset upward (y = 38 % of canvas) so the menu has room below
#   3. stamp "AIMS OS" wordmark in DejaVu-Bold 72 cream, below the logo
#   4. stamp "Live & Install Media" tagline in DejaVu 28 muted cream,
#      below the wordmark
#
# Why a single PNG instead of compositing text in the theme.txt:
#   - DejaVu fonts render with anti-aliasing at build time; GRUB's
#     internal PF2 font renderer is bitmap-only and renders text noisier
#     at large sizes
#   - the wordmark + tagline never change between builds, so baking them
#     into the PNG saves theme.txt complexity
# -----------------------------------------------------------------------------
log "generating GRUB background (hero + gradient) ..."
GRUB_BG_TMP="$(mktemp --suffix=.png)"

# Pass 1 — radial gradient #500000 → #1A0000. ImageMagick's radial-gradient
# fills from the centre outward by default; the second colour is the edge
# colour. The "plasma:" alternative would inject random noise — we want
# a clean, deterministic look.
convert -size 1920x1080 \
    radial-gradient:'#500000'-'#1A0000' \
    "${GRUB_BG_TMP}"

# Pass 2-4 — composite the logo + wordmark + tagline on top.
#   logo  : 280×280, anchored at y = 38 % of canvas (centre of logo)
#   text 1: "AIMS OS"  — pointsize 72, ~70 px below logo bottom
#   text 2: tagline    — pointsize 28, ~30 px below the wordmark
# ImageMagick's `-gravity center` + `-geometry +X+Y` measures from the
# canvas centre, positive Y goes DOWN. The logo's vertical anchor is
# the geometric centre of the logo rectangle.
convert "${GRUB_BG_TMP}" \
    \( "${LOGO_CIRCLE}" -resize 280x280 \) \
        -gravity center -geometry +0-130 -composite \
    \
    -font "DejaVu-Sans-Bold" -pointsize 72 -fill "#F5EFE7" \
        -gravity center -annotate +0+60  "AIMS OS" \
    -font "DejaVu-Sans"      -pointsize 28 -fill "#E6D8C8" \
        -gravity center -annotate +0+130 "Live & Install Media" \
    \
    -strip "${OUT_DIR}/grub/background.png"

rm -f "${GRUB_BG_TMP}"
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
# Full-opacity terracotta — the pill must read as a deliberate UI element
# against the maroon lattice, not a vague translucent wash. Previous
# version was 78% alpha and combined with a 9-patch dimension bug
# (below) it was effectively invisible at boot.
SELECT_COLOR='rgba(160,57,46,1.0)'
SELECT_RADIUS=8

# GRUB renders the selection background as a 9-patch: the four corners
# are placed at the corners of the selected row, the four edge tiles
# fill the remaining strips between corners, and the centre tile fills
# the middle. For the corners and the perpendicular dimension of the
# edges to MATCH, every edge tile has to be R px in the corner-aligned
# dimension (so GRUB doesn't drop or stretch them oddly):
#
#   nw/ne/sw/se : R × R         (rounded-quarter-disc corners)
#   n  / s      : 1 × R         (1px wide, tiled horizontally to fill)
#   e  / w      : R × 1         (1px tall, tiled vertically to fill)
#   c           : 1 × 1         (tiled in both directions to fill centre)
#
# A previous iteration used 1×1 for n/s/e/w, which left R-1 px gaps
# between corners and centre — GRUB rendered the corner dots alone and
# the selection pill effectively vanished.

# n / s — full-height vertical slice, GRUB tiles horizontally.
convert -size "1x${SELECT_RADIUS}" "xc:${SELECT_COLOR}" \
    -strip "${OUT_DIR}/grub/select_n.png"
convert -size "1x${SELECT_RADIUS}" "xc:${SELECT_COLOR}" \
    -strip "${OUT_DIR}/grub/select_s.png"

# e / w — full-width horizontal slice, GRUB tiles vertically.
convert -size "${SELECT_RADIUS}x1" "xc:${SELECT_COLOR}" \
    -strip "${OUT_DIR}/grub/select_e.png"
convert -size "${SELECT_RADIUS}x1" "xc:${SELECT_COLOR}" \
    -strip "${OUT_DIR}/grub/select_w.png"

# c — single pixel, tiled in both directions.
convert -size 1x1 "xc:${SELECT_COLOR}" \
    -strip "${OUT_DIR}/grub/select_c.png"

# Four 8×8 corners. Earlier iterations used a transparent quarter-disc
# for rounded-pill look, but grub-efi-arm64 2.06's gfxmenu silently
# discards 9-patches whose corners carry alpha — the pill never paints
# (verified on UTM + Trixie build #26237565553). We trade the rounded
# corners for SOLID 8×8 terracotta squares: the pill now reads as a
# rectangle, but it actually renders. The full-opaque corners also
# survive whatever downscaling the gfxmenu compositor does on HiDPI.
convert -size 8x8 "xc:${SELECT_COLOR}" -strip "${OUT_DIR}/grub/select_nw.png"
convert -size 8x8 "xc:${SELECT_COLOR}" -strip "${OUT_DIR}/grub/select_ne.png"
convert -size 8x8 "xc:${SELECT_COLOR}" -strip "${OUT_DIR}/grub/select_sw.png"
convert -size 8x8 "xc:${SELECT_COLOR}" -strip "${OUT_DIR}/grub/select_se.png"

for f in c n s e w nw ne sw se; do
    optipng -quiet -o2 "${OUT_DIR}/grub/select_${f}.png" 2>/dev/null || true
done

# ---- Menu card 9-patch (menu_pixmap_style) ---------------------------------
# A subtle darker wash with rounded corners sits BEHIND the whole boot menu,
# creating a "card" feel that contains the list visually without overpowering
# the maroon-lattice wallpaper. Same 9-patch convention as select_*, with a
# larger corner radius (16 px) for a softer look.
#
#   ┌─ menu_nw.png ─ menu_n.png ─ menu_ne.png ─┐
#   │                                          │
#   menu_w.png      menu_c.png        menu_e.png
#   │                                          │
#   └─ menu_sw.png ─ menu_s.png ─ menu_se.png ─┘
#
# Center colour: deep-maroon at 35 % alpha — darkens the lattice without
# washing it out, so the card reads as "this is the menu" rather than
# "this is a different surface".
log "generating GRUB menu card pixmaps ..."
MENU_COLOR='rgba(26,0,0,0.35)'
MENU_RADIUS=16

# Centre (tiled both directions).
convert -size 1x1 "xc:${MENU_COLOR}" \
    -strip "${OUT_DIR}/grub/menu_c.png"

# n / s — full-corner-height vertical slice, tiled horizontally.
convert -size "1x${MENU_RADIUS}" "xc:${MENU_COLOR}" \
    -strip "${OUT_DIR}/grub/menu_n.png"
convert -size "1x${MENU_RADIUS}" "xc:${MENU_COLOR}" \
    -strip "${OUT_DIR}/grub/menu_s.png"

# e / w — full-corner-width horizontal slice, tiled vertically.
convert -size "${MENU_RADIUS}x1" "xc:${MENU_COLOR}" \
    -strip "${OUT_DIR}/grub/menu_e.png"
convert -size "${MENU_RADIUS}x1" "xc:${MENU_COLOR}" \
    -strip "${OUT_DIR}/grub/menu_w.png"

# Rounded corners.
convert -size "${MENU_RADIUS}x${MENU_RADIUS}" xc:transparent -fill "${MENU_COLOR}" \
    -draw "circle ${MENU_RADIUS},${MENU_RADIUS} 0,${MENU_RADIUS}" \
    -strip "${OUT_DIR}/grub/menu_nw.png"
convert -size "${MENU_RADIUS}x${MENU_RADIUS}" xc:transparent -fill "${MENU_COLOR}" \
    -draw "circle 0,${MENU_RADIUS} ${MENU_RADIUS},${MENU_RADIUS}" \
    -strip "${OUT_DIR}/grub/menu_ne.png"
convert -size "${MENU_RADIUS}x${MENU_RADIUS}" xc:transparent -fill "${MENU_COLOR}" \
    -draw "circle ${MENU_RADIUS},0 ${MENU_RADIUS},${MENU_RADIUS}" \
    -strip "${OUT_DIR}/grub/menu_sw.png"
convert -size "${MENU_RADIUS}x${MENU_RADIUS}" xc:transparent -fill "${MENU_COLOR}" \
    -draw "circle 0,0 ${MENU_RADIUS},${MENU_RADIUS}" \
    -strip "${OUT_DIR}/grub/menu_se.png"

for f in c n s e w nw ne sw se; do
    optipng -quiet -o2 "${OUT_DIR}/grub/menu_${f}.png" 2>/dev/null || true
done

# ---- Per-entry icons (24×24, matched by --class in menuentry) --------------
# GRUB renders a small icon to the left of each boot-menu entry. The icon
# file is found by walking the menuentry's --class arguments and looking for
# theme_dir/icons/<class>.png. live-build's grub.cfg sets every entry's
# class to roughly "debian gnu-linux gnu os", so shipping AIMS icons under
# those four names guarantees every entry picks up the same logo without us
# having to rewrite the generated grub.cfg.
log "generating GRUB per-entry icons ..."
mkdir -p "${OUT_DIR}/grub/icons"
ICON_PX=24
ICON_TMP="$(mktemp --suffix=.png)"
# Source: the AIMS circle logo, downscaled with alpha preserved.
convert "${LOGO_CIRCLE}" -resize "${ICON_PX}x${ICON_PX}" -strip "${ICON_TMP}"
for class in debian gnu-linux gnu os; do
    cp "${ICON_TMP}" "${OUT_DIR}/grub/icons/${class}.png"
    optipng -quiet -o2 "${OUT_DIR}/grub/icons/${class}.png" 2>/dev/null || true
done
rm -f "${ICON_TMP}"

# -----------------------------------------------------------------------------
# 4. GDM login screen background
#    Must stay DARK because GNOME's GDM greeter renders the user name and
#    "Not listed?" link in WHITE — there's no dconf/CSS knob to recolor
#    them on Bookworm. White on our cream desktop wallpaper would land at
#    ~1.05:1 contrast (WCAG 1.4.3 AA requires ≥4.5:1; we'd fail
#    catastrophically). The maroon-lattice variant hits ~14:1 against
#    white — comfortably AAA.
#
#    So the GDM greeter + lock screen route through aims-os-greeter-1080p
#    (same maroon-lattice as GRUB, with the AIMS circle centred at 70 %
#    alpha so the pattern still reads through), while the desktop keeps
#    the calm cream wallpaper.
# -----------------------------------------------------------------------------
log "generating GDM greeter background ..."
compose_pattern_with_logo 1920 1080 320 \
    "${OUT_DIR}/wallpapers/aims-os-greeter-1080p.png"

# -----------------------------------------------------------------------------
# 5. Calamares welcome-screen wallpaper
#    Calamares displays productWallpaper as the BACKDROP behind the welcome
#    page's text + wordmark (and around the slideshow). The maroon-lattice
#    desktop wallpaper looks great on the desktop but eats the dark inks of
#    the AIMS wordmark when used here — the welcome page becomes illegible.
#    So Calamares gets its own plain-cream backdrop: the terracotta sidebar
#    (set via branding.desc style) still carries the brand identity, while
#    the content area stays readable.
# -----------------------------------------------------------------------------
log "generating Calamares wallpaper ..."
convert -size 1920x1080 "canvas:${COLOR_BG_CREAM}" \
    -strip "${OUT_DIR}/calamares/aims-os-wallpaper.png"
optipng -quiet -o2 "${OUT_DIR}/calamares/aims-os-wallpaper.png" 2>/dev/null || true

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
