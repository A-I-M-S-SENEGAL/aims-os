# AIMS OS apt repository

Official apt repo for AIMS OS metapackages, hosted on GitHub Pages.

It lets you install the AIMS OS scientific stack on top of any existing
Debian Trixie box, without flashing the full ISO.

## One-time setup

```bash
# 1. Trust the AIMS OS signing key
sudo curl -fsSL https://a-i-m-s-senegal.github.io/aims-os/aims-os-archive-keyring.gpg \
    -o /usr/share/keyrings/aims-os-archive-keyring.gpg

# 2. Add the repo (deb822 format, used by Trixie's apt)
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

## Pick what you need

| Filière | Command |
|---|---|
| Regular (Mathematical Sciences) | `sudo apt install aims-os-math` |
| Coop Big Data Analytics | `sudo apt install aims-os-bigdata` |
| Coop Computer Security | `sudo apt install aims-os-security` |
| GNOME desktop layer | `sudo apt install aims-os-desktop` |
| System baseline (firmware, locales, CLI) | `sudo apt install aims-os-core` |
| Everything | `sudo apt install aims-os-{core,desktop,math,bigdata,security}` |

The bigdata and security packages already depend on `aims-os-math`, so
installing either pulls the SciPy / R / LaTeX / Jupyter stack with them.

## Verify the signature

```bash
gpg --show-keys /usr/share/keyrings/aims-os-archive-keyring.gpg
```

Expected fingerprint:

```
7775 7473 70C3 E86F A12D  06D7 CEAB 168E 6D2E 30FF
```

## What's in each metapackage

The `debian/control` files in the [source repo](https://github.com/A-I-M-S-SENEGAL/aims-os)
are the truth. Each lists exactly what it pulls in its `Depends:` field.

## Source and bugs

- Source: https://github.com/A-I-M-S-SENEGAL/aims-os
- Bugs: hakim@aims-senegal.org or [GitHub Issues](https://github.com/A-I-M-S-SENEGAL/aims-os/issues)
