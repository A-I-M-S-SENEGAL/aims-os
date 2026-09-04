#!/bin/bash
# =============================================================================
# AIMS OS — stage the aims-os-branding payload
# =============================================================================
# Renders branding/generated/ from branding/source/ (generate-assets.sh)
# and copies everything the aims-os-branding metapackage ships into
# metapackages/aims-os-branding/files/, so a plain dpkg-buildpackage
# produces a self-contained .deb.
#
# Used by two callers:
#   build/build-metapackages.sh   inside the aims-os-builder container,
#                                 before the live-build ISO run
#   apt-repo/build-debs.sh        on the GitHub runner that publishes the
#                                 apt repo (imagemagick, librsvg2-bin and
#                                 optipng are installed by the workflow)
#
# Needs: convert (ImageMagick 6), rsvg-convert, optipng.
# files/ is .gitignore'd — nothing staged here leaks into git.
# =============================================================================
set -euo pipefail

REPO_ROOT="${REPO_ROOT:-$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)}"
export REPO_ROOT

BANNER='\033[1;35m[aims-os/branding]\033[0m'
log()  { printf '%b %s\n' "${BANNER}" "$*"; }
fail() { printf '%b \033[1;31mERROR:\033[0m %s\n' "${BANNER}" "$*" >&2; exit 1; }

for tool in convert rsvg-convert optipng; do
    command -v "${tool}" >/dev/null || fail "${tool} not in PATH (apt install imagemagick librsvg2-bin optipng)"
done

