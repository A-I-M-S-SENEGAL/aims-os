# AIMS OS

**A Debian-based GNU/Linux distribution built at AIMS Senegal.**

AIMS OS is a custom GNU/Linux distribution designed for the African Institute for
Mathematical Sciences — Senegal. It bundles a GNOME desktop with the scientific
toolchain used in AIMS curricula (SageMath, Jupyter, Octave, R, TeXstudio, GeoGebra,
the SciPy stack…) on top of a clean Debian 12 (Bookworm) base, with bilingual French
and English support out of the box.

---

## Quick facts

| | |
|---|---|
| Codename | AIMS OS 1.0 |
| Base | Debian 12 (Bookworm) |
| Desktop | GNOME |
| Installer | Calamares |
| Architectures | amd64, arm64 |
| Locales | fr_SN.UTF-8 (default), en_US.UTF-8 |
| Maintainer | AIMS Senegal IT &lt;hakim@aims-senegal.org&gt; |
| Upstream | [github.com/A-I-M-S-SENEGAL/aims-os](https://github.com/A-I-M-S-SENEGAL/aims-os) |
| Status | 0.1 — bootstrap |

## Repository layout

```
aims_os/
├── docker/         # build container (live-build inside privileged Debian)
├── build/          # live-build config + entrypoint script
├── metapackages/   # 4 metapackages defining the distro package set
│   ├── aims-os-core/       # base system, fonts, locales
│   ├── aims-os-desktop/    # GNOME and end-user apps
│   ├── aims-os-math/       # scientific software stack
│   └── aims-os-branding/   # plymouth, grub, wallpapers, gnome theming
├── branding/       # source artwork (logos, plymouth, grub, wallpapers)
└── docs/           # build and contributor docs
```

## Building an ISO

See [`docs/BUILD.md`](docs/BUILD.md) for the full guide. The short version on a
macOS host (Apple Silicon):

```bash
# arm64 ISO — native, fast (~10 min)
./build/build.sh arm64

# amd64 ISO — emulated via QEMU, slower (~30–45 min)
./build/build.sh amd64
```

ISO files land in `build/out/`.

## License & trademarks

AIMS OS build scripts and configuration are licensed under [GPL-3.0](LICENSE).
Included Debian packages retain their original upstream licenses.

AIMS OS is a **derivative work of Debian GNU/Linux**. *Debian* is a registered
trademark of Software in the Public Interest, Inc. See [COPYRIGHT](COPYRIGHT) for
the full notice.

The *AIMS* name and logo are trademarks of the African Institute for Mathematical
Sciences and are used here with institutional authorization.
