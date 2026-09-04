---
title: Lab deployment
description: How the fixed machines of an AIMS lab boot from the network, install without a USB stick, get cloned and authenticate against a directory.
---

This page gives the broad picture of how an AIMS lab deploys and
administers its fixed machines with AIMS OS. Addresses, server names,
detailed procedures and access details live in the IT team's internal
runbook (private repository), not here.

## Overview

One campus server hosts four services, each in its own container:

- **FOG**: network boot (PXE), AIMS OS installation without a USB
  stick, capture of a golden machine and cloning of a whole room
  (multicast). FOG never does DHCP: the campus firewall stays the only
  DHCP server.
- **APT cache**: a machine downloads a Debian package once, the next
  ones get it from the LAN. Machines detect it automatically and work
  without it off campus.
- **FreeIPA directory**: student and teacher accounts, passwords,
  groups, and machine access rules.
- **Remote access** for the IT team, behind an upstream
  authentication; nothing is exposed directly to the Internet.

## Preparing a machine

Machines must boot in **UEFI only** (legacy boot off, Secure Boot off,
network card first in the boot order). Per-model details are in the
internal runbook.

## Installing and cloning

1. The machine boots from the network and shows the FOG menu; one
   entry starts the AIMS OS installer (current ISO served by the
   server).
2. The golden machine then gets the `aims-os-centre-senegal-labo`
   package (key-only SSH for the IT team, never suspends, clock in
   sync) and is captured in FOG.
3. Every clone is then **enrolled** in the directory with its own
   identity. The golden machine is never enrolled before capture.

## Accounts and machines

Every student has one login, valid on the machine **assigned** to them
and only there; teachers log in anywhere. The home directory is created
at first login and a forgotten password is reset from the directory
UI. Every login is logged (who, which machine, when), which keeps the
hardware follow-up reliable. Assignment, release and the login report
are done with the `aims-labo` tool on the server.

## Known traps

- **FOG menu then "Boot from SAN device failed" or GRUB4DOS**: the
  machine is in legacy mode. Set the BIOS back to UEFI only.
- **Kernel panic with "Initramfs unpacking failed"** right after the
  FOG menu: the FOG exit type must be `exit`, not rEFInd.
- **Machine that does not power off** at the end of a network-started
  install: fixed in AIMS OS 2.1.2 (immediate restart).
- **Dates in Wolof** after installation: fixed in AIMS OS 2.1.3
  (fr_FR locale forced at first boot).
- **Machine installed before AIMS OS 2.1.3 without `aims-os-desktop`**:
  run `sudo apt install aims-os-desktop` once.
