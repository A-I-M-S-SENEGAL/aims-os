---
title: Sur un Debian existant (apt)
description: Ajouter la stack AIMS OS à un Debian 13 Trixie déjà installé via le repo apt officiel.
---

Si vous avez déjà un Debian 13 Trixie en place (laptop, serveur, VM,
cluster head), vous pouvez ajouter la couche AIMS OS sans réinstaller
le système. Le repo apt officiel est hébergé sur GitHub Pages et signé
GPG.

## Ajouter le repo

```bash
# 1. Récupérer la clé publique AIMS OS
sudo curl -fsSL https://a-i-m-s-senegal.github.io/aims-os/aims-os-archive-keyring.gpg \
    -o /usr/share/keyrings/aims-os-archive-keyring.gpg

# 2. Déclarer le repo (format deb822, utilisé par Trixie)
sudo tee /etc/apt/sources.list.d/aims-os.sources >/dev/null <<'EOF'
Types: deb
URIs: https://a-i-m-s-senegal.github.io/aims-os
Suites: trixie
Components: main
Architectures: amd64 arm64
Signed-By: /usr/share/keyrings/aims-os-archive-keyring.gpg
EOF

sudo apt update
```

## Vérifier la signature

L'empreinte attendue de la clé :

```
7775 7473 70C3 E86F A12D  06D7 CEAB 168E 6D2E 30FF
```

```bash
gpg --show-keys /usr/share/keyrings/aims-os-archive-keyring.gpg
```

## Choisir et installer

À partir de v2.1, les anciens métapaquets monolithiques ont été
découpés en variantes **slim** (ce qui sert à tout le monde) et
**extras** (le reste, à installer si besoin). La version v2.0
restait monolithique.

### Cas simple, vous voulez tout

```bash
sudo apt install aims-os-everything
```

Reproduit le contenu complet de l'ISO v2.0 (~9 GB après install).
Tire les 11 métapaquets en cascade.

### Stack par sujet

Les noms ci-dessous sont **génériques** ; chaque centre AIMS y rattache
sa propre nomenclature de filière (AIMS Sénégal parle de "Regular" et
"Coop", AIMS South Africa a sa propre structure, etc.).

| Domaine | Commande |
|---|---|
| Sciences Mathématiques (tronc commun) | `sudo apt install aims-os-math` |
| Big Data, NLP, Computer Vision, Climat, DB | `sudo apt install aims-os-bigdata` |
| Computer Security, cryptographie, forensique | `sudo apt install aims-os-security` |

`aims-os-bigdata` et `aims-os-security` dépendent de `aims-os-math`,
donc en installer un tire automatiquement la base SciPy / R / LaTeX
slim / Jupyter.

Pour la correspondance avec les filières AIMS Sénégal (Regular,
Coop Big Data, Coop Computer Security), voir
[Démarrer → Filières](/filieres/regular/).

### Couches optionnelles (v2.1)

| Couche | Commande | Contenu |
|---|---|---|
| Bureau slim | `sudo apt install aims-os-desktop` | GNOME + Firefox + LibreOffice fr + codecs libres + utilitaires |
| Bureau extras | `sudo apt install aims-os-desktop-extras` | Chromium + GIMP + Inkscape + Evolution + codecs non-free + dictionnaire EN |
| Stack dev complète | `sudo apt install aims-os-desktop-dev` | OpenJDK 21 + Gradle + Kotlin + PHP + Docker + Podman + kubectl + rustup |
| Stack maths extras | `sudo apt install aims-os-math-extras` | Maxima + Octave complet + R tidyverse + LaTeX multilingue + GeoGebra |
| Centre Sénégal | `sudo apt install aims-os-centre-senegal` | Locale fr_FR + Africa/Dakar + bookmarks AIMS-Mbour |
| Labo Mbour (postes fixes) | `sudo apt install aims-os-centre-senegal-labo` | SSH clé seule pour l'équipe IT, compte `aimsit` ; hors ISO, poste modèle uniquement |
| Wizard + scripts | `sudo apt install aims-os-welcome` | Scripts d'install `/usr/share/aims-os/install/*.sh` |
| Baseline système | `sudo apt install aims-os-core` | Sécurité + firmware + locales + CLI + Miniforge |

### Outils tiers (Cursor, RStudio, Node 22, Bun, Deno, uv, DBeaver, VSCodium)

Pas dans Debian, fournis comme **scripts d'install** par
`aims-os-welcome` :

```bash
sudo apt install aims-os-welcome

# Puis, à la carte :
sudo /usr/share/aims-os/install/cursor.sh       # IDE IA proprio
sudo /usr/share/aims-os/install/rstudio.sh      # RStudio Desktop
sudo /usr/share/aims-os/install/dbeaver.sh      # SQL GUI universel
sudo /usr/share/aims-os/install/vscodium.sh     # VS Code libre
sudo /usr/share/aims-os/install/nodejs.sh       # Node 22 LTS (NodeSource)
sudo /usr/share/aims-os/install/runtimes.sh     # Bun + Deno + uv
```

Chaque script télécharge l'outil depuis sa source officielle (cursor.com,
posit.co, dbeaver.io, NodeSource, GitHub releases) et l'installe.
Idempotent : relancer met à jour.

## À propos des composants non-free

Les blobs firmware Wi-Fi/GPU (`firmware-iwlwifi`, `firmware-realtek`,
...) sont dans `non-free-firmware` ; le codec RAR (`p7zip-rar`) est
dans `non-free`. AIMS OS les liste en `Recommends` pour ne pas casser
l'install sur un Debian qui n'a que `main`.

Si vous voulez le hardware support complet, activez les deux
composants dans votre `/etc/apt/sources.list` avant `apt install`.

## aims-os-branding

Le paquet `aims-os-branding` (wallpapers, thème GRUB, splash Plymouth,
branding Calamares) n'est volontairement **pas** publié sur le repo apt.
Il livre les assets uniquement avec l'ISO. Réécrire les wallpapers
d'un Debian existant sans demander serait impoli.
