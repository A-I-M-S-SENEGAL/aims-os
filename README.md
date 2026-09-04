# AIMS OS

**A Debian-based GNU/Linux distribution built at AIMS Senegal.**

AIMS OS is a custom GNU/Linux distribution for the African Institute for
Mathematical Sciences, Senegal. Version 2.1 ships a slim live ISO: a GNOME
desktop, the Calamares installer, and the scientific baseline every AIMS
student uses (Jupyter, the SciPy ecosystem, R, a French TeX Live), bilingual
French and English out of the box, on a clean Debian 13 (Trixie) base. The
heavier layers (full TeX Live, Octave, Maxima, TeXstudio, the Coop track
toolchains) install on demand from the AIMS apt repository, which the ISO
preconfigures, either through the first-boot wizard or a plain `apt install`.
SageMath is install-on-demand via Miniforge
(`mamba install -c conda-forge sagemath`) since upstream has not yet packaged
it for Python 3.13.

---

## Quick facts

| | |
|---|---|
| Codename | AIMS OS |
| Version | 2.1 |
| Base | Debian 13 (Trixie) |
| Desktop | GNOME 48 |
| Installer | Calamares 3.3 |
| Architectures | amd64, arm64 |
| Locales | fr_FR.UTF-8 (default), en_US.UTF-8 |
| Timezone | Africa/Dakar |
| Apt repo | [a-i-m-s-senegal.github.io/aims-os](https://a-i-m-s-senegal.github.io/aims-os/) |
| Maintainer | AIMS Senegal IT &lt;hakim@aims-senegal.org&gt; |
| Upstream | [github.com/A-I-M-S-SENEGAL/aims-os](https://github.com/A-I-M-S-SENEGAL/aims-os) |
| Status | v2.1.0 (Trixie, slim) released; development on `main` |

## Repository layout

```
aims_os/
├── .github/        # CI: ISO builds, boot tests, apt repo + docs publishing
├── docker/         # build container (live-build inside privileged Debian)
├── build/          # live-build config + host-side build wrapper
├── metapackages/   # 13 metapackages defining the distro package set
│   ├── aims-os-core/            # base system, security, locales, build tools
│   ├── aims-os-desktop/         # slim GNOME, Calamares, Firefox, LibreOffice fr
│   ├── aims-os-math/            # slim scientific stack: SciPy, Jupyter, R, TeX fr
│   ├── aims-os-branding/        # plymouth, grub, wallpapers, theming (ISO only)
│   ├── aims-os-welcome/         # first-boot wizard runtime + post-install scripts
│   ├── aims-os-centre-senegal/  # AIMS Senegal (Mbour) centre profile
│   ├── aims-os-centre-senegal-labo/  # Mbour lab workstations: IT SSH access (apt only)
│   ├── aims-os-desktop-extras/  # Chromium, GIMP, Inkscape, non-free codecs
│   ├── aims-os-desktop-dev/     # Java, PHP, containers, Rust
│   ├── aims-os-math-extras/     # Maxima, Octave, full TeX Live, R tidyverse
│   ├── aims-os-bigdata/         # Coop Big Data track
│   ├── aims-os-security/        # Coop Computer Security track
│   └── aims-os-everything/      # pulls every layer in one apt install
├── apt-repo/       # apt repository tooling, published to GitHub Pages
├── branding/       # source artwork (logos, plymouth, grub, wallpapers)
└── docs/           # build and contributor docs (Astro Starlight site)
```

The live ISO carries six layers: core, branding, desktop, math,
centre-senegal and welcome. Everything else comes from the AIMS apt repo
after installation.

## Building an ISO

Builds run on GitHub Actions; the hosted runners provide the disk space and
privileges live-build needs, natively for both architectures:

```bash
gh workflow run build-iso.yml                 # amd64 + arm64
gh workflow run build-iso.yml -f arch=arm64   # one architecture
```

ISOs are attached to the run as artifacts. Tagged `v*` releases also upload
to Cloudflare R2 and publish the apt repo. A local Docker-based build exists
for debugging; see [`docs/BUILD.md`](docs/BUILD.md):

```bash
./build/build.sh arm64    # native on Apple Silicon (~10 min)
./build/build.sh amd64    # QEMU emulation on Apple Silicon (~30 to 45 min)
```

## License & trademarks

AIMS OS build scripts and configuration are licensed under
[GPL-3.0](LICENSE). Included Debian packages retain their original upstream
licenses.

AIMS OS is a **derivative work of Debian GNU/Linux**. *Debian* is a
registered trademark of Software in the Public Interest, Inc. See
[COPYRIGHT](COPYRIGHT) for the full notice.

The *AIMS* name and logo are trademarks of the African Institute for
Mathematical Sciences and are used here with institutional authorization.
