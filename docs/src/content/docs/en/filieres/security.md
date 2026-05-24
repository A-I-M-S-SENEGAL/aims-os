---
title: Coop track — Computer Security
description: Cryptography, network audit, forensics for the Coop Security track.
---

The Coop Computer Security track adds on top of the Regular baseline
the cryptographic toolkit, network audit and computer forensics.

## Metapackage: `aims-os-security`

On an existing Debian:

```bash
sudo apt install aims-os-security
```

(Pulls `aims-os-math` automatically if not already there.)

## What's added

### Cryptography
- `python3-cryptography` — modern primitives (AEAD, X.509, KDF)
- `python3-pycryptodome` — drop-in PyCrypto, cited by lecture notes

Qiskit (Quantum Computing course) is **not** packaged in a current
version. Install on demand:

```bash
pipx install qiskit
# or
mamba install -c conda-forge qiskit
```

### Network audit
- `nmap` — port / service scan
- `wireshark` — packet capture + analysis (dumpcap setuid: see below)
- `tcpdump` — CLI capture
- `python3-scapy` — packet crafting

### Cracking
- `john` (John the Ripper) — password cracking
- `hashcat` — GPU-accelerated hash cracking
- `aircrack-ng` — Wi-Fi audit

### Forensics
- `sleuthkit` — filesystem + disk analysis
- `foremost` — file carving
- `binwalk` — firmware analysis / extraction

## Wireshark without sudo

On the AIMS OS ISO, `dumpcap` is already configured setuid root
(`wireshark-common/install-setuid=true` via preseed). The first-boot
service adds your account to the `wireshark` group at first boot.

On a standalone apt install, debconf asks you at `apt install
wireshark` whether you want the setuid. Answer "yes", then:

```bash
sudo usermod -aG wireshark $USER
newgrp wireshark
# or logout / login
```

## Courses covered

- Auditing Computer Forensics and Investigation
- Computer Network
- Computer Security 1: Network Security
- Computer Security: Case studies from industries
- Ethical Hacking
- Mathematical Model for Network Security
- Post Quantum Cryptography
- Quantum Mechanics and Computing (partial libs, Qiskit on-demand)

See the [full mapping](/en/courses/mapping/) for the breakdown.
