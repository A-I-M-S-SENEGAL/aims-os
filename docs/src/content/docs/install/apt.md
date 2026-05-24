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

| Filière | Commande |
|---|---|
| Regular (Sciences Mathématiques) | `sudo apt install aims-os-math` |
| Coop Big Data | `sudo apt install aims-os-bigdata` |
| Coop Computer Security | `sudo apt install aims-os-security` |
| Bureau GNOME | `sudo apt install aims-os-desktop` |
| Baseline système | `sudo apt install aims-os-core` |
| Tout (équivalent ISO) | `sudo apt install aims-os-{core,desktop,math,bigdata,security}` |

Les paquets `aims-os-bigdata` et `aims-os-security` dépendent de
`aims-os-math`, donc en installer un tire automatiquement la base
SciPy / R / LaTeX / Jupyter.

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
