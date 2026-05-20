# Testing an AIMS OS ISO

This guide walks through booting and validating an AIMS OS ISO on a macOS
host with Apple Silicon (M1–M4), using **UTM**. The same procedure
applies to a real PC (USB stick) — only the VM creation step changes.

Two ISOs are produced by every CI build, attached to each successful run
on the [Actions page](https://github.com/A-I-M-S-SENEGAL/aims-os/actions):

| File | Size | For |
|---|---|---|
| `aims-os-1.0-amd64.iso` | ~6.6 GB | Intel/AMD PCs (Mbour labs, generic laptops) |
| `aims-os-1.0-arm64.iso` | ~6.1 GB | Raspberry Pi 4/5, ARM laptops, **fast UTM on M1–M4** |

Test the **arm64** ISO first on a Mac — it virtualises natively
(near-bare-metal speed) and exercises the same hooks, the same metapackage
graph, and the same branding as amd64. If something is broken visually or
functionally, you will see it here too.

---

## 1. Install UTM

UTM is the standard QEMU-based virtualiser for Apple Silicon. Free, open
source, two install options:

```bash
brew install --cask utm
```

or download the .dmg from <https://mac.getutm.app/>. The App Store version
is a $10 paid one (same software, supports the developer).

Requires **macOS 13 (Ventura) or newer**.

---

## 2. Create the VM (arm64, **Virtualize** mode)

1. Open UTM → **Create a New Virtual Machine** → **Virtualize**.
2. Operating System: **Linux**.
3. Boot ISO Image: click *Browse* and pick `aims-os-1.0-arm64.iso`.
   Leave "Boot from kernel image" unchecked, "Use Apple Virtualization"
   unchecked (QEMU backend is more stable for our purposes), and
   "Enable Rosetta" unchecked (we don't need x86 binary translation in
   an arm64 VM).
4. Memory: **6144 MB** (6 GB) recommended. 4 GB minimum, 8 GB if your Mac
   has 16 GB+ of RAM.
5. CPU Cores: **4**.
6. Storage: **30 GB**. (Live session works fine without it; you only need
   disk if you'll test the Calamares installer.)
7. Shared Directory: skip.
8. Summary → review → **Save**. Pick a name like *AIMS OS test*.
9. Before pressing Play, open the VM settings (right-click → Edit):
   - **System** → *Architecture* must be `aarch64` (Apple Silicon, ARM 64-bit).
   - **Display** → *Display Card* `virtio-ramfb-gl (GPU Supported)` if
     available, else `virtio-gpu-pci`. Keep `Retina Mode` on.
   - **Network** → `Emulated VLAN`, *Network Mode* `Shared Network`.
10. Press ▶ to boot.

### amd64 ISO (slower, optional)

If you specifically need to test amd64 on a Mac (recommended only if you
have no PC available), the procedure is the same except in step 1 choose
**Emulate**, in step 2 *Architecture* select `x86_64`, *System* `Standard
PC (Q35 + ICH9, 2009)`, and add ~50% more RAM. Boot takes 5–10× longer
because every instruction goes through QEMU's TCG translator.

---

## 3. The boot test — 12-point checklist

Mark each item as the screen reaches it. The first time anything looks
wrong, file an issue on [aims-os/issues](https://github.com/A-I-M-S-SENEGAL/aims-os/issues)
with a screenshot.

```text
☐  1. GRUB menu displays
       Background: cream (#F5EFE7), AIMS circle logo + wordmark
       Menu entries: live (default), live failsafe, install (Calamares)
       No raw text or broken theme fallback

☐  2. Plymouth boot splash
       Cream background, static AIMS circle logo centred
       Ring of 12 terracotta rays rotates slowly around the logo
       No error text scrolls past

☐  3. GDM / live auto-login
       AIMS wordmark visible (we don't customise GDM further in v1.0)
       Auto-login to user `aims` succeeds

☐  4. GNOME desktop appears
       Wallpaper = AIMS circle logo, cream background
       Top bar: French labels (Activités, not Activities)
       Bottom dock visible

☐  5. Default app dock (favourites)
       Firefox, GNOME Terminal, Files, LibreOffice Writer, GeoGebra,
       TeXstudio, GNOME Software — in this order, all pinned

☐  6. System identity
       In a terminal:
           $ cat /etc/os-release
       Must print PRETTY_NAME="AIMS OS 1.0", ID=aims-os, ID_LIKE=debian

☐  7. Locale + timezone
           $ locale
           $ date
       Must show fr_FR.UTF-8 and Africa/Dakar (WAT / WAT+0 = UTC+0)

☐  8. Scientific stack
           $ mamba --version          (or conda)
           $ python3 -c "import numpy, scipy, sklearn, pandas; print('ok')"
           $ R --version
           $ jupyter notebook --version
           $ sage --version
       All should print sensible versions.

☐  9. Flatpak / Flathub
           $ flatpak remotes
       Must list `flathub`. (Either registered during build, or by the
       aims-flathub-init systemd unit on first boot — give it 30 s.)

☐ 10. Network
       Open Firefox → page loads
       (If no network: nm-applet → check connections)

☐ 11. Calamares launch
       From the desktop launcher click "Installer AIMS OS"
       The Calamares window must open and reach the "Welcome" page
       (Branding still says "Debian" in v1.0 — known, on the roadmap.)

☐ 12. Persistent install (optional but recommended)
       Walk through Calamares to the end on the 30 GB virtual disk.
       Reboot the VM without the ISO.
       Repeat checks 1–9 in the installed system.
```

---

## 4. What to look for — common failure modes

| Symptom | Likely cause | Fix area |
|---|---|---|
| GRUB shows generic blue/black, no AIMS theme | `/etc/default/grub.d/aims-os.cfg` not read OR `update-grub` not run | `aims-os-branding` postinst |
| Plymouth shows plain text / no logo | Plymouth theme not activated; initramfs not regenerated | `plymouth-set-default-theme -R aims-os` in postinst |
| Wallpaper missing (plain colour) | `dconf update` not run, picture-uri path wrong | `0090-dconf-update` hook + 00-aims-os defaults |
| English UI everywhere | `fr_FR.UTF-8` not generated | `aims-os-core` locales config + `task-french-desktop` |
| `mamba: command not found` | `/etc/profile.d/aims-miniforge.sh` not loaded | re-source ~/.bashrc, or fix profile.d script |
| Flathub not in `flatpak remotes` | First-boot service didn't run (network not up yet) | give it 30 s, then `systemctl status aims-flathub-init` |
| Calamares window doesn't open | Missing `calamares-settings-debian` or polkit rule | check `~/.cache/calamares/session.log` |
| Wi-Fi adapter not detected | Firmware blob missing | confirm `non-free-firmware` enabled in sources; add specific firmware-* package |

---

## 5. Reporting findings

After your test, open one issue per problem at
<https://github.com/A-I-M-S-SENEGAL/aims-os/issues>. Useful info to
include:

- The exact ISO file name and SHA-256 you tested
- arm64 vs amd64
- Test environment (UTM version, host macOS version, host Mac model)
- Screenshot of the broken state
- Output of `journalctl -b -p err` (errors since last boot)

A successful pass = the checklist's twelve ✅. When that happens, we
can tag `v1.0` and the release workflow will auto-publish both ISOs to
[GitHub Releases](https://github.com/A-I-M-S-SENEGAL/aims-os/releases).
