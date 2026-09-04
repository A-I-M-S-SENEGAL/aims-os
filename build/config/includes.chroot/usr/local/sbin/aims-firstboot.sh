#!/bin/sh
# =============================================================================
# AIMS OS — first-boot user setup
# =============================================================================
# Runs once on the FIRST boot of an installed system. Two jobs:
#
#   1. Activate the AIMS apt repository: copy the inert .sources file
#      shipped under /usr/share/aims-os/apt/ into
#      /etc/apt/sources.list.d/. It cannot ship active in the ISO tree
#      because live-build's binary-stage `apt upgrade` would fight the
#      locally built metapackages (see the .sources file header).
#
#   2. Look up the Calamares-created user (the only non-system
#      account, UID >= 1000) and add it to:
#
#      - docker     so `docker run` / `docker compose` work without
#                   sudo (Web/Android Dev course's first lab).
#      - wireshark  so the user can capture packets via the setuid
#                   dumpcap shipped by our preseed (Ethical Hacking).
#
# Then drops a sentinel file so we never run again on subsequent boots.
#
# The live ISO user `user` is handled separately at build time by hook
# 0101-user-groups (it exists in the chroot; we just usermod it directly
# there). For Calamares-installed users, the account doesn't exist at
# build time — only at first boot — hence this service.
# =============================================================================
set -eu

SENTINEL=/var/lib/aims-os/firstboot.done
LOG=/var/log/aims-firstboot.log

mkdir -p "$(dirname "${SENTINEL}")"
exec >>"${LOG}" 2>&1
echo "==== aims-firstboot $(date -Is) ===="

if [ -f "${SENTINEL}" ]; then
    echo "Sentinel ${SENTINEL} present — first-boot already ran."
    exit 0
fi

# Activate the AIMS apt repository. Runs before the user lookup so the
# repo lands even when Calamares hasn't created the account yet
# (the postponing path below exits without the sentinel).
APT_SRC=/usr/share/aims-os/apt/aims-os.sources
APT_DST=/etc/apt/sources.list.d/aims-os.sources
if [ -f "${APT_SRC}" ] && [ ! -f "${APT_DST}" ]; then
    cp "${APT_SRC}" "${APT_DST}"
    echo "AIMS apt repo activated at ${APT_DST}."
fi

# Calamares derives the "numbers and dates" locale from the timezone's
# country. glibc has no fr_SN locale, so for Africa/Dakar it picks wo_SN
# (Wolof) for LC_NUMERIC / LC_TIME / LC_MONETARY and friends, which the
# installer summary reports as "Wolof (Senegaal)". AIMS teaches in
# French and wo_SN is not even generated on the installed system, so
# keep the whole locale on fr_FR.UTF-8.
# Calamares writes BOTH /etc/default/locale and /etc/locale.conf, and
# systemd-localed re-syncs the former from the latter, so fixing only
# /etc/default/locale came back as wo_SN after a reboot (labo-hp-01,
# 2026-09-04). Patch both.
for f in /etc/default/locale /etc/locale.conf; do
    if [ -f "${f}" ] && grep -q "wo_SN" "${f}"; then
        sed -i 's/wo_SN\.UTF-8/fr_FR.UTF-8/g; s/wo_SN/fr_FR.UTF-8/g' "${f}"
        echo "Locale: wo_SN replaced by fr_FR.UTF-8 in ${f}."
    fi
done

# And do not even generate wo_SN: nothing at AIMS uses it, and a stray
# LC_* pointing at it would then fall back to LANG instead of Wolof.
if [ -f /etc/locale.gen ] && grep -qE "^wo_SN" /etc/locale.gen; then
    sed -i 's/^wo_SN/# wo_SN/' /etc/locale.gen
    locale-gen >/dev/null 2>&1 || true
    # locale-gen does not drop compiled locales from the archive.
    for l in $(locale -a 2>/dev/null | grep '^wo_'); do
        localedef --delete-from-archive "${l}" >/dev/null 2>&1 || true
    done
    echo "Locale: wo_SN removed from /etc/locale.gen."
fi

# Find every regular user (UID >= 1000, real shell, real home).
# In practice on a Calamares install this is exactly one account.
users=$(getent passwd | awk -F: '
    $3 >= 1000 && $3 < 60000 && $7 !~ /(nologin|false)$/ { print $1 }
')

if [ -z "${users}" ]; then
    echo "No non-system user found — postponing (sentinel NOT created)."
    exit 0
fi

for grp in docker wireshark; do
    if ! getent group "${grp}" >/dev/null 2>&1; then
        echo "Group ${grp} absent — skipping."
        continue
    fi
    for u in ${users}; do
        if id -nG "${u}" | tr ' ' '\n' | grep -qx "${grp}"; then
            echo "User ${u} already in ${grp}."
        else
            usermod -aG "${grp}" "${u}"
            echo "Added ${u} to ${grp}."
        fi
    done
done

touch "${SENTINEL}"
echo "Done."
