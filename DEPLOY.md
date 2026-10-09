# Publishing Trivet from GitHub

GitHub builds the app for you. The built app and website contain **no API
keys**: keys live only in Cloudflare (see MEDIA_SEARCH_SETUP.md). GitHub
only needs your proxy's address.

| You do | You get |
|---|---|
| Push to `main` | Website at `https://<username>.github.io/<repo>/` |
| Push a tag like `v1.0.0` | `trivet-v1.0.0.apk` on the Releases page |
| Actions → Build and deploy → Run workflow | Website + APK to download from that run |

## One-time setup

1. **Deploy the proxy** first (MEDIA_SEARCH_SETUP.md, steps 1–2).
2. **Push the project** to a GitHub repo with the default branch named `main`.
   Run `git status` first: `local.properties`, `.wrangler`, `.dart_tool` and
   `build` must NOT be listed.
3. **Add one secret**: repo → Settings → Secrets and variables → Actions →
   New repository secret:
   - `MEDIA_PROXY_URL` = your Cloudflare worker URL
4. **Turn on Pages**: repo → Settings → Pages → Source: **GitHub Actions**.
5. Push any commit to `main`, or run the workflow from the Actions tab.
   The first run takes about 5–8 minutes. The site link appears in the run.

If the secret is missing, the build still works; Film and Game search are
just off.

## Releasing an APK

    git tag v1.0.0
    git push origin v1.0.0

After a few minutes the APK is on the repo's Releases page. Share that link.
Friends download it, allow "install unknown apps" once, and install.

## Good to know

- **Updating the APK:** each build is signed with a fresh temporary key, so
  installing a newer version over an old one fails with "app not installed".
  Uninstall the old one first (saved entries on that phone are lost). For a
  permanent signing key, set up a keystore and add it as secrets.
- **Lock the proxy to your website (optional):** in `media_proxy/wrangler.toml`
  uncomment the `[vars]` lines, set your github.io address, and run
  `npx wrangler deploy` again. Other websites then can't use your proxy from
  a browser. The APK is unaffected.
- **Data:** entries are saved on each device (or in each browser), not online.