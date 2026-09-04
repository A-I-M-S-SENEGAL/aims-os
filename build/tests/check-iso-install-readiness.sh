#!/usr/bin/env bash
# =============================================================================
# AIMS OS — installer-readiness checks on a built ISO
# =============================================================================
# Static checks that catch the regressions met on the first FOG-driven
# lab install (2026-09-03) before an ISO reaches users:
#
#   * the live system carries the GRUB binaries Calamares needs, so an
#     install always ends with a bootloader (Debian #1005196 class of bug)
#   * the ISO pool carries the grub / shim packages Calamares' own
#     bootloader-config step installs from the medium
#   * the AIMS Calamares overrides are in place (immediate restart at the
#     end of a netboot install, French locale/keyboard defaults)
#   * the live initrd can mount its root over NFS (FOG netboot entry)
#   * the medium is a valid apt repository (sources-media step)
#
# Usage: check-iso-install-readiness.sh <iso> <amd64|arm64>
# Needs: mount (root), squashfs-tools (unsquashfs), initramfs-tools-core
# (lsinitramfs). Exits non-zero with the list of failed checks.
# =============================================================================
set -uo pipefail

ISO="${1:?iso path}"
ARCH="${2:?amd64|arm64}"
MNT="$(mktemp -d)"
FAIL=0

ok()   { printf '  ✓ %s\n' "$*"; }
fail() { printf '  ✗ %s\n' "$*"; FAIL=$((FAIL + 1)); }

sudo mount -o loop,ro "${ISO}" "${MNT}" || { echo "cannot mount ${ISO}"; exit 2; }
trap 'sudo umount "${MNT}" 2>/dev/null; rmdir "${MNT}" 2>/dev/null' EXIT

LIVE="${MNT}/live"
PKGS="${LIVE}/filesystem.packages"
SQ="${LIVE}/filesystem.squashfs"

echo "== live/ layout"
for f in vmlinuz initrd.img filesystem.squashfs filesystem.packages; do
    if ls "${LIVE}/${f}"* >/dev/null 2>&1; then ok "live/${f}*"; else fail "live/${f}* missing"; fi
done

echo "== packages in the live system (filesystem.packages)"
case "${ARCH}" in
    amd64) want="grub2-common grub-pc-bin grub-efi-amd64-bin grub-efi-amd64-signed shim-signed efibootmgr" ;;
    arm64) want="grub2-common grub-efi-arm64-bin grub-efi-arm64-signed shim-signed efibootmgr" ;;
    *) echo "unknown arch ${ARCH}"; exit 2 ;;
esac
for p in ${want} calamares calamares-settings-debian live-boot initramfs-tools aims-os-desktop aims-os-core; do
    if grep -qE "^${p}(:[a-z0-9]+)?[[:space:]]" "${PKGS}" 2>/dev/null; then ok "${p}"; else fail "${p} not in the live system"; fi
done

echo "== packages in the ISO pool (Calamares bootloader-config source)"
case "${ARCH}" in
    amd64) pool="grub-pc_ grub-efi-amd64_ shim-signed_" ;;
    arm64) pool="grub-efi-arm64_ shim-signed_" ;;
esac
for p in ${pool}; do
    if find "${MNT}/pool" -name "${p}*.deb" 2>/dev/null | grep -q .; then ok "pool: ${p}*.deb"; else fail "pool: ${p}*.deb missing"; fi
done
if [ -f "${MNT}/dists/trixie/Release" ]; then ok "dists/trixie/Release (medium is an apt repo)"; else fail "dists/trixie/Release missing"; fi

echo "== Calamares overrides inside the squashfs"
conf="$(unsquashfs -cat "${SQ}" etc/calamares/modules/finished.conf 2>/dev/null)"
if echo "${conf}" | grep -q 'restartNowCommand: "systemctl reboot -ff"'; then ok "finished.conf: immediate restart (netboot-safe)"; else fail "finished.conf: restartNowCommand is not 'systemctl reboot -ff'"; fi
for m in locale keyboard; do
    if unsquashfs -cat "${SQ}" "etc/calamares/modules/${m}.conf" 2>/dev/null | grep -qE "zone|layout|region|keyboard"; then ok "${m}.conf override present"; else fail "${m}.conf override missing"; fi
done
if unsquashfs -cat "${SQ}" usr/local/sbin/aims-firstboot.sh 2>/dev/null | grep -q "aims-os.sources"; then ok "aims-firstboot.sh activates the AIMS apt repo"; else fail "aims-firstboot.sh does not activate the AIMS apt repo"; fi
if unsquashfs -cat "${SQ}" usr/share/aims-os/apt/aims-os.sources 2>/dev/null | grep -q "a-i-m-s-senegal.github.io"; then ok "inert aims-os.sources shipped"; else fail "inert aims-os.sources missing"; fi

echo "== initrd: NFS root support (FOG netboot entry)"
INITRD="$(ls "${LIVE}"/initrd.img* | head -1)"
if lsinitramfs "${INITRD}" 2>/dev/null | grep -qE "kernel/fs/nfs/nfs\.ko|/nfsmount$"; then ok "nfs module + nfsmount in initrd"; else fail "initrd cannot mount an NFS root"; fi

echo
if [ "${FAIL}" -eq 0 ]; then echo "installer-readiness: all checks passed"; else echo "installer-readiness: ${FAIL} check(s) FAILED"; fi
exit "${FAIL}"
