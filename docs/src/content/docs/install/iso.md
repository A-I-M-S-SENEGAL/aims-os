---
title: Installer depuis l'ISO
description: Boot the AIMS OS ISO in UTM, QEMU, VirtualBox or VMware, then run the Calamares installer.
---

L'image ISO d'AIMS OS contient un système live amorçable et le
programme d'installation Calamares. Vous pouvez la flasher sur une
clé USB pour une vraie machine, ou la booter dans une VM (UTM sur Mac
M-series, QEMU/KVM sur Linux, VirtualBox, VMware).

## Télécharger

Les ISO vivent sur Cloudflare R2 (GitHub Releases cape les assets à
2 GiB et nos images font ~8,5 GB). Liens stables, mis à jour à chaque
release :

- **arm64** (Mac M-series sous UTM, serveurs ARM) :
  [aims-os-1.0-arm64.iso](https://pub-5d3e0470a4ad4b4484092f7263fc8e17.r2.dev/latest/aims-os-1.0-arm64.iso)
  · [SHA-256](https://pub-5d3e0470a4ad4b4484092f7263fc8e17.r2.dev/latest/aims-os-1.0-arm64.iso.sha256)
- **amd64** (PC portables x86_64) :
  [aims-os-1.0-amd64.iso](https://pub-5d3e0470a4ad4b4484092f7263fc8e17.r2.dev/latest/aims-os-1.0-amd64.iso)
  · [SHA-256](https://pub-5d3e0470a4ad4b4484092f7263fc8e17.r2.dev/latest/aims-os-1.0-amd64.iso.sha256)

Vérifiez la somme avant de booter (le `.sha256` est aussi attaché à
la [release GitHub correspondante](https://github.com/A-I-M-S-SENEGAL/aims-os/releases),
ça permet de pinner la version) :

```bash
shasum -a 256 -c aims-os-1.0-arm64.iso.sha256
```

Pour une version précise au lieu de "latest", remplacez `latest` par
le tag dans l'URL — par exemple
`.r2.dev/v2.0.0-rc1/aims-os-1.0-arm64.iso`. Les versions taggées
sont immuables, idéales pour les déploiements de laboratoire qui
veulent figer une image.

Toutes les releases :
[github.com/A-I-M-S-SENEGAL/aims-os/releases](https://github.com/A-I-M-S-SENEGAL/aims-os/releases)

## Flasher sur une clé USB (PC portable, machine physique)

Le cas le plus courant pour les étudiants AIMS. Il faut une clé USB
de **16 Go minimum** (l'ISO fait ~8,5 Go, l'install Calamares en
réclame plus pendant le déroulement).

:::caution
Le flash **efface tout** ce qui se trouve sur la clé. Sauvegardez
avant.
:::

### Option recommandée : balenaEtcher (multi-OS, GUI)

Marche pareil sur macOS, Windows et Linux. Vérifie le checksum
automatiquement.

1. Télécharger [balenaEtcher](https://etcher.balena.io/) → installer.
2. Lancer Etcher → **Flash from file** → choisir l'ISO AIMS OS.
3. **Select target** → choisir la clé USB (vérifier deux fois la
   lettre/numéro de disque).
4. **Flash!** → patienter 5-15 min selon la vitesse de la clé.
5. Une fois "Flash Complete", débrancher.

### macOS — ligne de commande (`dd`)

```bash
# Identifier le device de la clé (ex: /dev/disk4). Branchez la clé
# PUIS lancez la commande pour voir ce qui apparaît.
diskutil list

# Démonter (sans éjecter)
diskutil unmountDisk /dev/disk4

# Flash. ATTENTION au numéro de disque — un mauvais choix ÉCRASE
# votre disque système. /dev/rdiskN (avec 'r' devant) est ~5x plus
# rapide que /dev/diskN.
sudo dd if=~/Downloads/aims-os-1.0-amd64.iso of=/dev/rdisk4 bs=4m status=progress
sudo sync

# Éjecter proprement
diskutil eject /dev/disk4
```

### Linux — `dd` ou GNOME Disks

CLI :
```bash
lsblk                                  # repère ta clé (ex: /dev/sdc)
sudo umount /dev/sdc?                  # démonte toutes les partitions
sudo dd if=aims-os-1.0-amd64.iso of=/dev/sdc bs=4M status=progress oflag=sync
```

Ou GUI : ouvrir **GNOME Disks** (Disques) → sélectionner la clé →
menu (⋮) → **Restore Disk Image** → choisir l'ISO.

### Windows — Rufus ou balenaEtcher

[Rufus](https://rufus.ie/) est le standard Windows :
1. Lancer Rufus → **Device** = clé USB.
2. **Boot selection** → SELECT → choisir l'ISO.
3. **Partition scheme** : GPT (UEFI moderne). **Target system** : UEFI.
4. **START** → si Rufus demande "DD Image" vs "ISO Image", choisir
   **DD Image** (l'ISO AIMS est isohybrid).

### Booter sur la clé

1. Brancher la clé USB sur la machine cible **éteinte**.
2. Allumer en tenant la touche du **boot menu** :
   - HP / Dell / Lenovo ThinkPad : **F12**
   - Acer : **F12** ou **Esc**
   - ASUS : **F8** ou **Esc**
   - MSI : **F11**
   - Mac Intel : **Option/⌥** (puis choisir EFI Boot)
   - Mac M-series (Asahi) : voir doc Asahi Linux, plus complexe
3. Sélectionner la clé USB dans le menu de boot.
4. Le menu GRUB AIMS OS s'affiche → **Démarrer en mode Live**.

Sur les laptops récents avec **Secure Boot** activé : AIMS OS embarque
le shim signé Debian, ça boote sans toucher au BIOS. Si ça refuse,
désactiver Secure Boot dans le firmware UEFI (touche **F2**, **F10**
ou **Suppr** au démarrage).

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
"gestionnaire de paquets". C’est un bug connu corrigé dans la v9.1
et au-delà. Le système est en réalité installé, vous pouvez redémarrer
manuellement.

## Premier démarrage

Au reboot, GDM affiche l'écran de connexion brandé AIMS OS. Connectez-vous
avec l'utilisateur créé. La page de bienvenue HTML s'ouvre automatiquement
dans Firefox au premier login pour vous orienter.

Voir [Premier démarrage](/install/first-boot/) pour la suite.
