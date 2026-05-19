# syntax=docker/dockerfile:1.7
# =============================================================================
# AIMS OS — builder image
# =============================================================================
# Produces a `aims-os-builder` image with `live-build` and all of its
# Debian-side helpers (debootstrap, xorriso, squashfs-tools, bootloader
# tooling, archive keyring, equivs for metapackages…).
#
# The image base is the same Debian release we are TARGETING (Bookworm) — this
# avoids any host/target skew in live-build's behavior.
#
# This Dockerfile is architecture-neutral. The target architecture is
# selected by the caller via `docker run --platform linux/amd64` or
# `linux/arm64`; Docker Desktop on Apple Silicon emulates amd64 via QEMU.
# =============================================================================

FROM debian:bookworm-slim

LABEL org.opencontainers.image.title="AIMS OS builder"
LABEL org.opencontainers.image.description="Debian Bookworm + live-build for assembling AIMS OS ISOs"
LABEL org.opencontainers.image.vendor="AIMS Senegal"
LABEL org.opencontainers.image.source="https://github.com/A-I-M-S-SENEGAL/aims-os"
LABEL org.opencontainers.image.licenses="GPL-3.0-only"

ENV DEBIAN_FRONTEND=noninteractive \
    LANG=C.UTF-8 \
    LC_ALL=C.UTF-8

# -----------------------------------------------------------------------------
# Install the live-build toolchain.
#
#   live-build / debootstrap        — the actual ISO builder + base bootstrapper
#   mmdebstrap                       — modern, rootless-capable bootstrapper
#                                       (live-build can use it when available)
#   xorriso / squashfs-tools / cpio  — ISO + initrd plumbing
#   isolinux / syslinux-common / syslinux-efi
#                                    — BIOS boot for amd64 ISOs
#   grub-pc-bin                      — BIOS-mode GRUB stage for amd64
#   grub-efi-amd64-bin               — UEFI GRUB for amd64
#   grub-efi-arm64-bin               — UEFI GRUB for arm64
#   grub-common / grub2-common       — shared GRUB scaffolding
#   mtools / dosfstools / parted     — FAT EFI partitions and disk layout
#   debian-archive-keyring           — verify the upstream archive
#   apt-utils / ca-certificates      — apt + TLS
#   equivs                           — used to compile our metapackages
#   gnupg / curl / wget / git / sudo — utility surface for hooks and scripts
# -----------------------------------------------------------------------------
RUN apt-get update \
 && apt-get install -y --no-install-recommends \
        live-build \
        debootstrap \
        mmdebstrap \
        xorriso \
        squashfs-tools \
        cpio \
        isolinux \
        syslinux-common \
        syslinux-efi \
        grub-pc-bin \
        grub-efi-amd64-bin \
        grub-efi-arm64-bin \
        grub-common \
        grub2-common \
        mtools \
        dosfstools \
        parted \
        debian-archive-keyring \
        apt-utils \
        ca-certificates \
        equivs \
        gnupg \
        curl \
        wget \
        git \
        sudo \
        rsync \
        file \
        locales \
 && rm -rf /var/lib/apt/lists/*

# -----------------------------------------------------------------------------
# Make sure the chroot has a sane locale to draw from.
# -----------------------------------------------------------------------------
RUN sed -i -E 's/^# *(en_US\.UTF-8|fr_FR\.UTF-8|fr_SN\.UTF-8)/\1/' /etc/locale.gen \
 && locale-gen

# -----------------------------------------------------------------------------
# Entrypoint: creates /dev/loop[0-15] device nodes via mknod (worked around
# https://github.com/moby/moby/issues/27886) and then execs the requested
# command. `lb build` is the default.
# -----------------------------------------------------------------------------
COPY docker/entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod 0755 /usr/local/bin/entrypoint.sh

WORKDIR /build

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
CMD ["lb", "build"]
