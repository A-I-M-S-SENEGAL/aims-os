#!/bin/sh
# =============================================================================
# AIMS OS — post-install script: VSCodium
# =============================================================================
# Adds Paulcarroty's official VSCodium apt repo and installs `codium`.
# VSCodium is the libre rebuild of VS Code (no telemetry, no Microsoft
# Marketplace; uses Open VSX instead).
#
# Run as root:
#   sudo /usr/share/aims-os/install/vscodium.sh
#
# Idempotent. Re-running upgrades to the latest stable build via apt.
# =============================================================================
set -e

BANNER="[aims-os/install/vscodium]"
KEYRING=/usr/share/keyrings/vscodium.gpg

if [ "$(id -u)" -ne 0 ]; then
    echo "${BANNER} must run as root (try: sudo $0)" >&2
    exit 1
fi

if dpkg -s codium >/dev/null 2>&1; then
    echo "${BANNER} VSCodium already installed — refreshing apt only."
fi

echo "${BANNER} installing VSCodium via paulcarroty apt repo..."

# 1. GPG key
curl -fsSL https://gitlab.com/paulcarroty/vscodium-deb-rpm-repo/raw/master/pub.gpg \
    | gpg --dearmor --yes -o "${KEYRING}"

# 2. Repo (deb822 format)
cat > /etc/apt/sources.list.d/vscodium.sources <<'EOF'
Types: deb
URIs: https://download.vscodium.com/debs
Suites: vscodium
Components: main
Architectures: amd64 arm64
Signed-by: /usr/share/keyrings/vscodium.gpg
EOF

apt-get update
DEBIAN_FRONTEND=noninteractive apt-get install -y codium

echo "${BANNER} VSCodium $(codium --version 2>/dev/null | head -1) installed."
