#!/bin/bash
# =============================================================================
# AIMS OS — derived branding asset generator
# =============================================================================
# Reads the two source images:
#     branding/source/aims_circle.png   (563×563 RGBA — the round logo)
#     branding/source/logo-aims.png     (1164×214 RGBA — the wordmark)
#
# Produces every PNG the build process needs (wallpapers, Plymouth assets,
# GRUB background, GNOME application icons, GDM banner) and writes them
# under branding/generated/.
#
# Runs INSIDE the aims-os-builder container (where ImageMagick 6 and
# optipng live). Invoke from the host via:
#     docker run --rm --platform linux/arm64 \
#         -v "$PWD:/build:delegated" \
#         aims-os-builder:arm64 bash /build/branding/generate-assets.sh
#
# The generated/ directory is NOT in git — it is reproducible from the
# two source PNGs and this script. Anyone with the repo can regenerate
# every asset deterministically.
# =============================================================================

set -euo pipefail

# -----------------------------------------------------------------------------
# Brand palette — single source of truth
# -----------------------------------------------------------------------------
COLOR_BRAND_PRIMARY="#803018"   # logo strokes — extracted from the source PNG
COLOR_BRAND_ACCENT="#A0392E"    # lighter terracotta — UI accents, progress bar
COLOR_BG_CREAM="#F5EFE7"        # global light background
COLOR_TEXT_DARK="#1A1A1A"       # primary text on cream
COLOR_TEXT_MUTED="#666666"      # secondary text

# -----------------------------------------------------------------------------
# Paths
# -----------------------------------------------------------------------------
REPO_ROOT="${REPO_ROOT:-/build}"
SRC_DIR="${REPO_ROOT}/branding/source"
OUT_DIR="${REPO_ROOT}/branding/generated"

LOGO_CIRCLE="${SRC_DIR}/aims_circle.png"
LOGO_WORDMARK="${SRC_DIR}/logo-aims.png"

# -----------------------------------------------------------------------------
# Logging
# -----------------------------------------------------------------------------
BANNER='\033[1;35m[aims-os/branding]\033[0m'
log()  { printf '%b %s\n' "${BANNER}" "$*"; }
fail() { printf '%b \033[1;31mERROR:\033[0m %s\n' "${BANNER}" "$*" >&2; exit 1; }

# -----------------------------------------------------------------------------
# Pre-flight
# -----------------------------------------------------------------------------
command -v convert >/dev/null   || fail "ImageMagick not in PATH (apt install imagemagick)"
[[ -f "${LOGO_CIRCLE}"   ]]     || fail "missing ${LOGO_CIRCLE}"
[[ -f "${LOGO_WORDMARK}" ]]     || fail "missing ${LOGO_WORDMARK}"

# Read source dimensions so we know what we're starting from.
src_circle_dim="$(identify -format '%wx%h' "${LOGO_CIRCLE}")"
src_wordmark_dim="$(identify -format '%wx%h' "${LOGO_WORDMARK}")"
log "source circle:   ${src_circle_dim}"
log "source wordmark: ${src_wordmark_dim}"

mkdir -p \
    "${OUT_DIR}/wallpapers" \
    "${OUT_DIR}/plymouth" \
    "${OUT_DIR}/grub" \
    "${OUT_DIR}/icons" \
    "${OUT_DIR}/gdm"

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

# -----------------------------------------------------------------------------
# 1. Wallpapers
#    1080p + 4K, cream background, logo centred at a comfortable 320 px
#    (looks small but elegant on a 1080p screen; scales naturally to 4K).
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

# A 4-px-tall progress bar in the accent terracotta, on cream. The Plymouth
# script will crop a horizontal slice of this at runtime.
convert -size 600x4 "xc:${COLOR_BRAND_ACCENT}" \
    -strip "${OUT_DIR}/plymouth/progress-bar-fg.png"
convert -size 600x4 "xc:#E6D8C8" \
    -strip "${OUT_DIR}/plymouth/progress-bar-bg.png"

# -----------------------------------------------------------------------------
# 3. GRUB background
#    1920×1080. Cream background, circle logo top-centred at 200 px, the
#    wordmark below it at a reasonable width. The boot menu renders on top
#    of this so we leave the lower 60% mostly clear.
# -----------------------------------------------------------------------------
log "generating GRUB background ..."
convert -size 1920x1080 "canvas:${COLOR_BG_CREAM}" \
    \( "${LOGO_CIRCLE}"   -resize 200x200 \) -gravity north -geometry +0+80  -composite \
    \( "${LOGO_WORDMARK}" -resize 600x110 \) -gravity north -geometry +0+310 -composite \
    -strip "${OUT_DIR}/grub/background.png"
optipng -quiet -o2 "${OUT_DIR}/grub/background.png" 2>/dev/null || true

# -----------------------------------------------------------------------------
# 4. GDM login screen background (same as wallpaper for now)
# -----------------------------------------------------------------------------
log "generating GDM background ..."
cp "${OUT_DIR}/wallpapers/aims-os-default-1080p.png" "${OUT_DIR}/gdm/background.png"

# -----------------------------------------------------------------------------
# 5. Application launcher icons (sizes per freedesktop icon-theme spec)
# -----------------------------------------------------------------------------
log "generating app icons ..."
for size in 16 24 32 48 64 96 128 256 512; do
    mkdir -p "${OUT_DIR}/icons/${size}x${size}"
    resize_keep_alpha "${LOGO_CIRCLE}" "${size}" \
        "${OUT_DIR}/icons/${size}x${size}/aims-os-logo.png"
done

# -----------------------------------------------------------------------------
# 6. Inventory & summary
# -----------------------------------------------------------------------------
log "done — generated assets:"
( cd "${OUT_DIR}" && find . -type f -name '*.png' | sort | while read -r f; do
    dim="$(identify -format '%wx%h' "${f}")"
    size="$(du -h "${f}" | cut -f1)"
    printf '  %-50s %s  %s\n' "${f#./}" "${dim}" "${size}"
done )
