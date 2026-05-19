#!/bin/bash
# =============================================================================
# AIMS OS — builder container entrypoint
# =============================================================================
# Runs inside the `aims-os-builder` image at container start. Performs the
# small amount of pre-flight setup that cannot be baked into the image
# itself, then execs the requested command.
#
# Responsibilities:
#   1. Refuse to run unless we are root (live-build requires it).
#   2. Refuse to run unless the container has access to mount() — we test
#      that indirectly by checking we can create a loop device node.
#   3. Create /dev/loop[0-15] block-device nodes via mknod, because Docker
#      does NOT propagate host-side loop device creations into the
#      container's /dev tree. See moby/moby#27886.
#   4. exec "$@" so the requested command (lb build, lb config, bash for
#      debugging, anything) inherits PID 1.
#
# This script lives at /usr/local/bin/entrypoint.sh inside the image.
# =============================================================================

set -euo pipefail

BANNER="\033[1;33m[aims-os-builder]\033[0m"

log()  { printf '%b %s\n'  "${BANNER}" "$*"; }
fail() { printf '%b ERROR: %s\n' "${BANNER}" "$*" >&2; exit 1; }

# -----------------------------------------------------------------------------
# 1. Root check
# -----------------------------------------------------------------------------
if [[ "$(id -u)" -ne 0 ]]; then
    fail "must run as root (live-build needs chroot, mount, losetup). Re-run docker with --user 0 or omit --user."
fi

# -----------------------------------------------------------------------------
# 2. Privileged-mode probe (we need CAP_MKNOD + CAP_SYS_ADMIN)
# -----------------------------------------------------------------------------
if ! mknod -m 0660 /dev/aims-probe c 1 3 2>/dev/null; then
    fail "container lacks MKNOD capability. Re-run with --privileged (or at minimum --cap-add=MKNOD --cap-add=SYS_ADMIN)."
fi
rm -f /dev/aims-probe

# -----------------------------------------------------------------------------
# 3. Create loop device nodes
#
#   Loop devices use block major 7. We provision /dev/loop0 … /dev/loop15,
#   which is plenty for a live-build pass (typically 2–4 are used at once
#   for the squashfs and the ISO).
#
#   We tolerate already-present nodes (host /dev/ propagation is
#   inconsistent across Docker Desktop versions, and an existing node is
#   fine to keep).
# -----------------------------------------------------------------------------
log "provisioning loop devices /dev/loop[0-15] ..."
created=0
for i in $(seq 0 15); do
    dev="/dev/loop${i}"
    if [[ ! -b "${dev}" ]]; then
        # Clean up anything that's there but not a block device (rare).
        rm -f "${dev}"
        mknod -m 0660 "${dev}" b 7 "${i}"
        chown root:disk "${dev}" 2>/dev/null || true
        created=$((created + 1))
    fi
done
log "loop devices ready (${created} created, $((16 - created)) pre-existing)"

# -----------------------------------------------------------------------------
# 4. Sanity log of the environment, then dispatch
# -----------------------------------------------------------------------------
log "kernel:  $(uname -srm)"
log "debian:  $(. /etc/os-release && echo "${PRETTY_NAME}")"
log "lb:      $(lb --version 2>/dev/null || echo 'not installed')"
log "workdir: $(pwd)"
log "command: $*"

exec "$@"
