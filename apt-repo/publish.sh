#!/usr/bin/env bash
# =============================================================================
# AIMS OS — build the apt repo tree from .deb files and sign it
# =============================================================================
# Reads .deb files from ${DEBS_DIR} and produces a publishable apt repo
# structure under ${REPO_DIR}:
#
#   ${REPO_DIR}/
#     pubkey.gpg                       # AIMS OS Repository public key
#     dists/trixie/
#       Release                        # repo metadata
#       Release.gpg                    # detached GPG signature
#       InRelease                      # clear-signed Release (modern apt)
#       main/binary-{all,amd64,arm64}/
#         Packages                     # apt-ftparchive output
#         Packages.gz
#     pool/main/<initial>/<pkg>/
#       <pkg>_<version>_all.deb
#
# Signing uses the key identified by ${GPG_KEY_ID}; we expect that key to
# be already imported into gpg before this runs (CI imports it from the
# AIMS_GPG_PRIVATE_KEY secret).
#
# Usage:
#   GPG_KEY_ID=CEAB168E6D2E30FF ./apt-repo/publish.sh
# =============================================================================
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
DEBS_DIR="${DEBS_DIR:-${REPO_ROOT}/apt-repo/out}"
REPO_DIR="${REPO_DIR:-${REPO_ROOT}/apt-repo/site}"
SUITE="${SUITE:-trixie}"
COMPONENT="${COMPONENT:-main}"
GPG_KEY_ID="${GPG_KEY_ID:-CEAB168E6D2E30FF}"
ORIGIN="${ORIGIN:-AIMS Senegal}"
LABEL="${LABEL:-AIMS OS}"
DESCRIPTION="${DESCRIPTION:-AIMS OS metapackages for Debian Trixie}"

BANNER='\033[1;34m[aims-os/apt-repo]\033[0m'
log()  { printf '%b %s\n' "${BANNER}" "$*"; }
die()  { printf '%b ERROR: %s\n' "${BANNER}" "$*" >&2; exit 1; }

[ -d "${DEBS_DIR}" ] || die "DEBS_DIR ${DEBS_DIR} not found"
[ "$(find "${DEBS_DIR}" -maxdepth 1 -name 'aims-os-*.deb' | wc -l | tr -d ' ')" -gt 0 ] \
    || die "no .deb files in ${DEBS_DIR}"

# -----------------------------------------------------------------------------
# Clean previous tree, rebuild structure.
# -----------------------------------------------------------------------------
log "(re)building repo tree at ${REPO_DIR}/"
rm -rf "${REPO_DIR}"
mkdir -p "${REPO_DIR}/dists/${SUITE}/${COMPONENT}"/binary-{all,amd64,arm64} \
         "${REPO_DIR}/pool/${COMPONENT}"

# Move .debs into pool/<component>/<initial>/<package>/<name>.deb
for deb in "${DEBS_DIR}"/aims-os-*.deb; do
    pkg=$(basename "${deb}" | cut -d_ -f1)
    initial=${pkg:0:1}
    dest="${REPO_DIR}/pool/${COMPONENT}/${initial}/${pkg}"
    mkdir -p "${dest}"
    cp "${deb}" "${dest}/"
done

# -----------------------------------------------------------------------------
# Generate per-arch Packages indexes.
# All our metapackages are Architecture: all, so the same .deb shows up under
# binary-all (canonical) AND under binary-amd64/binary-arm64 (so clients that
# only scan their arch find them). apt-ftparchive does the right thing
# automatically when given a list with multiple --arch passes.
# -----------------------------------------------------------------------------
for arch in all amd64 arm64; do
    log "indexing ${COMPONENT}/binary-${arch}/Packages..."
    (
        cd "${REPO_DIR}"
        apt-ftparchive --arch "${arch}" packages "pool/${COMPONENT}" \
            > "dists/${SUITE}/${COMPONENT}/binary-${arch}/Packages"
        gzip -k -9 -f "dists/${SUITE}/${COMPONENT}/binary-${arch}/Packages"
    )
done

# -----------------------------------------------------------------------------
# Release file (top of dist).
# -----------------------------------------------------------------------------
log "generating dists/${SUITE}/Release..."
cat > "${REPO_DIR}/apt-ftparchive-release.conf" <<EOF
APT::FTPArchive::Release::Origin "${ORIGIN}";
APT::FTPArchive::Release::Label "${LABEL}";
APT::FTPArchive::Release::Suite "${SUITE}";
APT::FTPArchive::Release::Codename "${SUITE}";
APT::FTPArchive::Release::Architectures "all amd64 arm64";
APT::FTPArchive::Release::Components "${COMPONENT}";
APT::FTPArchive::Release::Description "${DESCRIPTION}";
EOF

(
    cd "${REPO_DIR}"
    apt-ftparchive -c=apt-ftparchive-release.conf release "dists/${SUITE}" \
        > "dists/${SUITE}/Release"
)
rm "${REPO_DIR}/apt-ftparchive-release.conf"

# -----------------------------------------------------------------------------
# Sign: produce both Release.gpg (detached) and InRelease (clear-signed).
# Modern apt prefers InRelease; older versions fall back to Release + Release.gpg.
# -----------------------------------------------------------------------------
log "signing Release with GPG key ${GPG_KEY_ID}..."
gpg --batch --yes --default-key "${GPG_KEY_ID}" \
    --output "${REPO_DIR}/dists/${SUITE}/Release.gpg" \
    --detach-sign --armor "${REPO_DIR}/dists/${SUITE}/Release"
gpg --batch --yes --default-key "${GPG_KEY_ID}" \
    --output "${REPO_DIR}/dists/${SUITE}/InRelease" \
    --clearsign "${REPO_DIR}/dists/${SUITE}/Release"

# -----------------------------------------------------------------------------
# Public key in dearmoured (binary) form — what the install instructions point
# users to wget. We ship the armored .gpg too for convenience.
# -----------------------------------------------------------------------------
log "exporting public key into repo root..."
gpg --export "${GPG_KEY_ID}" > "${REPO_DIR}/aims-os-archive-keyring.gpg"
cp "${REPO_ROOT}/apt-repo/aims-os-pubkey.gpg" "${REPO_DIR}/aims-os-pubkey.asc"

log "done — repo tree ready at ${REPO_DIR}"
echo ""
find "${REPO_DIR}" -maxdepth 4 -type f | sort | sed "s|${REPO_DIR}/|  |"
