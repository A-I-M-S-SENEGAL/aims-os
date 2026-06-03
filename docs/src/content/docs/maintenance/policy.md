---
title: Politique de maintenance
description: Comment AIMS OS suit Debian, le rythme de releases par cycle académique, et le support à long terme.
---

AIMS OS est une distribution dérivée de **Debian stable**, alignée sur
le calendrier académique d'AIMS Sénégal. Cette page documente le
rythme des releases, l'architecture des paquets, la durée de support,
et comment recevoir les mises à jour.

## Architecture des paquets — trois couches

À partir de v2.1, les métapaquets sont organisés en trois couches
empilées. Cette structure existe pour permettre une distribution
multi-centre sans dupliquer le tronc technique.

```
┌─ Universal subjects (technique générique)
│  aims-os-core / -desktop / -math / -bigdata / -security…
│
├─ Centre profiles (1 par centre AIMS)
│  aims-os-centre-senegal      ← bookmarks Mbour, wallpapers, WiFi
│  aims-os-centre-southafrica  ← futur, par AIMS SA
│
└─ Centre × subject × year (curriculum)
   aims-os-centre-senegal-bigdata-2026   ← PDFs cours, datasets, syllabus
   aims-os-centre-senegal-security-2026
   aims-os-centre-southafrica-bigdata-2026
```

### Universal subjects

Outils techniques génériques, utiles à n'importe quel centre AIMS qui
enseigne la matière. Pas de référence au pays, au campus, à un
syllabus.

Update : lié à la sortie de Debian stable (~2 ans). Les libs Python /
R / outils CLI ne changent pas au gré des cycles AIMS.

Exemples : `aims-os-bigdata` (Spark, Dask, OpenCV, Cartopy,
postgresql-client) ; `aims-os-security` (nmap, wireshark, hashcat).

### Centre profiles

Identité visuelle, intranet, configuration locale d'un centre AIMS
donné. Stable dans le temps : les bookmarks de l'intranet AIMS Mbour
ne changent pas chaque année.

Update : lié au campus (~rare). Quand AIMS Mbour change de plateforme
mail, on bump `aims-os-centre-senegal`.

Contenu attendu :

- Bookmarks Firefox pointant sur l'intranet, la library, le mail, les
  plateformes de cours du campus
- Wallpapers du campus (photos locales)
- Profil WiFi NetworkManager
- PPDs des imprimantes du campus
- Logo et autres assets de marque

### Centre × subject × year (curriculum)

Contenu pédagogique spécifique à un centre, une matière et une promo.
PDFs des cours, datasets utilisés, syllabus, exercices, examens passés.

Update : **annuel**. Chaque rentrée, nouvelle promo = nouveau paquet.
Les étudiants de l'ancienne promo gardent leur paquet, ils ne sont
pas affectés.

Convention de nommage :
`aims-os-centre-<pays>-<domaine>-<année-rentrée>`

Exemples :
- `aims-os-centre-senegal-bigdata-2026` (promo Big Data Mbour 2026-2027)
- `aims-os-centre-senegal-security-2026`
- `aims-os-centre-southafrica-bigdata-2026`

### Comment ça s'installe en pratique

Un étudiant Mbour 2026-2027 en Coop Big Data installe en une commande :

```bash
sudo apt install aims-os-centre-senegal-bigdata-2026
```

Ce paquet a comme `Depends` :

```
Depends: aims-os-bigdata,           ← outillage technique
         aims-os-centre-senegal,    ← identité campus
         aims-os-math               ← tronc commun
```

→ Apt résout en cascade, l'étudiant obtient tout d'un coup : Spark +
bookmarks AIMS-Mbour + PDFs des cours 2026.

### État actuel des couches

