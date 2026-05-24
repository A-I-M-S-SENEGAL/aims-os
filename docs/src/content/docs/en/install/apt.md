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

| Track | Command |
|---|---|
| Regular (Mathematical Sciences) | `sudo apt install aims-os-math` |
| Coop Big Data | `sudo apt install aims-os-bigdata` |
| Coop Computer Security | `sudo apt install aims-os-security` |
| GNOME desktop layer | `sudo apt install aims-os-desktop` |
| System baseline | `sudo apt install aims-os-core` |
| Everything (matches the ISO) | `sudo apt install aims-os-{core,desktop,math,bigdata,security}` |

The `aims-os-bigdata` and `aims-os-security` packages depend on
`aims-os-math`, so installing either pulls the SciPy / R / LaTeX /
Jupyter baseline with them.

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
