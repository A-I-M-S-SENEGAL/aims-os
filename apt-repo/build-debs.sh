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
    log "building ${pkg_name}..."

    (
        cd "${pkg_dir}"
        # -us -uc : skip signing here; apt-ftparchive's Release file is what
        #           gets signed downstream. -b : binary-only.
        dpkg-buildpackage --no-sign -b 2>&1 | tail -5
    )
done

log "collecting .deb files into ${OUT_DIR}..."
find "${METAPKG_DIR}" -maxdepth 1 -name 'aims-os-*_*.deb' -exec mv {} "${OUT_DIR}/" \;
find "${METAPKG_DIR}" -maxdepth 1 \( -name '*.changes' -o -name '*.buildinfo' \) -delete

deb_count=$(find "${OUT_DIR}" -maxdepth 1 -name 'aims-os-*.deb' | wc -l | tr -d ' ')
log "done — ${deb_count} .deb file(s) in ${OUT_DIR}"
ls -lh "${OUT_DIR}"/*.deb
