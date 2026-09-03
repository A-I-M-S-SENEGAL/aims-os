#!/bin/bash
# =============================================================================
# AIMS OS — metapackage builder (runs INSIDE the aims-os-builder container)
# =============================================================================
# This script compiles every Debian source package under metapackages/
# (the whole aims-os-* set: core, desktop, math, branding, welcome, the
# extras / dev / track layers) into binary .debs and moves the results
# into build/config/packages.chroot/, the directory live-build watches
# for local packages to install during its chroot stage.
#
# It is invoked by build/build.sh (via `docker_run "${arch}" bash
# /build/build/build-metapackages.sh`) right before `lb config && lb
# build`, so the AIMS OS metapackages are present when live-build
# runs apt inside the chroot. Which of them actually land on the ISO
# is decided by build/config/package-lists/30-aims-os.list.chroot.
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
# Stage the aims-os-branding payload (render branding/generated/ and copy
# everything the metapackage ships into metapackages/aims-os-branding/files/).
# Shared with apt-repo/build-debs.sh — see branding/stage-payload.sh.
# -----------------------------------------------------------------------------
log "staging aims-os-branding payload ..."
REPO_ROOT="${REPO_ROOT}" bash "${REPO_ROOT}/branding/stage-payload.sh"

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

    # The theme itself + the assets it references.
    # The AIMS logo + brand text are BAKED into background.png at
    # build time (see branding/generate-assets.sh) — no separate
    # info.png is shipped because grub-efi-arm64's `+ image` element
    # rendering path corrupts PNGs into rainbow noise.
    cp "${BRAND_DIR}/grub/theme.txt"                "${BOOT_DIR}/live-theme/theme.txt"
    cp "${BRAND_DIR}/generated/grub/background.png" "${BOOT_DIR}/live-theme/background.png"
    # 9-patch selection pill (terracotta) — drawn behind the focused row.
    for f in c n s e w nw ne sw se; do
        cp "${BRAND_DIR}/generated/grub/select_${f}.png" \
           "${BOOT_DIR}/live-theme/select_${f}.png"
    done
    # 9-patch menu card (semi-transparent maroon, rounded 16-px corners)
    # — drawn behind the whole boot menu so it reads as a contained list.
    for f in c n s e w nw ne sw se; do
        cp "${BRAND_DIR}/generated/grub/menu_${f}.png" \
           "${BOOT_DIR}/live-theme/menu_${f}.png"
    done
    # Per-entry icons (24×24 AIMS logo, one PNG per --class the live-build
    # grub.cfg sets on each menuentry — debian/gnu-linux/gnu/os). GRUB walks
    # the class list at render time and shows the first matching icon.
    mkdir -p "${BOOT_DIR}/live-theme/icons"
    cp "${BRAND_DIR}/generated/grub/icons/"*.png \
       "${BOOT_DIR}/live-theme/icons/"

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
# live-build auto-installs EVERY .deb found in config/packages.chroot/
# into the chroot — it is an install list, not a package pool. Staging
# all 12 metapackages there is what silently turned the v2.1 "slim"
# ISO into a 7.7 GB full install (aims-os-everything then pulled every
# layer in as hard Depends). The authoritative list of what belongs on
# the ISO is the live-build package list; everything else is built and
# linted above but ships through the apt repo only.
ISO_LIST="${REPO_ROOT}/build/config/package-lists/30-aims-os.list.chroot"
iso_pkgs="$(grep -vE '^[[:space:]]*(#|$)' "${ISO_LIST}")"

log "staging ISO debs into ${PKG_DEST} (list: $(basename "${ISO_LIST}")) ..."
for pkg in ${iso_pkgs}; do
    mv "${METAPKG_DIR}/${pkg}"_*_all.deb "${PKG_DEST}/"
done

excluded="$(cd "${METAPKG_DIR}" && ls -1 aims-os-*_*.deb 2>/dev/null || true)"
if [[ -n "${excluded}" ]]; then
    log "apt-repo-only, NOT staged into the ISO:"
    printf '%s\n' "${excluded}" | sed 's/^/    /'
fi
( cd "${METAPKG_DIR}" && rm -f -- *.deb *.buildinfo *.changes )

deb_count="$(find "${PKG_DEST}" -maxdepth 1 -name 'aims-os-*.deb' | wc -l | tr -d ' ')"
log "done — ${deb_count} ISO debs ready in build/config/packages.chroot/"
ls -1 "${PKG_DEST}"
