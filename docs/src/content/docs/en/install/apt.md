---
title: On an existing Debian (apt)
description: Add the AIMS OS stack to an already-installed Debian 13 Trixie via the official apt repository.
---

If you already have a Debian 13 Trixie running (laptop, server, VM,
cluster head), you can add the AIMS OS layer without reinstalling
the system. The official apt repo is hosted on GitHub Pages and
GPG-signed.

## Add the repo

```bash
# 1. Fetch the AIMS OS public signing key
sudo curl -fsSL https://a-i-m-s-senegal.github.io/aims-os/aims-os-archive-keyring.gpg \
    -o /usr/share/keyrings/aims-os-archive-keyring.gpg

# 2. Declare the repo (deb822 format, used by Trixie)
sudo tee /etc/apt/sources.list.d/aims-os.sources >/dev/null <<'EOF'
Types: deb
URIs: https://a-i-m-s-senegal.github.io/aims-os
Suites: trixie
Components: main
Architectures: amd64 arm64
Signed-By: /usr/share/keyrings/aims-os-archive-keyring.gpg
EOF

sudo apt update
```

## Verify the signature

Expected fingerprint:

```
7775 7473 70C3 E86F A12D  06D7 CEAB 168E 6D2E 30FF
```

```bash
gpg --show-keys /usr/share/keyrings/aims-os-archive-keyring.gpg
```

## Pick and install

Starting with v2.1, the former monolithic metapackages have been
split into **slim** variants (the bits everyone uses) and **extras**
(everything else, install if you need it). v2.0 was monolithic.

### Easy mode, give me everything

```bash
sudo apt install aims-os-everything
```

Reproduces the full v2.0 ISO content (~9 GB after install). Pulls
all 11 metapackages in cascade.

### Subject stack

The names below are **generic** ; each AIMS centre maps them onto
its own track structure (AIMS Senegal speaks of "Regular" and "Coop",
AIMS South Africa has its own layout, etc.).

| Domain | Command |
|---|---|
| Mathematical Sciences (baseline) | `sudo apt install aims-os-math` |
| Big Data, NLP, Computer Vision, Climate, DB | `sudo apt install aims-os-bigdata` |
| Computer Security, cryptography, forensics | `sudo apt install aims-os-security` |

`aims-os-bigdata` and `aims-os-security` depend on `aims-os-math`,
so installing either pulls the SciPy / R / slim LaTeX / Jupyter
baseline.

For the mapping onto AIMS Senegal's filière names (Regular, Coop Big
Data, Coop Computer Security), see [Get started → Tracks](/en/filieres/regular/).

### Optional layers (v2.1)

| Layer | Command | Contents |
|---|---|---|
| Slim desktop | `sudo apt install aims-os-desktop` | GNOME + Firefox + LibreOffice fr + free codecs + utilities |
| Desktop extras | `sudo apt install aims-os-desktop-extras` | Chromium + GIMP + Inkscape + Evolution + non-free codecs + EN dictionaries |
| Full dev stack | `sudo apt install aims-os-desktop-dev` | OpenJDK 21 + Gradle + Kotlin + PHP + Docker + Podman + kubectl + rustup |
| Maths extras | `sudo apt install aims-os-math-extras` | Maxima + full Octave + R tidyverse + multilingual LaTeX + GeoGebra |
| Senegal centre | `sudo apt install aims-os-centre-senegal` | fr_FR locale + Africa/Dakar + AIMS-Mbour bookmarks |
| Mbour lab (fixed workstations) | `sudo apt install aims-os-centre-senegal-labo` | Key-only SSH for the IT team, `aimsit` account; off the ISO, golden machine only |
| Wizard + scripts | `sudo apt install aims-os-welcome` | Install scripts at `/usr/share/aims-os/install/*.sh` |
| System baseline | `sudo apt install aims-os-core` | Security + firmware + locales + CLI + Miniforge |

### Third-party tools (Cursor, RStudio, Node 22, Bun, Deno, uv, DBeaver, VSCodium)

Not in Debian, shipped as **install scripts** by `aims-os-welcome`:

```bash
sudo apt install aims-os-welcome

# Then pick what you need:
sudo /usr/share/aims-os/install/cursor.sh       # proprietary AI IDE
sudo /usr/share/aims-os/install/rstudio.sh      # RStudio Desktop
sudo /usr/share/aims-os/install/dbeaver.sh      # universal SQL GUI
sudo /usr/share/aims-os/install/vscodium.sh     # libre VS Code
sudo /usr/share/aims-os/install/nodejs.sh       # Node 22 LTS (NodeSource)
sudo /usr/share/aims-os/install/runtimes.sh     # Bun + Deno + uv
```

Each script fetches the tool from its official upstream (cursor.com,
posit.co, dbeaver.io, NodeSource, GitHub releases) and installs it.
Idempotent. Re-running upgrades to the latest build.

## About non-free components

The Wi-Fi / GPU firmware blobs (`firmware-iwlwifi`, `firmware-realtek`,
...) live in Debian's `non-free-firmware`; the RAR codec
(`p7zip-rar`) lives in `non-free`. AIMS OS lists them as `Recommends`
so the install does not break on a Debian that has only `main`.

If you want full hardware support, enable both components in your
`/etc/apt/sources.list` before `apt install`.

## aims-os-branding

The `aims-os-branding` package (wallpapers, GRUB theme, Plymouth
splash, Calamares branding) is deliberately **not** published on the
apt repo. It only ships with the ISO. Rewriting an existing Debian's
wallpapers without asking would be rude.
