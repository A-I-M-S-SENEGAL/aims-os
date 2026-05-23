# apt-repo/

Tooling for the AIMS OS apt repository served at
https://a-i-m-s-senegal.github.io/aims-os/.

## Files

| File | Role |
|---|---|
| `build-debs.sh` | Runs `dpkg-buildpackage` on every `metapackages/aims-os-*/`. Outputs `.deb` files to `apt-repo/out/`. |
| `publish.sh` | Reads `.deb` files from `apt-repo/out/`, builds a signed apt repo tree under `apt-repo/site/`. Needs the AIMS OS private key already in the local gpg. |
| `aims-os-pubkey.gpg` | Public key, committed. Gets bundled into the published repo so users can fetch + verify it. |
| `site-README.md` | Landing page shown at the bare repo URL. |
| `out/` | `.deb` build output. Gitignored. |
| `site/` | Repo tree ready for Pages upload. Gitignored. |

## Run the publish flow locally

```bash
# 1. Build the .debs (debhelper + dpkg-dev required)
./apt-repo/build-debs.sh

# 2. Build and sign the repo tree (private key must be imported into gpg)
GPG_KEY_ID=CEAB168E6D2E30FF ./apt-repo/publish.sh

# 3. Look at what's there
find apt-repo/site -maxdepth 4 -type f
```

## CI

`.github/workflows/publish-apt-repo.yml` runs the same two scripts on a
GitHub Actions runner and deploys the result via the official
`actions/deploy-pages` flow.

Fires on:
- Manual: `gh workflow run publish-apt-repo.yml`
- Tag push: `git push origin v2.0.x` (publishes alongside the matching ISO release).

Repo settings you need:
- Secret `AIMS_GPG_PRIVATE_KEY` holding the armored private key (no
  passphrase). Set with `gh secret set AIMS_GPG_PRIVATE_KEY < key.asc`.
- Settings → Pages → Source: GitHub Actions (not "Deploy from a branch").
  The deploy step fails without this.

## Signing key

- Key ID: `CEAB168E6D2E30FF`
- Fingerprint: `7775 7473 70C3 E86F A12D  06D7 CEAB 168E 6D2E 30FF`
- UID: `AIMS OS Repository (apt repo signing key) <hakim@aims-senegal.org>`
- Algorithm: RSA 4096
- Expires: 2028-05-22. Bump with `gpg --edit-key CEAB168E6D2E30FF expire`
  and re-export to `aims-os-pubkey.gpg`.
