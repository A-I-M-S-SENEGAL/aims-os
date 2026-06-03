# live-build chroot hooks

Each file matching `*.hook.chroot` runs once inside the live-build chroot
during the `lb build` stage. Order is alphabetical, hence the leading
numeric prefix.

## Disabled hooks (`*.hook.chroot.disabled`)

live-build only matches `*.hook.chroot`. Appending `.disabled` keeps the
script around for reference and future reuse, but skips it for the
slim v2.1 build path.

Currently disabled for the v2.1 slim ISO:

| File | What it did in v2.0 | Where it goes in v2.1 |
|------|----------------------|-----------------------|
| `0095-nodesource.hook.chroot.disabled`  | Added NodeSource APT repo + installed Node 22 LTS         | Moved to `aims-os-desktop-dev` (apt install at wizard time). The NodeSource repo setup will move to `aims-os-core`'s postinst so the repo is always available. |
| `0096-vscodium.hook.chroot.disabled`    | Added Paulcarroty's APT repo + installed VSCodium         | Wizard install — script lives at `/usr/share/aims-os/install/vscodium.sh` (TBD step 4) |
| `0097-cursor.hook.chroot.disabled`      | Downloaded the Cursor `.deb` from cursor.com              | Wizard install — script at `/usr/share/aims-os/install/cursor.sh` (TBD step 4) |
| `0098-dbeaver.hook.chroot.disabled`     | Installed DBeaver CE from upstream APT repo               | Wizard install — script at `/usr/share/aims-os/install/dbeaver.sh` (TBD step 4) |
| `0099-rust-runtimes.hook.chroot.disabled` | Installed Bun + Deno + uv from upstream binary releases | Wizard install — script at `/usr/share/aims-os/install/runtimes.sh` (TBD step 4) |
| `0103-rstudio.hook.chroot.disabled`     | Downloaded RStudio Desktop `.deb` from Posit              | Wizard install — script at `/usr/share/aims-os/install/rstudio.sh` (TBD step 4) |

These tools represent about 4-5 GB of the v2.0 ISO. Pulling them out
of the chroot is the biggest single contributor to the v2.1 slim
target. Students who want them get them via the first-boot wizard
(coming in step 4 of the v2.1 plan) or by running the install script
themselves later.

## Re-enabling

```
git mv 0095-nodesource.hook.chroot.disabled 0095-nodesource.hook.chroot
```

…and the hook is back on the next build.
