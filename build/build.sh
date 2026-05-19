#!/usr/bin/env bash
# =============================================================================
# AIMS OS — host-side build wrapper
# =============================================================================
# Run from the project root on a macOS or Linux host with Docker Desktop /
# Docker Engine installed. This script orchestrates everything outside the
# build container: image build, privileged run, cache reuse, ISO extraction
# with SHA-256 checksum.
#
# Usage:
#   ./build/build.sh arm64           Build the arm64 ISO (native on M-series)
#   ./build/build.sh amd64           Build the amd64 ISO (QEMU emulation on M-series)
#   ./build/build.sh clean           lb clean — keeps the apt cache
#   ./build/build.sh purge           lb clean --purge — wipes cache too
#   ./build/build.sh image <arch>    Just (re)build the docker image, no ISO
#   ./build/build.sh shell <arch>    Drop into a privileged shell in the builder
#   ./build/build.sh metapackages <arch>  Compile the 4 AIMS OS metapackages only
#   ./build/build.sh help            Show this help
#
# Output:
#   build/out/aims-os-1.0-<arch>.iso         the bootable ISO
#   build/out/aims-os-1.0-<arch>.iso.sha256  checksum
#   build/out/aims-os-1.0-<arch>.log         full build log
# =============================================================================

set -euo pipefail

# -----------------------------------------------------------------------------
# Paths & constants
# -----------------------------------------------------------------------------
REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
BUILD_DIR="${REPO_ROOT}/build"
OUT_DIR="${BUILD_DIR}/out"
CACHE_DIR="${BUILD_DIR}/cache"

VERSION="1.0"
IMAGE_NAME="aims-os-builder"

# -----------------------------------------------------------------------------
# Pretty logging — matches the style used by docker/entrypoint.sh
# -----------------------------------------------------------------------------
BANNER='\033[1;36m[aims-os/build]\033[0m'
log()  { printf '%b %s\n'  "${BANNER}" "$*"; }
warn() { printf '%b \033[1;33mWARN:\033[0m %s\n' "${BANNER}" "$*" >&2; }
die()  { printf '%b \033[1;31mERROR:\033[0m %s\n' "${BANNER}" "$*" >&2; exit 1; }

# -----------------------------------------------------------------------------
# Pre-flight
# -----------------------------------------------------------------------------
check_docker() {
    command -v docker >/dev/null 2>&1 \
        || die "docker not found in PATH. Install Docker Desktop and retry."
    docker info >/dev/null 2>&1 \
        || die "docker daemon unreachable. Start Docker Desktop and retry."
    docker buildx version >/dev/null 2>&1 \
        || die "docker buildx plugin not available. Update Docker Desktop."
}

validate_arch() {
    local arch="${1:-}"
    case "${arch}" in
        amd64|arm64) ;;
        "") die "missing architecture argument. Use: $0 <arm64|amd64>" ;;
        *) die "unsupported arch '${arch}'. Expected: amd64 or arm64." ;;
    esac
}

# -----------------------------------------------------------------------------
# Docker image (arch-tagged) — built once, reused across runs.
# Buildx is invoked with --load so the image lands in the local docker engine.
# -----------------------------------------------------------------------------
build_image() {
    local arch="$1"
    local tag="${IMAGE_NAME}:${arch}"

    log "building docker image ${tag} for linux/${arch} ..."
    docker buildx build \
        --platform "linux/${arch}" \
        --load \
        --tag "${tag}" \
        --file "${REPO_ROOT}/docker/Dockerfile" \
        "${REPO_ROOT}"
    log "image ${tag} ready."
}

ensure_image() {
    local arch="$1"
    local tag="${IMAGE_NAME}:${arch}"
    if ! docker image inspect "${tag}" >/dev/null 2>&1; then
        log "image ${tag} not found locally; building ..."
        build_image "${arch}"
    fi
}

# -----------------------------------------------------------------------------
# Run a command inside the privileged builder container.
# Bind-mounts:
#   project root  → /build              (live-build reads config + writes ISO)
#   cache dir     → /build/cache        (persistent apt + debootstrap cache)
# Both use the `delegated` consistency mode, which is the right choice on
# macOS Docker Desktop for build workloads (container is the authoritative
# writer; host reads occasionally).
# -----------------------------------------------------------------------------
docker_run() {
    local arch="$1"; shift
    local tag="${IMAGE_NAME}:${arch}"

    mkdir -p "${CACHE_DIR}" "${OUT_DIR}"

    # -t (TTY) only when stdin is actually attached to a terminal. Without
    # this guard the script breaks under non-interactive invocation
    # (CI, `bash -c`, agent tools), failing with:
    #   "cannot attach stdin to a TTY-enabled container".
    local interact_flags=(-i)
    if [[ -t 0 ]]; then
        interact_flags+=(-t)
    fi

    docker run --rm "${interact_flags[@]}" \
        --platform "linux/${arch}" \
        --privileged \
        --hostname "aims-os-builder-${arch}" \
        --volume "${REPO_ROOT}:/build:delegated" \
        --volume "${CACHE_DIR}:/build/build/cache:delegated" \
        --workdir /build/build \
        "${tag}" \
        "$@"
}

