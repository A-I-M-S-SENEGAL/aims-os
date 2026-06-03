---
title: Maintenance policy
description: How AIMS OS tracks Debian, the release cadence per academic cycle, and long-term support.
---

AIMS OS is a Debian-stable-based distribution aligned with the AIMS
Senegal academic calendar. This page documents the release cadence,
package architecture, support duration, and how to receive updates.

## Package architecture — three layers

Starting with v2.1, the metapackages are organised in three stacked
layers. This structure exists to allow multi-centre distribution
without duplicating the technical baseline.

```
┌─ Universal subjects (generic tech stack)
│  aims-os-core / -desktop / -math / -bigdata / -security…
│
├─ Centre profiles (one per AIMS centre)
│  aims-os-centre-senegal      ← Mbour bookmarks, wallpapers, Wi-Fi
│  aims-os-centre-southafrica  ← future, by AIMS SA
│
└─ Centre × subject × year (curriculum)
   aims-os-centre-senegal-bigdata-2026   ← course PDFs, datasets, syllabus
   aims-os-centre-senegal-security-2026
   aims-os-centre-southafrica-bigdata-2026
```

### Universal subjects

Generic technical tooling useful to any AIMS centre teaching the
subject. No country, campus or syllabus references.

Update cadence: tied to the Debian stable release (~2 years). The
Python / R / CLI tooling does not move at AIMS cycle pace.

Examples: `aims-os-bigdata` (Spark, Dask, OpenCV, Cartopy,
postgresql-client); `aims-os-security` (nmap, wireshark, hashcat).

### Centre profiles

Visual identity, intranet wiring and local config of a given AIMS
centre. Stable over time: the AIMS Mbour intranet bookmarks do not
change every year.

Update cadence: tied to the campus (~rare). When AIMS Mbour switches
mail platforms, we bump `aims-os-centre-senegal`.

Expected contents:

- Firefox bookmarks pointing at the campus intranet, library, mail,
  learning platforms
- Campus wallpapers (local photos)
- NetworkManager Wi-Fi profile
- CUPS PPDs for campus printers
- Logo and other brand assets

### Centre × subject × year (curriculum)

Pedagogical content specific to one centre, one subject, one cohort.
Course PDFs, datasets used in class, syllabus, exercises, past exams.

Update cadence: **yearly**. Each academic-year start ships a new
package. Students on the previous cohort keep their package; they are
not affected.

Naming convention:
`aims-os-centre-<country>-<subject>-<intake-year>`

Examples:
- `aims-os-centre-senegal-bigdata-2026` (Mbour 2026-2027 Big Data cohort)
- `aims-os-centre-senegal-security-2026`
- `aims-os-centre-southafrica-bigdata-2026`

### Installing in practice

A Mbour 2026-2027 Coop Big Data student installs everything in one
command:

```bash
sudo apt install aims-os-centre-senegal-bigdata-2026
```

This package depends on:

```
Depends: aims-os-bigdata,           ← technical stack
         aims-os-centre-senegal,    ← campus identity
         aims-os-math               ← shared baseline
```

→ Apt resolves the cascade, the student gets it all in one go: Spark
+ AIMS-Mbour bookmarks + 2026 course PDFs.

### Current state of the layers

| Layer | Implemented in v2.1 | Status |
|---|---|---|
| Universal subjects | ✅ | 11 metapackages published |
| Senegal centre profile | ⚠️ empty stub | Architecture in place, content to add (bookmarks, wallpapers, etc.) |
| Other centre profiles | ❌ | To be created by each centre |
| Centre × subject × year | ❌ | To create when a cohort's pedagogical content is ready |

## Base: Debian stable

Each AIMS OS major version tracks one Debian stable release:

| AIMS OS | Debian base | Status |
|---------|-------------|--------|
| **v2.x** | Debian 13 (Trixie) | current |
| **v3.x** | Debian 14 (Forky)  | once Forky ships (~summer 2027) |

We jump to a new major within **6 months** after a new Debian stable
ships, giving the bundled third-party tools (Cursor, RStudio,
DBeaver, Bun, Deno…) time to support the new base.

## 4 releases per academic cycle

The AIMS academic cycle runs September → August. AIMS OS ships four
releases per cycle, anchored to the teaching milestones.

| Release | Window | Contents |
|---------|--------|----------|
| **vX.Y.0** | September | Cycle start. Stack frozen for the new courses, ISO handed to incoming students |
| **vX.Y.1** | December  | Mid-term. Security + fixes after the first round of field feedback |
| **vX.Y.2** | March     | Post-break. Second-semester tools if new courses need them |
| **vX.Y.3** | July      | Cleanup, prep for the next cycle |

Between releases, **security patches flow continuously** via the
[APT repo](/en/install/apt/) — no reflash needed.

## Emergency hotfixes

Off-schedule: a `vX.Y.Z+1` release ships immediately when a critical
CVE lands on a core component (kernel, glibc, OpenSSL, GNOME). We do
not wait for the next milestone.

Urgency criteria:
- CVSS v3 score ≥ 8.0
- Known public exploitation
- Component exposed by default on AIMS OS

## Support

Each major gets two support tiers:

- **Full support**: the entire lifetime of the major. Functional
  updates, security, bug fixes.
- **Security-only**: 6 months after the next major ships. Only CVE
  backports.

In practice, an AIMS OS major stays usable and patched for roughly
**3 years** — matching Debian stable's support window for the
underlying base.

| Major | Full support | Security-only | EOL |
|-------|--------------|---------------|-----|
| v2.x  | until v3.0 ships | 6 months after v3.0 | ~Q1 2028 |
| v3.x  | until v4.0 ships | 6 months after v4.0 | TBD |

## Receiving updates

### Installed system

The AIMS OS APT repo is added automatically during install. To pull
patches between releases:

```bash
sudo apt update
sudo apt upgrade
```

Schedule via cron, or let `unattended-upgrades` handle it (configured
for security fixes by default).

### Live ISO (USB stick)

The `latest/` ISO on [our R2 mirror](/en/install/iso/) is overwritten
on every release. Re-download to get the most recent version. To pin
a specific version, use the tag-prefixed URL (e.g. `v2.0.0-rc1/`).

## Check your version

```bash
cat /etc/aims-os-release
```

Prints the installed version, Debian base, and build date.

## Announcements

Each release is announced:
- On the [GitHub Releases page](https://github.com/A-I-M-S-SENEGAL/aims-os/releases)
- By email on the internal AIMS list (students + staff)
- With a full changelog in the tag's commit message
