---
title: First boot
description: What happens at the first AIMS OS login, and how to get set up quickly.
---

At the first GNOME login, AIMS OS does three things on its own:

1. The systemd `aims-firstboot.service` adds your account to the
   `docker` and `wireshark` groups. That unlocks `docker run` without
   sudo and lets `wireshark` capture without root for the Ethical
   Hacking course.
2. The HTML welcome page opens in Firefox, branded AIMS, bilingual FR/EN.
3. Plymouth + GDM already applied the terracotta theme at boot.

## Check the version

Open a terminal and type:

```bash
aims-version
```

Prints the OS name, base Debian version, kernel and desktop. Variants:

- `aims-version --json` — machine-readable
- `aims-version --verbose` — adds python3 / R / node / docker / Cursor / RStudio
- `aims-version --plain` — no ANSI colour

## Re-open the welcome page

```bash
aims-welcome          # opens the GUI if never shown
aims-welcome --force  # forces it open
aims-welcome --text   # text version in the terminal
```

## Activate the docker group for the current session

Group changes (`docker`, `wireshark`) only take effect on the next
session. To use them right now:

```bash
newgrp docker
docker run hello-world  # should work without sudo
```

Or just logout / login.

## Locale and keyboard

The system defaults to `fr_FR.UTF-8`, Africa/Dakar timezone, keyboard
`fr` (France). To change:

- Keyboard: **Settings → Keyboard → Input Sources**
- System locale: `sudo dpkg-reconfigure locales`

## Network

On Wi-Fi, manage the connection through GNOME Settings → Wi-Fi.
NetworkManager OpenVPN is pre-installed for AIMS VPNs.

On Mac M-series under UTM, ICMP ping is blocked by UTM's NAT. Use
`curl https://google.com` or Firefox to test. TCP connectivity works
normally.

## Update the system

```bash
sudo apt update && sudo apt upgrade
```

Pulls Debian Security patches and new AIMS OS stack versions if you
added the [apt repo](/en/install/apt/).

## What next

- [Pick your track](/en/filieres/regular/)
- [Map your courses to the tools](/en/courses/mapping/)
