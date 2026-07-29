#!/bin/sh
# =============================================================================
# AIMS OS — post-install script: RStudio Desktop (Posit)
# =============================================================================
# Downloads the official RStudio .deb and verifies its sha256 before
# handing it to apt. Pinned per architecture; bump the versions AND the
# hashes together on each AIMS OS release.
#
#   amd64  stable channel (download1.rstudio.org). The hash comes from
#          Posit's own manifest:
#          https://posit.co/wp-content/uploads/downloads.json
#   arm64  Posit publishes no stable arm64 desktop .deb; the only arm64
#          source is the dailies S3 bucket (https://dailies.rstudio.com/),
#          which ships no checksum. The hash below pins the exact bytes
#          vetted when this build was picked (2026-07-29).
#
# URL gotcha (arm64): the dailies index lists builds under
# noble-${arch}/ directories, but the actual .deb files live under
# jammy/${arch}/ on S3 (Posit only does the jammy build and reuses it
# under the noble label). The path component below is `jammy`.
#
# Run as root:
#   sudo /usr/share/aims-os/install/rstudio.sh
# =============================================================================
set -e

BANNER="[aims-os/install/rstudio]"

if [ "$(id -u)" -ne 0 ]; then
    echo "${BANNER} must run as root (try: sudo $0)" >&2
    exit 1
fi

arch=$(dpkg --print-architecture)
case "${arch}" in
    amd64)
        RSTUDIO_VERSION=2026.07.1-147
        URL="https://download1.rstudio.org/electron/jammy/amd64/rstudio-${RSTUDIO_VERSION}-amd64.deb"
        SHA256="3a130a7209c9c9034c00440aa4b46164bbc5b75c1cf5588c98ef22a236ac1f4b"
        ;;
    arm64)
        RSTUDIO_VERSION=2026.04.1-420
        URL="https://s3.amazonaws.com/rstudio-ide-build/electron/jammy/arm64/rstudio-${RSTUDIO_VERSION}-arm64.deb"
        SHA256="27b05d3e3eda9805c1bc766021c43d851215299513691be0878dc8a4b536ad49"
        ;;
    *)
        echo "${BANNER} arch ${arch} unsupported by RStudio — aborting." >&2
        exit 1
        ;;
esac

echo "${BANNER} downloading RStudio ${RSTUDIO_VERSION} for ${arch}..."

DEB=/tmp/rstudio.deb
curl -fL --retry 5 --retry-delay 5 --retry-all-errors "${URL}" -o "${DEB}"

echo "${SHA256}  ${DEB}" | sha256sum -c - >/dev/null || {
    echo "${BANNER} sha256 MISMATCH on ${URL} — refusing to install." >&2
    rm -f "${DEB}"
    exit 1
}

# apt-get install resolves the heavy GTK / Qt / libssl deps.
DEBIAN_FRONTEND=noninteractive apt-get install -y "${DEB}"
rm -f "${DEB}"

echo "${BANNER} RStudio ${RSTUDIO_VERSION} installed."
