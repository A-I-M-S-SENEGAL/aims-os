#!/bin/bash
# =============================================================================
# AIMS OS — metapackage builder (runs INSIDE the aims-os-builder container)
# =============================================================================
# This script compiles each Debian source package under metapackages/
# (aims-os-core, aims-os-desktop, aims-os-math, aims-os-branding) into a
# binary .deb and moves the result into build/config/packages.chroot/,
# the directory live-build watches for local packages to install during
# its chroot stage.
#
# It is invoked by build/build.sh (via `docker_run "${arch}" bash
# /build/build/build-metapackages.sh`) right before `lb config && lb
# build`, so the four AIMS OS metapackages are present when live-build
# runs apt inside the chroot.
#
# Paths assume the repo root is bind-mounted at /build inside the
# container (the layout that build/build.sh sets up).
# =============================================================================

set -euo pipefail

REPO_ROOT="${REPO_ROOT:-/build}"
METAPKG_DIR="${REPO_ROOT}/metapackages"
PKG_DEST="${REPO_ROOT}/build/config/packages.chroot"

BANNER='\033[1;34m[aims-os/metapkg]\033[0m'
log()  { printf '%b %s\n'  "${BANNER}" "$*"; }
fail() { printf '%b \033[1;31mERROR:\033[0m %s\n' "${BANNER}" "$*" >&2; exit 1; }

[[ -d "${METAPKG_DIR}" ]] \
    || fail "metapackages directory not found at ${METAPKG_DIR}"

mkdir -p "${PKG_DEST}"

# -----------------------------------------------------------------------------
# Stage aims-os-branding payload from branding/{source,generated} into
# metapackages/aims-os-branding/files/ before the build runs.
#
# Reason: a Debian source package must be self-contained. We keep the
# branding artefacts (logos, generated wallpapers, Plymouth theme) at
# the project root rather than duplicating them under each metapackage,
# so we copy them into place at build time. The files/ directory is
# .gitignore'd; nothing here leaks into git.
# -----------------------------------------------------------------------------
stage_branding_payload() {
    local BRAND_DIR="${REPO_ROOT}/branding"
    local FILES_DIR="${METAPKG_DIR}/aims-os-branding/files"

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

    # ---- Plymouth (text + images) ----
    cp "${BRAND_DIR}/plymouth/aims-os.plymouth"   \
       "${FILES_DIR}/usr/share/plymouth/themes/aims-os/"
    cp "${BRAND_DIR}/plymouth/aims-os.script"     \
       "${FILES_DIR}/usr/share/plymouth/themes/aims-os/"
    cp "${BRAND_DIR}/generated/plymouth/aims-circle.png"     \
       "${FILES_DIR}/usr/share/plymouth/themes/aims-os/"
    cp "${BRAND_DIR}/generated/plymouth/ray-ring.png"        \
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

    local n
    n="$(find "${FILES_DIR}" -type f | wc -l | tr -d ' ')"
    log "staged ${n} files under aims-os-branding/files/"
}

stage_branding_payload

# -----------------------------------------------------------------------------
# Stage the live-ISO GRUB theme into build/config/bootloaders/grub-pc/.
#
# live-build copies that directory verbatim into the binary stage and uses
# it to override the upstream Debian splash + theme files (which would
# otherwise leave the live boot screen looking like a plain Debian
# install). The layout we ship:
#
#     splash.png                  → triggers theme load via theme.cfg
#     live-theme/theme.txt        → our GRUB theme (palette, menu, labels)
#     live-theme/background.png   → referenced by theme.txt's desktop-image
#     live-theme/select_*.png     → 9-patch selection pixmap (9 files)
#
# splash.png and live-theme/background.png are the SAME image — duplicated
# because live-build's theme.cfg requires /boot/grub/splash.png to exist to
# enable the theme, while theme.txt independently expects background.png
# next to it. Disk cost is ~300 KB; not worth a symlink dance.
# -----------------------------------------------------------------------------
stage_live_grub_theme() {
    local BRAND_DIR="${REPO_ROOT}/branding"
    local BOOT_DIR="${REPO_ROOT}/build/config/bootloaders/grub-pc"

    log "staging live-ISO GRUB theme into config/bootloaders/grub-pc/ ..."
    rm -rf "${BOOT_DIR}"
    mkdir -p "${BOOT_DIR}/live-theme"

    # Splash (triggers theme.cfg's "use theme" branch)
    cp "${BRAND_DIR}/generated/grub/background.png" "${BOOT_DIR}/splash.png"

    # The theme itself + the assets it references
    cp "${BRAND_DIR}/grub/theme.txt"                "${BOOT_DIR}/live-theme/theme.txt"
    cp "${BRAND_DIR}/generated/grub/background.png" "${BOOT_DIR}/live-theme/background.png"
    for f in c n s e w nw ne sw se; do
        cp "${BRAND_DIR}/generated/grub/select_${f}.png" \
           "${BOOT_DIR}/live-theme/select_${f}.png"
    done

    local n
    n="$(find "${BOOT_DIR}" -type f | wc -l | tr -d ' ')"
    log "staged ${n} files under build/config/bootloaders/grub-pc/"
}

stage_live_grub_theme

# -----------------------------------------------------------------------------
# Clean any leftover build artifacts so we always produce fresh debs.
# -----------------------------------------------------------------------------
log "cleaning previous build artifacts ..."
( cd "${METAPKG_DIR}" && rm -f -- *.deb *.buildinfo *.changes )
for pkg_dir in "${METAPKG_DIR}"/aims-os-*/; do
    ( cd "${pkg_dir}" && dh_clean >/dev/null 2>&1 || true )
done
( cd "${PKG_DEST}" && rm -f -- *.deb )

# -----------------------------------------------------------------------------
# Build each metapackage in source-name order. The order doesn't matter
# functionally (apt resolves Depends at install time) but is stable for
# reproducible logs.
# -----------------------------------------------------------------------------
built_count=0
for pkg_dir in "${METAPKG_DIR}"/aims-os-*/; do
    pkg="$(basename "${pkg_dir}")"
    log "building ${pkg} ..."
    (
        cd "${pkg_dir}"
        dpkg-buildpackage --build=binary --unsigned-source --unsigned-changes \
            2>&1 | grep -E '^(dpkg-deb: building|dpkg-buildpackage: (info|error))' || true
    )
    built_count=$((built_count + 1))
done
log "built ${built_count} metapackages"

# -----------------------------------------------------------------------------
# Lint everything before shipping.
# -----------------------------------------------------------------------------
log "running lintian on the produced debs ..."
lintian_findings="$(
    cd "${METAPKG_DIR}" \
        && lintian aims-os-*_*.deb 2>&1 | grep -vE 'running with root|^$' || true
)"
if [[ -n "${lintian_findings}" ]]; then
    printf '%b lintian findings:\n%s\n' "${BANNER}" "${lintian_findings}" >&2
else
    log "lintian: 0 findings on every deb"
fi

# -----------------------------------------------------------------------------
# Stage the debs where live-build expects them, and drop the noise.
# -----------------------------------------------------------------------------
log "staging debs into ${PKG_DEST} ..."
mv "${METAPKG_DIR}"/aims-os-*_*.deb "${PKG_DEST}/"
( cd "${METAPKG_DIR}" && rm -f -- *.buildinfo *.changes )

deb_count="$(find "${PKG_DEST}" -maxdepth 1 -name 'aims-os-*.deb' | wc -l | tr -d ' ')"
log "done — ${deb_count} debs ready in build/config/packages.chroot/"
ls -1 "${PKG_DEST}"
