---
title: Premier démarrage
description: Ce qui se passe au premier login dans AIMS OS, et comment configurer rapidement.
---

Au premier login dans GNOME, AIMS OS fait trois choses automatiquement :

1. Le service systemd `aims-firstboot.service` ajoute votre compte aux
   groupes `docker` et `wireshark`. Cela débloque `docker run` sans
   sudo et `wireshark` sans capture-as-root pour le cours Ethical
   Hacking.
2. La page de bienvenue HTML s'ouvre dans Firefox, brandée AIMS,
   bilingue FR/EN.
3. Plymouth + GDM ont déjà appliqué le thème terracotta au boot.

## Vérifier la version

Ouvrir un terminal et taper :

```bash
aims-version
```

Affiche le nom du système, la version Debian de base, le kernel et
l'environnement de bureau. Variantes :

- `aims-version --json` — sortie machine-readable
- `aims-version --verbose` — ajoute python3 / R / node / docker / Cursor / RStudio
- `aims-version --plain` — sans couleur ANSI

## Re-afficher la page de bienvenue

```bash
aims-welcome          # ouvre la GUI si jamais affichée
aims-welcome --force  # force-open dans le navigateur
aims-welcome --text   # version texte dans le terminal
```

## Activer le groupe docker pour la session courante

Les changements de groupe (`docker`, `wireshark`) ne prennent effet
qu'à la prochaine session. Pour les utiliser tout de suite :

```bash
newgrp docker
docker run hello-world  # devrait marcher sans sudo
```

Ou simplement logout / login.

## Locale et clavier

Le système est en `fr_FR.UTF-8` par défaut, fuseau Africa/Dakar. Le
clavier est `fr` (France). Pour changer :

- Clavier : **Paramètres → Clavier → Sources de saisie**
- Locale système : `sudo dpkg-reconfigure locales`

## Réseau

Si vous êtes sur Wi-Fi, la connexion se gère depuis GNOME Settings →
Wi-Fi. NetworkManager OpenVPN est pré-installé pour les VPN AIMS.

Sur les Mac M-series sous UTM, le ping ICMP est bloqué par le NAT
d'UTM. Utiliser `curl https://google.com` ou Firefox pour tester. La
connectivité TCP fonctionne normalement.

## Mettre à jour le système

```bash
sudo apt update && sudo apt upgrade
```

Tire les correctifs Debian Security et les nouvelles versions de la
stack AIMS OS si vous avez ajouté le [repo apt](/install/apt/).

## Installer les outils tiers (Cursor, RStudio, etc.)

À partir d'AIMS OS v2.1, l'ISO ne contient plus par défaut Cursor,
RStudio, DBeaver, VSCodium, Node 22, Bun, Deno ni uv — on a sorti
ces ~1,5 GB pour alléger le téléchargement. Le métapaquet
`aims-os-welcome` (déjà installé) fournit les scripts d'install :

```bash
ls /usr/share/aims-os/install/
# cursor.sh  dbeaver.sh  nodejs.sh  rstudio.sh  runtimes.sh  vscodium.sh

# Installer à la carte (sudo demandé)
sudo /usr/share/aims-os/install/cursor.sh
sudo /usr/share/aims-os/install/rstudio.sh
sudo /usr/share/aims-os/install/nodejs.sh
# etc.

# Ou tout d'un coup
for s in /usr/share/aims-os/install/*.sh; do
    sudo "$s" || echo "FAILED: $s"
done
```

Chaque script télécharge l'outil depuis sa source officielle (cursor.com,
posit.co, dbeaver.io, NodeSource, GitHub releases). Comptez ~30-45 min
selon votre connexion pour tout installer.

Pour les filières complètes :

```bash
sudo apt install aims-os-bigdata          # Coop Big Data
sudo apt install aims-os-security         # Coop Computer Security
sudo apt install aims-os-math-extras      # Maths complet (Maxima, full Octave, R tidyverse, LaTeX multilingue, GeoGebra)
sudo apt install aims-os-desktop-extras   # Chromium, GIMP, Inkscape, codecs non-free
sudo apt install aims-os-desktop-dev      # Java, Docker, Rust
```

Une future version d'AIMS OS proposera un **wizard premier-boot**
qui vous demande votre filière et vos outils, puis lance ces
commandes automatiquement. En attendant, c'est manuel.

## Et après

- [Vérifier votre filière](/filieres/regular/)
- [Mapper vos cours sur les outils](/courses/mapping/)
