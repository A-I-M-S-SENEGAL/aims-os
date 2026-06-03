#!/bin/sh
# =============================================================================
# AIMS OS — post-install script: Bun + Deno + uv (single-binary runtimes)
# =============================================================================
# Three modern, single-binary, fast tools none of which are packaged in
# Debian Trixie. Fetched from their GitHub release pages and installed
# system-wide at /usr/local/bin.
#
#   Bun   JavaScript / TypeScript runtime, bundler, package manager (Zig)
#   Deno  TypeScript-first runtime by Node's original creator (Rust)
#   uv    Astral's Python package manager (Rust)
#
# Run as root:
#   sudo /usr/share/aims-os/install/runtimes.sh
#
# Idempotent. Re-running fetches the latest releases.
# =============================================================================
set -e

BANNER="[aims-os/install/runtimes]"

if [ "$(id -u)" -ne 0 ]; then
    echo "${BANNER} must run as root (try: sudo $0)" >&2
    exit 1
fi

arch=$(dpkg --print-architecture)
case "${arch}" in
    arm64) BUN_ARCH=aarch64; DENO_ARCH=aarch64; UV_ARCH=aarch64 ;;
    amd64) BUN_ARCH=x64;     DENO_ARCH=x86_64;  UV_ARCH=x86_64  ;;
    *)
        echo "${BANNER} arch ${arch} unsupported — aborting." >&2
        exit 1
        ;;
esac

# unzip is needed for Bun + Deno; pull it via apt if missing.
if ! command -v unzip >/dev/null 2>&1; then
    apt-get update
    apt-get install -y --no-install-recommends unzip
fi

# -----------------------------------------------------------------------------
# Bun
# -----------------------------------------------------------------------------
echo "${BANNER} installing Bun (latest) for linux-${BUN_ARCH}..."
BUN_ZIP=/tmp/bun.zip
curl -fL --retry 5 --retry-delay 5 \
    "https://github.com/oven-sh/bun/releases/latest/download/bun-linux-${BUN_ARCH}.zip" \
    -o "${BUN_ZIP}"
unzip -j -o "${BUN_ZIP}" -d /tmp/bun-extract
install -m 0755 "/tmp/bun-extract/bun" /usr/local/bin/bun
ln -sf bun /usr/local/bin/bunx
rm -rf "${BUN_ZIP}" /tmp/bun-extract
bun --version

# -----------------------------------------------------------------------------
# Deno
# -----------------------------------------------------------------------------
echo "${BANNER} installing Deno (latest) for linux-${DENO_ARCH}..."
DENO_ZIP=/tmp/deno.zip
curl -fL --retry 5 --retry-delay 5 \
    "https://github.com/denoland/deno/releases/latest/download/deno-${DENO_ARCH}-unknown-linux-gnu.zip" \
    -o "${DENO_ZIP}"
unzip -j -o "${DENO_ZIP}" -d /tmp/deno-extract
install -m 0755 "/tmp/deno-extract/deno" /usr/local/bin/deno
rm -rf "${DENO_ZIP}" /tmp/deno-extract
deno --version | head -1

# -----------------------------------------------------------------------------
# uv
# -----------------------------------------------------------------------------
echo "${BANNER} installing uv (latest) for ${UV_ARCH}-unknown-linux-gnu..."
UV_TAR=/tmp/uv.tar.gz
curl -fL --retry 5 --retry-delay 5 \
    "https://github.com/astral-sh/uv/releases/latest/download/uv-${UV_ARCH}-unknown-linux-gnu.tar.gz" \
    -o "${UV_TAR}"
tar -xzf "${UV_TAR}" -C /tmp
install -m 0755 "/tmp/uv-${UV_ARCH}-unknown-linux-gnu/uv"  /usr/local/bin/uv
install -m 0755 "/tmp/uv-${UV_ARCH}-unknown-linux-gnu/uvx" /usr/local/bin/uvx
rm -rf "${UV_TAR}" "/tmp/uv-${UV_ARCH}-unknown-linux-gnu"
uv --version

echo "${BANNER} Bun + Deno + uv installed."
