---
title: Install from the ISO
description: Boot the AIMS OS ISO in UTM, QEMU, VirtualBox or VMware, then run the Calamares installer.
---

The AIMS OS ISO contains a bootable live system and the Calamares
installer. You can flash it to a USB key for bare metal, or boot it
in a VM (UTM on Mac M-series, QEMU/KVM on Linux, VirtualBox, VMware).

## Download

Stable links to the latest release. GitHub always redirects to the
most recent version:

- **arm64** (Mac M-series under UTM, ARM servers):
  [aims-os-1.0-arm64.iso](https://github.com/A-I-M-S-SENEGAL/aims-os/releases/latest/download/aims-os-1.0-arm64.iso)
  · [SHA-256](https://github.com/A-I-M-S-SENEGAL/aims-os/releases/latest/download/aims-os-1.0-arm64.iso.sha256)
- **amd64** (x86_64 laptops):
  [aims-os-1.0-amd64.iso](https://github.com/A-I-M-S-SENEGAL/aims-os/releases/latest/download/aims-os-1.0-amd64.iso)
  · [SHA-256](https://github.com/A-I-M-S-SENEGAL/aims-os/releases/latest/download/aims-os-1.0-amd64.iso.sha256)

Check the checksum before booting:

```bash
shasum -a 256 -c aims-os-1.0-arm64.iso.sha256
```

All releases, release notes and in-flight builds:
[github.com/A-I-M-S-SENEGAL/aims-os/releases](https://github.com/A-I-M-S-SENEGAL/aims-os/releases)

## Boot in UTM (Mac M-series)

1. Open UTM, create a new VM, **Virtualize** (not Emulate), pick **Linux**.
2. Point the **Boot ISO Image** field at `aims-os-1.0-arm64.iso`.
3. Memory: 4 GiB minimum, 8 GiB recommended for GNOME + LibreOffice.
4. Storage: 50 GiB minimum (the scientific stack + LaTeX + Cursor
   take ~12 GiB after install).
5. Network: Shared by default. ICMP ping is blocked by UTM's NAT
   even with the firewall off, use `curl https://google.com` or
   Firefox to test connectivity. TCP works fine.

## Boot in QEMU/KVM (Linux host)

```bash
qemu-system-x86_64 \
  -enable-kvm \
  -m 4G -smp 4 \
  -drive file=aims-os-disk.qcow2,format=qcow2,if=virtio \
  -cdrom aims-os-1.0-amd64.iso \
  -boot d \
  -vga virtio -display gtk
```

(For arm64, swap to `qemu-system-aarch64 -M virt -cpu host
-bios /usr/share/AAVMF/AAVMF_CODE.fd ...`)

## The GRUB menu

At boot, GRUB shows the AIMS OS menu with four entries in French:

- **Démarrer en mode Live**: live system, no install
- **Installer AIMS OS**: launches Calamares in a live session
- **Options d'installation avancées**: custom kernel parameters
- **Utilitaires**: memtest, firmware tools

Pick **Démarrer en mode Live**.

## Run Calamares

Once on the live desktop, the **Installer AIMS OS** icon sits on the
desktop and in the app grid. Double-click to start.

The flow follows the standard Calamares pattern:

1. **Welcome** — checks network and disk space
2. **Location** — Africa / Dakar by default
3. **Keyboard** — fr (France) by default, fr (Senegal) or us available
4. **Partitions** — Erase disk (VM is dedicated) or manual partitioning
5. **Users** — your name, username, password
6. **Summary** — final review
7. **Install** — runs ~20-30 minutes on a modern VM
8. **Finish** — reboot into the installed system

If the install hangs at Finish with a "package manager" error — that's
a known bug fixed in v9.1 and later. The system is actually installed,
you can reboot manually.

## First boot

On reboot, GDM shows the AIMS-OS-branded login screen. Sign in with
the user you created. The HTML welcome page opens automatically in
Firefox on first login to orient you.

See [First boot](/en/install/first-boot/) for what comes next.
