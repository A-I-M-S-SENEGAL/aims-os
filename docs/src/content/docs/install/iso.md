---
title: Installer depuis l'ISO
description: Boot the AIMS OS ISO in UTM, QEMU, VirtualBox or VMware, then run the Calamares installer.
---

L'image ISO d'AIMS OS contient un système live amorçable et le
programme d'installation Calamares. Vous pouvez la flasher sur une
clé USB pour une vraie machine, ou la booter dans une VM (UTM sur Mac
M-series, QEMU/KVM sur Linux, VirtualBox, VMware).

## Télécharger

Les ISO sont publiées en tant qu'artefacts GitHub Actions sur le
projet upstream :

[Liste des builds AIMS OS sur GitHub](https://github.com/A-I-M-S-SENEGAL/aims-os/actions/workflows/build-iso.yml?query=is%3Asuccess+branch%3Amain)

Choisissez le dernier build réussi sur `main` et téléchargez :

- `aims-os-1.0-arm64.iso` pour les Mac M-series (UTM, Asahi Linux) et
  les serveurs ARM
- `aims-os-1.0-amd64.iso` pour les PC portables x86_64

Vérifiez la somme SHA-256 livrée à côté avant de booter :

```bash
shasum -a 256 -c aims-os-1.0-arm64.iso.sha256
```

## Booter dans UTM (Mac M-series)

1. Ouvrir UTM, créer une nouvelle machine virtuelle, **Virtualiser**
   (pas Émuler), choisir **Linux**.
2. Pointer le champ **Boot ISO Image** vers le fichier
   `aims-os-1.0-arm64.iso`.
3. Mémoire : 4 GiB minimum, 8 GiB recommandé pour GNOME + LibreOffice.
4. Stockage : 50 GiB minimum (la stack scientifique + LaTeX + Cursor
   prennent ~12 GiB après install).
5. Réseau : Shared par défaut. Ping ICMP est bloqué par UTM même
   firewall désactivé : utilisez `curl https://google.com` ou Firefox
   pour tester la connectivité.

## Booter dans QEMU/KVM (Linux host)

```bash
qemu-system-x86_64 \
  -enable-kvm \
  -m 4G -smp 4 \
  -drive file=aims-os-disk.qcow2,format=qcow2,if=virtio \
  -cdrom aims-os-1.0-amd64.iso \
  -boot d \
  -vga virtio -display gtk
```

(Pour arm64, remplacer par `qemu-system-aarch64 -M virt -cpu host
-bios /usr/share/AAVMF/AAVMF_CODE.fd ...`)

## Le menu GRUB

Au démarrage, GRUB affiche le menu AIMS OS avec quatre entrées en
français :

- **Démarrer en mode Live** : système live, pas d'installation
- **Installer AIMS OS** : lance Calamares dans une session live
- **Options d'installation avancées** : kernel parameters custom
- **Utilitaires** : memtest, firmware tools

Sélectionner **Démarrer en mode Live**.

## Lancer Calamares

Une fois sur le bureau live, l'icône **Installer AIMS OS** est sur le
bureau et dans la grille d'applications. Double-cliquer pour démarrer.

Le déroulé suit le pattern Calamares standard :

1. **Bienvenue** — vérifie la connexion réseau et l'espace disque
2. **Emplacement** — Afrique / Dakar par défaut
3. **Clavier** — fr (France) par défaut, fr (Sénégal) ou us disponibles
4. **Partitions** — Effacer le disque (la VM est dédiée) ou partitionnement
   manuel
5. **Utilisateurs** — votre nom, username, mot de passe
6. **Résumé** — récapitulatif avant install
7. **Installer** — boucle ~20-30 minutes sur une VM moderne
8. **Terminer** — redémarrer dans le système installé

Si l'installation se bloque sur l'étape Terminer avec une erreur
"gestionnaire de paquets" — c'est un bug connu corrigé dans la v9.1
et au-delà. Le système est en réalité installé, vous pouvez redémarrer
manuellement.

## Premier démarrage

Au reboot, GDM affiche l'écran de connexion brandé AIMS OS. Connectez-vous
avec l'utilisateur créé. La page de bienvenue HTML s'ouvre automatiquement
dans Firefox au premier login pour vous orienter.

Voir [Premier démarrage](/install/first-boot/) pour la suite.