# -----------------------------------------------------------------------------
# Build pipeline
# -----------------------------------------------------------------------------
cmd_build() {
    local arch="$1"
    local log_file="${OUT_DIR}/aims-os-${VERSION}-${arch}.log"

    check_docker
    validate_arch "${arch}"
    ensure_image "${arch}"

    mkdir -p "${OUT_DIR}"

    log "starting ISO build for ${arch} — log → ${log_file}"
    log "this can take 10 min (arm64 native) to 45 min (amd64 emulated on Apple Silicon)."

    # Two-phase build inside a single container invocation:
    #   1. Compile the AIMS OS metapackages and drop them in
    #      build/config/packages.chroot/ where live-build picks them up.
    #   2. lb config + lb build to produce the ISO.
    # Tee'd to the per-arch log so post-mortems are possible without
    # re-running the (slow) build.
    docker_run "${arch}" \
        bash -c "set -e ; bash /build/build/build-metapackages.sh && lb config && lb build" \
        2>&1 | tee "${log_file}"

    extract_iso "${arch}"
}

# -----------------------------------------------------------------------------
# Compile only the four AIMS OS metapackages and drop them in
# build/config/packages.chroot/. Useful when iterating on a metapackage
# control file without paying the cost of a full ISO build.
# -----------------------------------------------------------------------------
cmd_metapackages() {
    local arch="${1:-arm64}"
    check_docker
    validate_arch "${arch}"
    ensure_image "${arch}"
    log "compiling AIMS OS metapackages for ${arch} ..."
    docker_run "${arch}" bash /build/build/build-metapackages.sh
}

# -----------------------------------------------------------------------------
# After a successful build, the ISO is at build/binary.iso (live-build
# default name). Move it to build/out/ with the canonical AIMS OS name and
# generate a SHA-256.
# -----------------------------------------------------------------------------
extract_iso() {
    local arch="$1"
    local src="${BUILD_DIR}/binary.iso"
    local dst="${OUT_DIR}/aims-os-${VERSION}-${arch}.iso"

    [[ -f "${src}" ]] || die "expected ISO at ${src} not found — build failed?"

    mv "${src}" "${dst}"
    log "ISO written to ${dst} ($(du -h "${dst}" | cut -f1))"

    log "computing SHA-256 ..."
    if command -v sha256sum >/dev/null 2>&1; then
        ( cd "${OUT_DIR}" && sha256sum "$(basename "${dst}")" > "${dst}.sha256" )
    else
        # macOS host doesn't ship sha256sum; use shasum.
        ( cd "${OUT_DIR}" && shasum -a 256 "$(basename "${dst}")" > "${dst}.sha256" )
    fi
    log "checksum: $(cat "${dst}.sha256")"
}

# -----------------------------------------------------------------------------
# Maintenance commands
# -----------------------------------------------------------------------------
cmd_clean() {
    check_docker
    # `lb clean` removes intermediate state but keeps the apt cache, which is
    # exactly what we want between iterative builds.
    local arch="${1:-arm64}"  # default arch for the cleanup container
    validate_arch "${arch}"
    ensure_image "${arch}"
    log "running lb clean (cache preserved) ..."
    docker_run "${arch}" lb clean
    log "intermediate state cleared. The apt cache in ${CACHE_DIR} is intact."
}

cmd_purge() {
    check_docker
    local arch="${1:-arm64}"
    validate_arch "${arch}"
    ensure_image "${arch}"
    log "running lb clean --purge (cache wiped) ..."
    docker_run "${arch}" lb clean --purge
    rm -rf "${CACHE_DIR}"
    log "everything cleared including ${CACHE_DIR}."
}

cmd_shell() {
    local arch="${1:-arm64}"
    check_docker
    validate_arch "${arch}"
    ensure_image "${arch}"
    log "spawning interactive shell in ${IMAGE_NAME}:${arch} ..."
    docker_run "${arch}" bash
}

cmd_image() {
    local arch="${1:?missing arch}"
    check_docker
    validate_arch "${arch}"
    build_image "${arch}"
}

cmd_help() {
    sed -n '/^# Usage:/,/^# ===/p' "$0" | sed 's/^# \{0,1\}//' | sed '$d'
}

# -----------------------------------------------------------------------------
# Dispatch
# -----------------------------------------------------------------------------
main() {
    local cmd="${1:-help}"
    case "${cmd}" in
        amd64|arm64)            cmd_build "${cmd}" ;;
        clean)                  cmd_clean "${2:-arm64}" ;;
        purge)                  cmd_purge "${2:-arm64}" ;;
        shell)                  cmd_shell "${2:-arm64}" ;;
        image)                  cmd_image "${2:?missing arch (amd64|arm64)}" ;;
        metapackages)           cmd_metapackages "${2:-arm64}" ;;
        -h|--help|help)         cmd_help ;;
        *)  die "unknown command '${cmd}'. Run '$0 help' for usage." ;;
    esac
}

main "$@"