| Couche | Implémentée v2.1 | Statut |
|---|---|---|
| Universal subjects | ✅ | 11 métapaquets publiés |
| Centre profile Sénégal | ⚠️ stub vide | Architecture posée, contenu à ajouter (bookmarks, wallpapers, etc.) |
| Centre profiles autres | ❌ | À créer par chaque centre |
| Centre × subject × year | ❌ | À créer quand le contenu pédagogique d'une promo est prêt |

## Base : Debian stable

Chaque version majeure d'AIMS OS suit une release Debian stable :

| AIMS OS | Base Debian | Statut |
|---------|-------------|--------|
| **v2.x** | Debian 13 (Trixie) | actuelle |
| **v3.x** | Debian 14 (Forky)  | quand Forky sort (~été 2027) |

Le passage à un nouveau major se fait dans les **6 mois** après la
sortie d'une nouvelle Debian stable, le temps que les outils tiers
embarqués (Cursor, RStudio, DBeaver, Bun, Deno…) suivent la nouvelle
base.

## 4 releases par cycle académique

Le cycle AIMS court de septembre à août. AIMS OS publie quatre
releases par cycle, calées sur les jalons pédagogiques.

| Release | Période | Contenu |
|---------|---------|---------|
| **vX.Y.0** | Septembre | Cycle start. Stack figée pour les cours, ISO distribué aux nouveaux étudiants |
| **vX.Y.1** | Décembre | Mid-term. Sécurité + corrections après le premier retour terrain |
| **vX.Y.2** | Mars     | Post-vacances. Outils du 2ᵉ semestre si nouveaux cours |
| **vX.Y.3** | Juillet  | Cleanup, prep cycle suivant |

Entre deux releases, les **patchs sécurité sont continus** via le
[repo APT](/install/apt/) — pas besoin de reflasher.

## Hotfix d'urgence

Hors calendrier : une release `vX.Y.Z+1` est publiée immédiatement
si une CVE critique touche un composant central (kernel, glibc,
OpenSSL, GNOME). Pas d'attente du prochain milestone.

Critères d'urgence :
- CVE notée ≥ 8.0 sur CVSS v3
- Exploitation publique connue
- Composant exposé par défaut sur AIMS OS

## Support

Chaque major reçoit deux niveaux de support :

- **Support complet** : pendant tout le cycle de vie du major. Mises
  à jour fonctionnelles, sécurité, corrections de bugs.
- **Sécurité seule** : 6 mois après la sortie du major suivant. Seules
  les CVE sont rétro-portées.

En pratique, un major AIMS OS reste utilisable et patché pendant
environ **3 ans** — la durée de support de la Debian stable
sous-jacente.

| Major | Support complet | Sécurité seule | EOL |
|-------|-----------------|----------------|-----|
| v2.x  | jusqu'à la sortie de v3.0 | 6 mois après v3.0 | ~T1 2028 |
| v3.x  | jusqu'à la sortie de v4.0 | 6 mois après v4.0 | TBD |

## Recevoir les mises à jour

### Système installé

Le repo APT d'AIMS OS est ajouté automatiquement à l'install. Pour
récupérer les patchs entre deux releases :

```bash
sudo apt update
sudo apt upgrade
```

À programmer en tâche cron ou laisser `unattended-upgrades` faire le
travail (configuré pour les correctifs sécurité par défaut).

### ISO live (clé USB)

L'ISO `latest/` sur [notre miroir R2](/install/iso/) est ré-écrasé à
chaque release. Re-télécharger l'ISO suffit pour avoir la version la
plus récente. Pour pinner une version précise, utiliser l'URL avec
le tag (ex. `v2.0.0-rc1/`).

## Vérifier sa version

```bash
cat /etc/aims-os-release
```

Affiche la version installée, la base Debian, et la date du build.

## Annonces

Chaque release est annoncée :
- Sur la page [Releases GitHub](https://github.com/A-I-M-S-SENEGAL/aims-os/releases)
- Par mail sur la liste interne AIMS (étudiants + staff)
- Avec un changelog complet dans le commit message du tag
