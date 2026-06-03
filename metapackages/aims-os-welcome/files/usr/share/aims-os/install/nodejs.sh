#!/bin/sh
# =============================================================================
# AIMS OS — post-install script: NodeSource Node.js 22 LTS
# =============================================================================
# Replaces Debian Trixie's nodejs (20.x EOL April 2026) with Node 22 LTS
# from NodeSource. Pins priority 700 so a future Trixie point-release
# can't downgrade us.
#
# Run as root (via pkexec from aims-welcome, or sudo manually):
#   sudo /usr/share/aims-os/install/nodejs.sh
#
# Idempotent. Re-running upgrades to the latest 22.x without touching
# the apt source files.
# =============================================================================
set -e

BANNER="[aims-os/install/nodejs]"
KEYRING=/usr/share/keyrings/nodesource.gpg

if [ "$(id -u)" -ne 0 ]; then
    echo "${BANNER} must run as root (try: sudo $0)" >&2
    exit 1
fi

# Short-circuit if a NodeSource 22.x is already installed.
if command -v node >/dev/null 2>&1; then
    ver=$(node --version 2>/dev/null | sed 's/^v//')
    case "${ver}" in
        22.*)
            echo "${BANNER} Node v${ver} already installed — refreshing apt only."
            ;;
    esac
fi

echo "${BANNER} setting up NodeSource 22 LTS apt repo..."

# 1. GPG key
curl -fsSL https://deb.nodesource.com/gpgkey/nodesource-repo.gpg.key \
    | gpg --dearmor --yes -o "${KEYRING}"

# 2. Source list — `nodistro` is NodeSource's distro-agnostic channel.
cat > /etc/apt/sources.list.d/nodesource.sources <<'EOF'
Types: deb
URIs: https://deb.nodesource.com/node_22.x
Suites: nodistro
Components: main
Signed-by: /usr/share/keyrings/nodesource.gpg
EOF

# 3. Pin: prefer NodeSource over Trixie's nodejs.
cat > /etc/apt/preferences.d/nodesource-nodejs.pref <<'EOF'
Package: nodejs
Pin: origin deb.nodesource.com
Pin-Priority: 700
EOF

# 4. Drop Trixie's nodejs + npm if present, then install NodeSource one.
apt-get update
apt-get remove -y --purge nodejs npm 2>/dev/null || true
DEBIAN_FRONTEND=noninteractive apt-get install -y nodejs

echo "${BANNER} Node $(node --version) / npm $(npm --version) installed."
