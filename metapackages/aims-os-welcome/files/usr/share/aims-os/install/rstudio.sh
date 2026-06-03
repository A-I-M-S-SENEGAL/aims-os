#!/bin/sh
# =============================================================================
# AIMS OS — post-install script: RStudio Desktop (Posit)
# =============================================================================
# Downloads the official RStudio .deb directly from Posit's S3 bucket.
# Pinned to a known-good build; bump RSTUDIO_VERSION on each AIMS OS
# release.
#
# URL gotcha: Posit's dailies index lists builds under noble-${arch}/
# directories, but the actual .deb files live under jammy/${arch}/ on
# S3 (Posit only does the jammy build and reuses it under the noble
# label). The path component below is `jammy`.
#
# Reference: https://dailies.rstudio.com/
#
# Run as root:
#   sudo /usr/share/aims-os/install/rstudio.sh
# =============================================================================
set -e

BANNER="[aims-os/install/rstudio]"
RSTUDIO_VERSION=2026.04.1-420

if [ "$(id -u)" -ne 0 ]; then
    echo "${BANNER} must run as root (try: sudo $0)" >&2
    exit 1
fi

arch=$(dpkg --print-architecture)
case "${arch}" in
    arm64|amd64) ;;
    *)
        echo "${BANNER} arch ${arch} unsupported by RStudio — aborting." >&2
        exit 1
        ;;
esac

echo "${BANNER} downloading RStudio ${RSTUDIO_VERSION} for ${arch}..."

URL="https://s3.amazonaws.com/rstudio-ide-build/electron/jammy/${arch}/rstudio-${RSTUDIO_VERSION}-${arch}.deb"
DEB=/tmp/rstudio.deb

curl -fL --retry 5 --retry-delay 5 --retry-all-errors "${URL}" -o "${DEB}"

# apt-get install resolves the heavy GTK / Qt / libssl deps.
DEBIAN_FRONTEND=noninteractive apt-get install -y "${DEB}"
rm -f "${DEB}"

echo "${BANNER} RStudio ${RSTUDIO_VERSION} installed."
