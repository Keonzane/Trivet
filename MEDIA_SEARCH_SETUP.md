# Leisure search setup

The app contains **no API keys**. TMDB and RAWG are reached through a small
Cloudflare Worker (`media_proxy/`) that holds the keys. The app only knows
the proxy's address (`MEDIA_PROXY_URL`).

| Kind chip | Sources | Needs |
|---|---|---|
| Book | Open Library + AniList (manga) | nothing |
| Series | TMDB (TV, via proxy) + AniList (anime) | proxy for non-anime |
| Film | TMDB (via proxy) | `MEDIA_PROXY_URL` |
| Game | RAWG (via proxy) | `MEDIA_PROXY_URL` |

If a kind has no working source, the add sheet says so under the title field.
In debug runs the console prints each source's status at startup and the
reason any search fails (`[media-search] TMDB failed: ...`).

## 1. Get the keys (you only paste them into Cloudflare)
- **TMDB:** themoviedb.org → Settings → API → request a key (Developer,
  personal use). Either the short "API Key" or the long "Read Access Token".
- **RAWG:** sign up at rawg.io (email or Google), then rawg.io/apidocs →
  Get API Key. Test in a browser:
  `https://api.rawg.io/api/games?key=KEY&search=zelda&page_size=3`
  RAWG's terms require the "Game data from RAWG" link the app shows under
  game results; keep it.

## 2. Deploy the proxy (Node + a free Cloudflare account)
    cd media_proxy
    npx wrangler login
    npx wrangler deploy
    npx wrangler secret put TMDB_API_KEY
    npx wrangler secret put RAWG_API_KEY

`deploy` prints your proxy URL, e.g. `https://trivet-media-proxy.you.workers.dev`.

Check it (replace the URL):

    curl https://trivet-media-proxy.you.workers.dev/
    # {"ok":true,"tmdb":true,"rawg":true}
    curl "https://trivet-media-proxy.you.workers.dev/tmdb/3/search/movie?query=dune"
    curl "https://trivet-media-proxy.you.workers.dev/rawg/api/games?search=zelda&page_size=3"

## 3. Run the app
Put your proxy URL in `dart_defines.json`, then:

    flutter run --dart-define-from-file=dart_defines.json

- Android Studio: Run → Edit Configurations → Additional run args:
  `--dart-define-from-file=dart_defines.json`
- The URL is baked in at build time: after changing it, stop and re-run.

## Changing a key later
Run `npx wrangler secret put <NAME>` again in `media_proxy/`. It takes effect
immediately. No app rebuild needed.

## Platform notes
- Android release builds: `android/app/src/main/AndroidManifest.xml` needs
  `<uses-permission android:name="android.permission.INTERNET"/>`, and for the
  RAWG link to open on Android 11+, a `<queries>` entry for https links
  (`<intent><action android:name="android.intent.action.VIEW" /><data android:scheme="https" /></intent>`).
  The GitHub workflow adds both automatically.
- macOS: add `com.apple.security.network.client` = true to both
  `macos/Runner/*.entitlements`.