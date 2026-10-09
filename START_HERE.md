# Start here

Your proxy is already deployed and `dart_defines.json` already has its URL,
so you only need to do this once on your PC:

1. Double-click **setup.bat** (or run `.\setup.bat` in the VS Code terminal).
   It adds the android / web / windows folders, allows internet on Android,
   and downloads packages.
2. Run the app:
   - **Chrome (easiest):** `.\run.bat -d chrome`
   - **Android phone / emulator:** `.\run.bat` and pick the device
   - **VS Code:** press F5 (uses the "Trivet" launch config)

When it starts, the console should print:

    [media-search] TMDB: ready
    [media-search] RAWG: ready

Then in the app: Add → Leisure → pick Film / Series / Book / Game and type a title.

- `dart_defines.json` is committed. It only holds the proxy URL, which is
  not secret; the API keys stay in Cloudflare.
- Proxy keys live in Cloudflare. To change one: `cd media_proxy` then
  `npx.cmd wrangler secret put TMDB_API_KEY` (or `RAWG_API_KEY`).
- Publishing to GitHub: see DEPLOY.md.