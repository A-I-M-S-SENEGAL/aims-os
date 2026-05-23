#!/bin/sh
# =============================================================================
# AIMS OS — first-boot user setup
# =============================================================================
# Runs once on the FIRST boot of an installed system. Looks up the
# Calamares-created user (the only non-system account, UID >= 1000)
# and adds it to:
#
#   - docker     so `docker run` / `docker compose` work without sudo
#                (Web/Android Dev course's first lab).
#   - wireshark  so the user can capture packets via the setuid dumpcap
#                shipped by our preseed (Ethical Hacking course).
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
