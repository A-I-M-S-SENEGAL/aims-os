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
