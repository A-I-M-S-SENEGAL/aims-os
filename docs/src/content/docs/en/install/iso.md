---
title: Install from the ISO
description: Boot the AIMS OS ISO in UTM, QEMU, VirtualBox or VMware, then run the Calamares installer.
---

The AIMS OS ISO contains a bootable live system and the Calamares
installer. You can flash it to a USB key for bare metal, or boot it
in a VM (UTM on Mac M-series, QEMU/KVM on Linux, VirtualBox, VMware).

## Download

ISOs live on Cloudflare R2 (GitHub Releases cap assets at 2 GiB and
our images are ~7.7 GB). Stable links, updated on every release:

- **arm64** (Mac M-series under UTM, ARM servers):
  [aims-os-1.0-arm64.iso](https://pub-5d3e0470a4ad4b4484092f7263fc8e17.r2.dev/latest/aims-os-1.0-arm64.iso)
  · [SHA-256](https://pub-5d3e0470a4ad4b4484092f7263fc8e17.r2.dev/latest/aims-os-1.0-arm64.iso.sha256)
- **amd64** (x86_64 laptops):
  [aims-os-1.0-amd64.iso](https://pub-5d3e0470a4ad4b4484092f7263fc8e17.r2.dev/latest/aims-os-1.0-amd64.iso)
  · [SHA-256](https://pub-5d3e0470a4ad4b4484092f7263fc8e17.r2.dev/latest/aims-os-1.0-amd64.iso.sha256)

Check the checksum before booting. The `.sha256` is also attached
to the matching [GitHub Release](https://github.com/A-I-M-S-SENEGAL/aims-os/releases)
so you can pin a version:

```bash
shasum -a 256 -c aims-os-1.0-arm64.iso.sha256
```

For a specific version instead of "latest", swap `latest` for the
tag in the URL — for example
`.r2.dev/v2.1.0/aims-os-1.0-arm64.iso`. Tagged versions are
immutable, useful for lab deployments that want to pin an image.

For **pre-releases** (`-alpha`, `-beta`, `-rc`) — they deliberately
don't update `latest/` (safety for stable deployments). Use the
explicit versioned URL, e.g.
`.r2.dev/v2.2.0-alpha1/aims-os-1.0-arm64.iso`.

All releases:
[github.com/A-I-M-S-SENEGAL/aims-os/releases](https://github.com/A-I-M-S-SENEGAL/aims-os/releases)

## Flash to a USB stick (real laptop, physical machine)

The most common case for AIMS students. You'll need a USB stick of
**16 GB minimum** (the ISO is ~7.7 GB and Calamares uses extra during
install).

:::caution
Flashing **erases everything** on the stick. Back up first.
:::

### Recommended: Ventoy (all platforms)

**Why not Rufus / Etcher**: these tools write the ISO byte by byte
onto the stick (DD mode). That's slow by nature, especially on
mid-range USB sticks: 30-60 min for 7.7 GB on a decent USB 3.0
stick, over an hour on a cheap one that actually tops out at
5-10 MB/s sustained write. And every new AIMS OS release means a
full re-flash.

**Ventoy changes the model**. You install Ventoy on the stick
**once** (~30 seconds, formats into two partitions). After that,
you copy the ISO onto the stick **like a normal file**: no more
Rufus, no more wait on every update, no more "wrong disk" risk. On
boot, a Ventoy menu lets you pick the image.

Bonus: multiple ISOs fit on the same stick (AIMS OS + Debian rescue
+ Windows installer, all together).

**Install Ventoy**:

1. Download [Ventoy](https://www.ventoy.net/) (Windows / macOS /
   Linux, GUI or CLI).
2. Plug the USB stick in. **Everything on it will be wiped** — back
   up first.
3. Launch Ventoy → pick the stick → **Install**. Takes ~30 s.

**Add / update AIMS OS**:

1. Open the stick in your file manager (macOS Finder, Windows
   Explorer, Linux Files).
2. Drag `aims-os-1.0-<arch>.iso` into the root of the stick. Time =
   regular file-copy speed (often 1-3 min for 7.7 GB on USB 3.0).
3. Eject the stick cleanly.
4. Boot the PC from the stick → Ventoy menu → pick AIMS OS → GRUB.

**Updating to a new release**: delete the old `.iso`, copy the new
one in. No reformatting, no Rufus.

### Alternatives

If Ventoy isn't an option (IT policy, stick already flashed), here
are the classic single-ISO flows.

#### balenaEtcher (cross-OS, GUI)

Works the same on macOS, Windows and Linux. Verifies the checksum
on its own.

1. Download [balenaEtcher](https://etcher.balena.io/) → install.
2. Open Etcher → **Flash from file** → pick the AIMS OS ISO.
3. **Select target** → pick the USB stick (double-check the disk
   letter/number).
4. **Flash!** → wait depending on stick speed.
5. Once "Flash Complete", unplug.

#### macOS — command line (`dd`)

```bash
# Identify the device for the stick (e.g., /dev/disk4). Plug the
# stick IN THEN run the command to see what shows up.
diskutil list

# Unmount (do not eject)
diskutil unmountDisk /dev/disk4

# Flash. WATCH the disk number — wrong choice OVERWRITES your
# system disk. /dev/rdiskN (with 'r') is ~5x faster than /dev/diskN.
sudo dd if=~/Downloads/aims-os-1.0-amd64.iso of=/dev/rdisk4 bs=4m status=progress
sudo sync

# Eject properly
diskutil eject /dev/disk4
```

#### Linux — `dd` or GNOME Disks

CLI:
```bash
lsblk                                  # spot your stick (e.g., /dev/sdc)
sudo umount /dev/sdc?                  # unmount every partition
sudo dd if=aims-os-1.0-amd64.iso of=/dev/sdc bs=4M status=progress oflag=sync
```

Or GUI: open **GNOME Disks** → pick the stick → menu (⋮) →
**Restore Disk Image** → pick the ISO.

#### Windows — Rufus

[Rufus](https://rufus.ie/) remains the Windows standard for a
single-ISO flash:
1. Launch Rufus → **Device** = USB stick.
2. **Boot selection** → SELECT → pick the ISO.
3. **Partition scheme**: GPT (modern UEFI). **Target system**: UEFI.
4. **START** → if Rufus asks "DD Image" vs "ISO Image", pick
   **DD Image** (the AIMS ISO is isohybrid).

:::tip
Rufus DD mode writes byte by byte → time = the stick's actual
sustained write speed. A "USB 3.0 latest generation" cheap stick
often tops out at 10-30 MB/s = 4-13 min for 7.7 GB. A genuine
Sandisk Extreme Pro / Samsung BAR Plus runs at 150 MB/s = ~1 min.
Quick test: run `CrystalDiskMark` on Windows to measure your stick.
If you're flashing multiple times or doing regular updates, switch
to Ventoy (above).
:::

### Boot from the stick

1. Plug the USB stick into the **powered-off** target machine.
2. Power on while holding the **boot menu** key:
   - HP / Dell / Lenovo ThinkPad: **F12**
   - Acer: **F12** or **Esc**
   - ASUS: **F8** or **Esc**
   - MSI: **F11**
   - Intel Mac: **Option/⌥** (then pick EFI Boot)
   - Mac M-series (Asahi): see Asahi Linux docs, more involved
3. Pick the USB stick from the boot menu.
4. The AIMS OS GRUB menu shows → **Démarrer en mode Live**.

On recent laptops with **Secure Boot** enabled: AIMS OS ships
Debian's signed shim, so it boots without touching the BIOS. If it
refuses, disable Secure Boot in the UEFI firmware (usually **F2**,
**F10** or **Del** at power-on).

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

If the install hangs at Finish with a "package manager" error. That’s
a known bug fixed in v9.1 and later. The system is actually installed,
you can reboot manually.

## First boot

On reboot, GDM shows the AIMS-OS-branded login screen. Sign in with
the user you created. The HTML welcome page opens automatically in
Firefox on first login to orient you.

See [First boot](/en/install/first-boot/) for what comes next.
