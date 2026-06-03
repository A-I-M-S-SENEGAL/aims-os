#!/bin/sh
# =============================================================================
# AIMS OS — post-install script: Cursor (AI code editor)
# =============================================================================
# Downloads the official Cursor .deb directly from cursor.com.
# Proprietary, free tier with 2000 AI completions / month. Adds the
# cursor.com apt repo on its own postinst so future `apt upgrade` keeps
# it current.
#
# Run as root:
#   sudo /usr/share/aims-os/install/cursor.sh
#
# Idempotent. Re-running fetches the latest 3.5.x build and reinstalls.
# Bump CURSOR_CHANNEL when Cursor moves to a new major-minor.
# =============================================================================
set -e

BANNER="[aims-os/install/cursor]"
CURSOR_CHANNEL=3.5

if [ "$(id -u)" -ne 0 ]; then
    echo "${BANNER} must run as root (try: sudo $0)" >&2
    exit 1
fi

arch=$(dpkg --print-architecture)
case "${arch}" in
    arm64) cursor_arch=arm64 ;;
    amd64) cursor_arch=x64   ;;
    *)
        echo "${BANNER} arch ${arch} unsupported by Cursor — aborting." >&2
        exit 1
        ;;
esac

echo "${BANNER} downloading Cursor ${CURSOR_CHANNEL} for linux-${cursor_arch}..."

URL="https://api2.cursor.sh/updates/download/golden/linux-${cursor_arch}-deb/cursor/${CURSOR_CHANNEL}"
DEB=/tmp/cursor.deb

curl -fL --retry 5 --retry-delay 5 --retry-all-errors "${URL}" -o "${DEB}"

# apt-get install handles the libnss3 / libgbm1 / libasound2t64 deps
# that a raw `dpkg -i` would leave broken.
DEBIAN_FRONTEND=noninteractive apt-get install -y "${DEB}"
rm -f "${DEB}"

echo "${BANNER} Cursor ${CURSOR_CHANNEL} installed."