stage_branding_payload() {
    BRAND_DIR="${REPO_ROOT}/branding"
    FILES_DIR="${REPO_ROOT}/metapackages/aims-os-branding/files"

    log "regenerating branding/generated/ via generate-assets.sh ..."
    bash "${BRAND_DIR}/generate-assets.sh" >/dev/null

    log "staging branding payload into aims-os-branding/files/ ..."
    rm -rf "${FILES_DIR}"
    mkdir -p \
        "${FILES_DIR}/usr/share/backgrounds/aims-os" \
        "${FILES_DIR}/usr/share/plymouth/themes/aims-os" \
        "${FILES_DIR}/usr/share/grub/themes/aims-os" \
        "${FILES_DIR}/usr/share/gnome-background-properties" \
        "${FILES_DIR}/usr/share/icons/hicolor" \
        "${FILES_DIR}/usr/lib/aims-os" \
        "${FILES_DIR}/etc/calamares/branding/aims-os"

    # ---- Wallpapers ----
    # aims-os-default-*.png  → calm cream wallpaper for the GNOME desktop.
    # aims-os-greeter-1080p  → maroon-lattice variant used by hook 0065 to
    #                          re-skin the GDM greeter + lock screen. Kept
    #                          dark so the white GNOME login text passes
    #                          WCAG AAA contrast (cream + white = ~1.05:1,
    #                          which would fail AA).
    cp "${BRAND_DIR}/generated/wallpapers/aims-os-default-1080p.png" \
       "${FILES_DIR}/usr/share/backgrounds/aims-os/"
    cp "${BRAND_DIR}/generated/wallpapers/aims-os-default-4k.png" \
       "${FILES_DIR}/usr/share/backgrounds/aims-os/"
    cp "${BRAND_DIR}/generated/wallpapers/aims-os-greeter-1080p.png" \
       "${FILES_DIR}/usr/share/backgrounds/aims-os/"
    # aims-os-default-dark-*  → dark-style twins, picked by GNOME when the
    #                            user switches to the dark appearance.
    cp "${BRAND_DIR}/generated/wallpapers/aims-os-default-dark-1080p.png" \
       "${FILES_DIR}/usr/share/backgrounds/aims-os/"
    cp "${BRAND_DIR}/generated/wallpapers/aims-os-default-dark-4k.png" \
       "${FILES_DIR}/usr/share/backgrounds/aims-os/"

    # ---- dconf defaults owned by the package (background light/dark) ----
    # Later files in local.d override earlier ones, so this wins over the
    # ISO's 00-aims-os and also reaches machines installed from older ISOs.
    mkdir -p "${FILES_DIR}/etc/dconf/db/local.d"
    cp "${BRAND_DIR}/dconf/01-aims-os-branding" \
       "${FILES_DIR}/etc/dconf/db/local.d/"

    # ---- Plymouth (text + images) ----
    cp "${BRAND_DIR}/plymouth/aims-os.plymouth"   \
       "${FILES_DIR}/usr/share/plymouth/themes/aims-os/"
    cp "${BRAND_DIR}/plymouth/aims-os.script"     \
       "${FILES_DIR}/usr/share/plymouth/themes/aims-os/"
    cp "${BRAND_DIR}/generated/plymouth/aims-circle.png"     \
       "${FILES_DIR}/usr/share/plymouth/themes/aims-os/"
    # 30 pre-rendered rotation frames (ring-0.png .. ring-29.png), flat in
    # the theme directory so Image("ring-N.png") resolves via ImageDir.
    cp "${BRAND_DIR}/generated/plymouth/ring/ring-"*.png \
       "${FILES_DIR}/usr/share/plymouth/themes/aims-os/"

    # ---- GRUB (installed-system theme — same files as the live-ISO theme) ----
    cp "${BRAND_DIR}/grub/theme.txt"                   \
       "${FILES_DIR}/usr/share/grub/themes/aims-os/"
    cp "${BRAND_DIR}/generated/grub/background.png"    \
       "${FILES_DIR}/usr/share/grub/themes/aims-os/"
    for f in c n s e w nw ne sw se; do
        cp "${BRAND_DIR}/generated/grub/select_${f}.png" \
           "${FILES_DIR}/usr/share/grub/themes/aims-os/"
    done

    # ---- GNOME wallpaper picker manifest ----
    cp "${BRAND_DIR}/wallpapers/aims-os.xml" \
       "${FILES_DIR}/usr/share/gnome-background-properties/"

    # ---- Hicolor icons (9 sizes for app/system icon discovery) ----
    for size in 16 24 32 48 64 96 128 256 512; do
        mkdir -p "${FILES_DIR}/usr/share/icons/hicolor/${size}x${size}/apps"
        cp "${BRAND_DIR}/generated/icons/${size}x${size}/aims-os-logo.png" \
           "${FILES_DIR}/usr/share/icons/hicolor/${size}x${size}/apps/"
    done

    # ---- Vendor logos + emblems (desktop-base "vendor-logos" alternative) ----
    # Registered at priority 100 by /usr/lib/aims-os/debrand (postinst).
    mkdir -p "${FILES_DIR}/usr/share/aims-os/vendor-logos" \
             "${FILES_DIR}/usr/share/icons/aims-os"
    cp "${BRAND_DIR}/generated/vendor/vendor-logos/"* \
       "${FILES_DIR}/usr/share/aims-os/vendor-logos/"
    cp -R "${BRAND_DIR}/generated/vendor/emblems/." \
          "${FILES_DIR}/usr/share/icons/aims-os/"
    # The debranding script itself (alternatives, wallpaper picker, perms).
    install -m 0755 "${BRAND_DIR}/debrand.sh" "${FILES_DIR}/usr/lib/aims-os/debrand"

    # ---- Identity files (os-release + lsb-release) ----
    cp "${BRAND_DIR}/os-release/os-release"  "${FILES_DIR}/usr/lib/aims-os/"
    cp "${BRAND_DIR}/os-release/lsb-release" "${FILES_DIR}/usr/lib/aims-os/"

    # ---- Calamares branding ----
    # Combines the static branding files we maintain in-tree (branding.desc,
    # show.qml, logo + welcome image, slides/ photos) with the wallpaper
    # rasterised by generate-assets.sh. /etc/calamares/branding/aims-os/ is
    # what hook 0085 tells Calamares to load — see
    # build/config/hooks/normal/0085-*.
    cp "${BRAND_DIR}/calamares/branding/aims-os/branding.desc"      \
       "${FILES_DIR}/etc/calamares/branding/aims-os/"
    cp "${BRAND_DIR}/calamares/branding/aims-os/show.qml"           \
       "${FILES_DIR}/etc/calamares/branding/aims-os/"
    cp "${BRAND_DIR}/calamares/branding/aims-os/aims-os-logo.png"   \
       "${FILES_DIR}/etc/calamares/branding/aims-os/"
    cp "${BRAND_DIR}/calamares/branding/aims-os/aims-os-welcome.png" \
       "${FILES_DIR}/etc/calamares/branding/aims-os/"
    cp "${BRAND_DIR}/generated/calamares/aims-os-wallpaper.png"     \
       "${FILES_DIR}/etc/calamares/branding/aims-os/"
    # show.qml references slides via the relative path "slides/slide-N-*.jpg",
    # so the directory must land at /etc/calamares/branding/aims-os/slides/
    # next to show.qml — same layout the upstream Calamares default uses.
    mkdir -p "${FILES_DIR}/etc/calamares/branding/aims-os/slides"
    cp "${BRAND_DIR}/calamares/branding/aims-os/slides/"*.jpg       \
       "${FILES_DIR}/etc/calamares/branding/aims-os/slides/"

    n=""
    n="$(find "${FILES_DIR}" -type f | wc -l | tr -d ' ')"
    log "staged ${n} files under aims-os-branding/files/"
}

stage_branding_payload
