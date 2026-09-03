#!/usr/bin/env bash
# =============================================================================
# AIMS OS — build all metapackage .deb files
# =============================================================================
# Walks every metapackages/aims-os-*/ directory and runs dpkg-buildpackage on
# it. Metapackages have no payload, so the build is fast (~5s per package)
# and needs only debhelper-compat + standard build-essential — no chroot.
#
# Produces .deb files next to each source dir (debhelper writes one level up).
# We then collect them into ${OUT_DIR}.
#
# Usage:
#   ./apt-repo/build-debs.sh                # outputs to apt-repo/out/
#   OUT_DIR=/tmp/debs ./apt-repo/build-debs.sh
# =============================================================================
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
METAPKG_DIR="${REPO_ROOT}/metapackages"
OUT_DIR="${OUT_DIR:-${REPO_ROOT}/apt-repo/out}"

BANNER='\033[1;34m[aims-os/apt-repo]\033[0m'
log() { printf '%b %s\n' "${BANNER}" "$*"; }

log "cleaning previous build artifacts..."
mkdir -p "${OUT_DIR}"
rm -f "${OUT_DIR}"/*.deb "${OUT_DIR}"/*.changes "${OUT_DIR}"/*.buildinfo

for pkg_dir in "${METAPKG_DIR}"/aims-os-*/; do
    pkg_name=$(basename "${pkg_dir}")

    # aims-os-branding ships a generated payload (wallpapers, GRUB theme,
    # Plymouth assets, Calamares branding) rendered from branding/source/*
    # by branding/stage-payload.sh. That needs ImageMagick, librsvg and
    # optipng; the publish / test workflows install them. Without the
    # toolchain (a bare developer box) the package is skipped rather than
    # shipped empty.
    if [ "${pkg_name}" = "aims-os-branding" ]; then
        if command -v convert >/dev/null && command -v rsvg-convert >/dev/null && command -v optipng >/dev/null; then
            log "staging ${pkg_name} payload (render pipeline)..."
            REPO_ROOT="${REPO_ROOT}" bash "${REPO_ROOT}/branding/stage-payload.sh" >/dev/null
        else
            log "skipping ${pkg_name} (imagemagick / librsvg2-bin / optipng not installed)"
            continue
        fi
    fi

    log "building ${pkg_name}..."
    (
        cd "${pkg_dir}"
        # --no-sign : apt-ftparchive's Release file is what gets signed
        #             downstream, no need to sign the .deb itself.
        # -b        : binary-only build.
        dpkg-buildpackage --no-sign -b 2>&1 | tail -5
    )
done

log "collecting .deb files into ${OUT_DIR}..."
find "${METAPKG_DIR}" -maxdepth 1 -name 'aims-os-*_*.deb' -exec mv {} "${OUT_DIR}/" \;
find "${METAPKG_DIR}" -maxdepth 1 \( -name '*.changes' -o -name '*.buildinfo' \) -delete

deb_count=$(find "${OUT_DIR}" -maxdepth 1 -name 'aims-os-*.deb' | wc -l | tr -d ' ')
log "done — ${deb_count} .deb file(s) in ${OUT_DIR}"
ls -lh "${OUT_DIR}"/*.deb
