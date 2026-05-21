# Building AIMS OS

This guide walks through producing an AIMS OS ISO from source on a **macOS
host with Apple Silicon (M1 / M2 / M3 / M4)**. Linux hosts work too — the
Docker layer makes the build host-agnostic — but this document targets the
primary developer setup at AIMS Senegal IT.

---

## 1. What you need

| Requirement | Notes |
|---|---|
| **macOS** | 14 Sonoma or newer recommended |
| **Apple Silicon** | M1 / M2 / M3 / M4 (Intel Macs also work, with no QEMU tax) |
| **Docker Desktop for Mac** | 4.30 or newer; Rosetta-x86 emulation enabled in *Settings → General → "Use Rosetta for x86_64/amd64 emulation"* |
| **Free disk space** | 40 GB minimum (chroot + cache + ISO + intermediate files) |
| **RAM** | 8 GB minimum, 16 GB recommended |
| **Tools** | `git`, [`gh`](https://cli.github.com/) (optional, for cloning private repo) |

> **Why Docker?** `live-build` is a Linux tool that needs root, loop devices
> and a chroot — none of which macOS provides natively. Docker Desktop runs
> a Linux VM under the hood; we just bring our own privileged container.

### Docker resources (recommended)

Open **Docker Desktop → Settings → Resources** and raise:
- **CPUs**: 6+ (or all your performance cores)
- **Memory**: 8 GB+
- **Disk image size**: 60 GB+

---

## 2. Clone the repository

```bash
# via HTTPS (gh auth)
gh repo clone A-I-M-S-SENEGAL/aims-os
cd aims-os

# or via SSH
git clone git@github.com:A-I-M-S-SENEGAL/aims-os.git
cd aims-os
```

---

## 3. Build an ISO

The build is a single command. The script handles Docker, target architecture
selection, and live-build orchestration.

### Native arm64 build (recommended for development)

```bash
./build/build.sh arm64
```

- ~10 minutes on M4 (no emulation)
- Boots on Apple Silicon VMs (UTM, Parallels, OrbStack), Raspberry Pi 4/5,
  most modern ARM SBCs
- Use this to **iterate** on config, branding, package lists

### Cross-built amd64 build (for AIMS Senegal lab PCs)

```bash
./build/build.sh amd64
```

- ~30–45 minutes on M4 (Docker runs Linux/amd64 via QEMU + Rosetta)
- Boots on every Intel/AMD PC at AIMS Senegal (Mbour) and elsewhere
- Use this to ship the **production ISO**

### Output

ISOs land in:

```
build/out/aims-os-1.0-arm64.iso
build/out/aims-os-1.0-amd64.iso
```

A SHA-256 sum file is generated alongside each ISO.

---

## 4. Testing an ISO

### On macOS using UTM (free, recommended)

1. Install [UTM](https://mac.getutm.app/) (App Store or direct download).
2. New VM → Virtualize → Linux → browse to the matching-arch ISO.
3. 4 GB RAM, 30 GB disk, EFI boot.
4. Boot.

> Important: UTM in *virtualize* mode is fast but **only runs arm64 on
> Apple Silicon**. To test the amd64 ISO on Apple Silicon, switch UTM to
> *emulate* mode (QEMU) — it will be slow but functional.

### Writing to a USB stick (real hardware)

```bash
# find your USB device (be VERY careful — wrong target = data loss)
diskutil list

# unmount it (replace diskN with the right number)
diskutil unmountDisk /dev/diskN

# write the ISO (use the raw device "rdiskN" for speed)
sudo dd if=build/out/aims-os-1.0-amd64.iso of=/dev/rdiskN bs=4m status=progress
sync
diskutil eject /dev/diskN
```

---

## 5. What happens during a build

The build is a 5-stage pipeline orchestrated by `build/build.sh`:

```
   ┌───────────────────────────────────────────────────────────────┐
   │ 1. docker run --privileged debian:trixie    (target platform) │
   │ 2. entrypoint.sh creates /dev/loop[0-15] via mknod             │
   │ 3. lb config   (reads build/auto/config)                       │
   │ 4. lb build    (debootstrap → chroot → install pkgs → ISO)     │
   │ 5. ISO copied back to build/out/ on the host                   │
   └───────────────────────────────────────────────────────────────┘
```

The metapackages defined in `metapackages/` are built first and seeded into
a local APT repository inside the chroot, then `lb build` pulls them in
alongside the upstream Debian packages.

---

## 6. Troubleshooting

### Build fails with `losetup: cannot find an unused loop device`

The container's `/dev/loop*` nodes were not created. Either Docker is not
running privileged, or the entrypoint did not run. Re-pull the build image:

```bash
docker rmi aims-os-builder
./build/build.sh arm64
```

### Build hangs at `debootstrap`

Almost always a network issue between the container and `deb.debian.org`.
Test:

```bash
docker run --rm debian:trixie curl -I https://deb.debian.org/debian/
```

If that fails, restart Docker Desktop.

### "No space left on device" mid-build

The Docker VM disk filled up. Raise *Docker Desktop → Settings → Resources →
Disk image size*, or prune:

```bash
docker system prune -a --volumes
```

### amd64 build is unbearably slow

That's QEMU emulation under Docker. Three options:
1. Iterate on **arm64** locally, only build amd64 for releases.
2. Run the build on a Linux/amd64 server (a $5/month VPS does the job).
3. Ensure *Settings → General → "Use Rosetta for amd64 emulation"* is on —
   it noticeably speeds up user-space code, though syscalls still go through
   QEMU.

---

## 7. Clean rebuild

```bash
./build/build.sh clean         # removes chroot, cache, intermediate state
./build/build.sh arm64         # rebuild
```

---

## 8. Architecture reference

| File | Role |
|---|---|
| `docker/Dockerfile` | Builds the `aims-os-builder` image (Debian + live-build + helpers) |
| `docker/entrypoint.sh` | Creates loop devices, then `exec`s the build command |
| `build/build.sh` | Host-side wrapper: arch selection, docker run, ISO extraction |
| `build/config/auto/config` | `lb config` parameters (Bookworm, GNOME, Calamares, branding) |
| `build/config/package-lists/` | Lists of packages to install into the live system |
| `build/config/hooks/` | Hooks executed inside the chroot (e.g. apply branding) |
| `build/config/includes.chroot/` | Files copied verbatim into the live filesystem |
| `metapackages/aims-os-*/` | The four metapackages that define the distro |

For the actual implementation of each component, see the corresponding
source files in this repository.
