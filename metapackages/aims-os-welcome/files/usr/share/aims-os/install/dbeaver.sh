#!/bin/sh
# =============================================================================
# AIMS OS — post-install script: DBeaver Community Edition
# =============================================================================
# Adds upstream's apt repo at https://dbeaver.io/debs/dbeaver-ce and
# installs `dbeaver-ce`. DBeaver is a universal SQL GUI (Postgres,
# MariaDB/MySQL, SQLite, MongoDB, Redis, …). Apache 2.0.
#
# Run as root:
#   sudo /usr/share/aims-os/install/dbeaver.sh
#
# Idempotent.
# =============================================================================
set -e

BANNER="[aims-os/install/dbeaver]"
KEYRING=/usr/share/keyrings/dbeaver.gpg

if [ "$(id -u)" -ne 0 ]; then
    echo "${BANNER} must run as root (try: sudo $0)" >&2
    exit 1
fi

if dpkg -s dbeaver-ce >/dev/null 2>&1; then
    echo "${BANNER} DBeaver CE already installed — refreshing apt only."
fi

echo "${BANNER} installing DBeaver CE via upstream apt repo..."

# 1. GPG key
curl -fsSL https://dbeaver.io/debs/dbeaver.gpg.key \
    | gpg --dearmor --yes -o "${KEYRING}"

# 2. Flat repo (Suite = /, no Components)
cat > /etc/apt/sources.list.d/dbeaver.sources <<'EOF'
Types: deb
URIs: https://dbeaver.io/debs/dbeaver-ce
Suites: /
Signed-by: /usr/share/keyrings/dbeaver.gpg
EOF

apt-get update
DEBIAN_FRONTEND=noninteractive apt-get install -y dbeaver-ce

echo "${BANNER} DBeaver CE installed."
