---
title: Filière Coop — Computer Security
description: Cryptographie, audit réseau, forensics pour la filière Coop Security.
---

La filière Coop Computer Security ajoute par-dessus la base Regular
le toolkit cryptographique, l'audit réseau et la forensics
informatique.

## Métapaquet : `aims-os-security`

Sur Debian existant :

```bash
sudo apt install aims-os-security
```

(Pulls automatiquement `aims-os-math` si pas déjà là.)

## Ce qui est ajouté

### Cryptographie
- `python3-cryptography` — primitives modernes (AEAD, X.509, KDF)
- `python3-pycryptodome` — drop-in PyCrypto, cité par les énoncés

Qiskit (cours Quantum Computing) n'est **pas** packagé en version
courante. Installation à la demande :

```bash
pipx install qiskit
# ou
mamba install -c conda-forge qiskit
```

### Audit réseau
- `nmap` — scan ports / services
- `wireshark` — capture + analyse paquets (dumpcap setuid : voir plus bas)
- `tcpdump` — capture CLI
- `python3-scapy` — packet crafting

### Cracking
- `john` (John the Ripper) — cassage mots de passe
- `hashcat` — accélération GPU pour hash cracking
- `aircrack-ng` — audit Wi-Fi

### Forensics
- `sleuthkit` — analyse système de fichiers + disques
- `foremost` — file carving
- `binwalk` — analyse / extraction de firmware

## Wireshark sans sudo

Sur l'ISO AIMS OS, `dumpcap` est déjà configuré setuid root
(`wireshark-common/install-setuid=true` via preseed). Le service
first-boot ajoute votre compte au groupe `wireshark` au premier
démarrage.

Sur un install apt standalone, debconf vous demande à `apt install
wireshark` si vous voulez le setuid. Répondez "oui", puis :

```bash
sudo usermod -aG wireshark $USER
newgrp wireshark
# ou logout/login
```

## Cours couverts

- Auditing Computer Forensics and Investigation
- Computer Network
- Computer Security 1: Network Security
- Computer Security: Case studies from industries
- Ethical Hacking
- Mathematical Model for Network Security
- Post Quantum Cryptography
- Quantum Mechanics and Computing (libs partielles, Qiskit on-demand)

Voir la [cartographie complète](/courses/mapping/) pour le détail.
