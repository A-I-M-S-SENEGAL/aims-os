#!/bin/sh
# =============================================================================
# AIMS OS — Debian branding sweep (installed at /usr/lib/aims-os/debrand)
# =============================================================================
# Run by aims-os-branding's postinst on every install and upgrade, so it
# reaches machines installed from older ISOs as well as the live build.
# Idempotent. `debrand --undo` (prerm) puts Debian back.
#
#  1. vendor-logos alternative. Debian's gnome-control-center shows the
#     file /usr/share/icons/vendor/scalable/emblems/emblem-vendor.svg in
#     Settings → About, compiled in, ignoring os-release LOGO. That path
#     is a slave of the update-alternatives group "vendor-logos" that
#     desktop-base registers at priority 50. We register the same group
#     with the same slaves at priority 100, pointing at the AIMS files.
#  2. Debian wallpapers out of Settings → Appearance: the ten
#     debian-*.xml manifests of desktop-base are diverted away.
#  3. Permission repair: the ISO hook that swapped the debian-logos
#     files used to leave them 0600 (mktemp + cp -a); make them 0644.
# =============================================================================
set -e

AIMS_LOGOS=/usr/share/aims-os/vendor-logos
AIMS_ICONS=/usr/share/icons/aims-os
VENDOR=/usr/share/icons/vendor
BGPROPS=/usr/share/gnome-background-properties

alternative_install() {
    update-alternatives --quiet --install \
        /usr/share/images/vendor-logos vendor-logos "${AIMS_LOGOS}" 100 \
        --slave "${VENDOR}/64x64/emblems/emblem-vendor.png"   emblem-vendor-64       "${AIMS_ICONS}/64x64/emblems/emblem-aims.png" \
        --slave "${VENDOR}/128x128/emblems/emblem-vendor.png" emblem-vendor-128      "${AIMS_ICONS}/128x128/emblems/emblem-aims.png" \
        --slave "${VENDOR}/256x256/emblems/emblem-vendor.png" emblem-vendor-256      "${AIMS_ICONS}/256x256/emblems/emblem-aims.png" \
        --slave "${VENDOR}/scalable/emblems/emblem-vendor.svg" emblem-vendor-scalable "${AIMS_ICONS}/scalable/emblems/emblem-aims.svg" \
        --slave "${VENDOR}/64x64/emblems/emblem-vendor-symbolic.png"   emblem-vendor-symbolic-64       "${AIMS_ICONS}/64x64/emblems/emblem-aims-symbolic.png" \
        --slave "${VENDOR}/128x128/emblems/emblem-vendor-symbolic.png" emblem-vendor-symbolic-128      "${AIMS_ICONS}/128x128/emblems/emblem-aims-symbolic.png" \
        --slave "${VENDOR}/256x256/emblems/emblem-vendor-symbolic.png" emblem-vendor-symbolic-256      "${AIMS_ICONS}/256x256/emblems/emblem-aims-symbolic.png" \
        --slave "${VENDOR}/scalable/emblems/emblem-vendor-symbolic.svg" emblem-vendor-symbolic-scalable "${AIMS_ICONS}/scalable/emblems/emblem-aims-symbolic.svg" \
        --slave "${VENDOR}/64x64/emblems/emblem-vendor-white.png"   emblem-vendor-white-64       "${AIMS_ICONS}/64x64/emblems/emblem-aims-white.png" \
        --slave "${VENDOR}/128x128/emblems/emblem-vendor-white.png" emblem-vendor-white-128      "${AIMS_ICONS}/128x128/emblems/emblem-aims-white.png" \
        --slave "${VENDOR}/256x256/emblems/emblem-vendor-white.png" emblem-vendor-white-256      "${AIMS_ICONS}/256x256/emblems/emblem-aims-white.png" \
        --slave "${VENDOR}/scalable/emblems/emblem-vendor-white.svg" emblem-vendor-white-scalable "${AIMS_ICONS}/scalable/emblems/emblem-aims-white.svg"
}

case "${1:-}" in
    --undo)
        update-alternatives --quiet --remove vendor-logos "${AIMS_LOGOS}" 2>/dev/null || true
        for x in "${BGPROPS}"/debian-*.xml.aims-hidden; do
            [ -e "${x}" ] || continue
            orig="${x%.aims-hidden}"
            dpkg-divert --quiet --remove --rename --divert "${x}" "${orig}" 2>/dev/null || true
        done
        exit 0
        ;;
esac

# 1. Vendor logos / emblems.
if [ -d "${AIMS_LOGOS}" ] && [ -f "${AIMS_ICONS}/scalable/emblems/emblem-aims.svg" ]; then
    alternative_install
fi

# 2. Debian wallpapers out of the picker.
for x in "${BGPROPS}"/debian-*.xml; do
    [ -f "${x}" ] || continue
    dpkg-divert --quiet --add --rename --divert "${x}.aims-hidden" "${x}"
done

# 3. Readable logo files (older ISO hook left them 0600).
if [ -d /usr/share/desktop-base/debian-logos ]; then
    find /usr/share/desktop-base/debian-logos -maxdepth 1 -type f \
        \( -name '*.svg' -o -name '*.png' \) ! -perm -o=r -exec chmod 0644 {} + 2>/dev/null || true
fi

exit 0
