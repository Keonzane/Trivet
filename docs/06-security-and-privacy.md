# Security and privacy

This repository is public. Checked by me, with the evidence for each answer
below.

**Last checked:** 2026-10-09 (row 2 updated 2026-10-11, when
`dart_defines.example.json` was added)

## What this app stores

| Data | Where it lives | Who can see it |
| --- | --- | --- |
| Projects and logged work hours | on the device (`shared_preferences`; in the browser's local storage on the web) | only that user, on that device |
| Workouts | on the device (`shared_preferences`) | only that user |
| Leisure titles, progress, ratings, notes, reviews and logged time | on the device (`shared_preferences`) | only that user |
| Light or dark mode | on the device (`shared_preferences`) | only that user |
| What the user types into leisure search | sent to TMDB and RAWG (through my proxy), Open Library and AniList to find matches; not stored by the app or the proxy | those services |

There are no accounts, and nothing the user logs leaves the device.

## Secrets

- Values my app needs at run time: `MEDIA_PROXY_URL` (the address of the
  search proxy). It is not a secret.
- The real secrets are `TMDB_API_KEY` and `RAWG_API_KEY`. They live only in
  Cloudflare, as secrets on the Worker in `media_proxy/` (set with
  `npx wrangler secret put`). The app never has them.
- Locally the proxy URL is in `dart_defines.json`, passed with
  `--dart-define-from-file=dart_defines.json`. It is committed because it
  isn't secret; `dart_defines.example.json` shows the format.
- The deploy workflow gets the URL from the repository secret
  `MEDIA_PROXY_URL` (Settings > Secrets and variables > Actions).
- What the deployed web build carries that a visitor could read: only the
  proxy URL. That is acceptable because the proxy only forwards search
  requests (`GET` and `OPTIONS` only), adds the keys on its own side, and
  never returns them.

## What protects the data on the service side

Nothing the user logs leaves the device, so there is no database and no
rules to write. The only server is the Cloudflare Worker, which stores
nothing: it only accepts the TMDB search and detail paths and the RAWG game
search the app uses, passes on a short list of allowed parameters, cuts each
to 200 characters and caps RAWG results at 20.

## Checklist

- [x] Private config is not committed: there is no `.env`; the API keys are
  Cloudflare secrets. `dart_defines.json` holds only the public proxy URL,
  and `dart_defines.example.json` is committed
- [x] `git log -p | grep -i "api_key\|secret\|password\|token"` finds nothing real (row 4)
- [x] No service account file, keystore or `service_role` key anywhere in the repo (row 3)
- [x] Security rules or RLS policies: not applicable, no backend database (rows 13–17)
- [x] No real personal data in sample data, screenshots or the video (rows 18, 21, 22)
- [x] No course or university credentials anywhere (no `student.json`)
- [x] Anyone whose data appears in a test was asked first: not applicable,
  there are no tests with anyone's data

## Full checklist

### Secrets and credentials

| # | Check | Yes / No / N/A | Evidence |
| --- | --- | --- | --- |
| 1 | No API key, token or password is hardcoded in `lib/`, including in comments and commented-out code | Yes | Searched `lib/` and `pubspec.yaml` for key, secret, password, token and api_key, comments included. The only matches are comments explaining that keys live on the proxy; no key values. The TMDB and RAWG keys exist only as Cloudflare secrets. |
| 2 | Anything private is in a gitignored config or passed with `--dart-define`, with an example file committed | Yes | The API keys are Cloudflare secrets set with `wrangler secret put`, never in the repo. The app only gets the proxy URL, through `--dart-define-from-file=dart_defines.json`. `dart_defines.json` is committed on purpose because the URL is not secret (it is visible in the built web app anyway), and `dart_defines.example.json` is committed to show the format for anyone running their own proxy. Cloudflare account files (`media_proxy/.wrangler/`) are gitignored. |
| 3 | No keystore, `key.properties` or signing credential is in the repository | Yes | Checked a fresh clone of the pushed repo with `git ls-files` for .jks, .keystore, key.properties, .pem and .env: no matches. |
| 4 | Git history is clean: I searched `git log -p` for password, secret, api key and token | Yes | Searched every added and removed line in `git log -p` for password, secret, api key and token. Matches are only documentation, checklist text and names like `TMDB_API_KEY` or `secrets.MEDIA_PROXY_URL`; no key values. Also searched for key-shaped strings (32-character hex, JWT, Google `AIza` keys): none. |
| 5 | Any credential that was ever committed has been rotated | N/A | No credential was ever committed (see row 4), so there is nothing to rotate. |

### GitHub Actions

| # | Check | Yes / No / N/A | Evidence |
| --- | --- | --- | --- |
| 6 | No secret value is written literally in any workflow YAML file | Yes | `.github/workflows/deploy.yml` is the only workflow. Its only secret is read as `${{ secrets.MEDIA_PROXY_URL }}`; no values are written in the file. |
| 7 | Secrets are stored in repository Actions secrets and read with `${{ secrets.NAME }}` | Yes | `MEDIA_PROXY_URL` is a repository Actions secret (Settings → Secrets and variables → Actions) and the workflow reads it with `${{ secrets.MEDIA_PROXY_URL }}`. |
| 8 | No workflow step echoes, dumps or debug-prints a secret, and I opened a recent run's log to confirm | Yes | No step echoes or prints the secret; it is only written into `dart_defines.json` for the build. Opened the latest "Build and deploy" run → web → "Write proxy URL file from secrets": `MEDIA_PROXY_URL` shows as `***` in the log. (The first run showed it blank because the secret hadn't been added yet; I added it and re-ran.) |
| 9 | If I build a signed APK: the keystore is a base64 secret decoded to a file at build time, never printed | N/A | The Android job builds an APK with Flutter's default debug signing (`signingConfigs.getByName("debug")` in `android/app/build.gradle.kts`); there is no release keystore. |
| 10 | Uploaded build artifacts contain no key file, keystore or generated config | Yes | The web job uploads `build/web` and the Android job uploads the APK. Neither contains a key or keystore; the only config compiled in is the proxy URL, which is not secret. |
| 11 | Third-party actions are pinned to a commit SHA, not a moveable tag | No | Actions are pinned to version tags (`actions/checkout@v4`, `subosito/flutter-action@v2`, `softprops/action-gh-release@v2` and others), not commit SHAs. Next step: replace each tag with its commit SHA. |
| 12 | Secret scanning and push protection are enabled on the repository | Yes | Secret scanning and push protection are both enabled in the repo's Settings → Advanced Security → Secret Protection. Push protection for my account is also on in my account Settings → Code security. |

### Backend and security rules

The app has no database or accounts: all user data is stored on the
device with `shared_preferences`. The only server is the Cloudflare
Worker, which stores nothing and only forwards searches. Rows 13–17 are
therefore N/A.

| # | Check | Yes / No / N/A | Evidence |
| --- | --- | --- | --- |
| 13 | Firestore and Storage rules are not left open to anyone; they require an authenticated user | N/A | No Firebase or Supabase is used, so there are no rules to write (covers rows 13–17). |
| 14 | Rules restrict a user to their own documents where that makes sense | N/A | No backend database and no accounts (see row 13). |
| 15 | If Supabase: Row Level Security is on for every table | N/A | Supabase is not used (see row 13). |
| 16 | Firebase and Google API keys are restricted in the Google Cloud console to the APIs and app they are for | N/A | The app uses no Firebase or Google API keys (see row 13). The TMDB and RAWG keys never leave the proxy. |
| 17 | I opened the app signed out and confirmed I could not read or write data I should not | N/A | There is no sign-in and no shared data: each install only holds its own entries (see row 13). |
| 18 | Seed and sample data is invented, not real people's data | N/A | The app has no seed or sample data. |

### Input and app surface

| # | Check | Yes / No / N/A | Evidence |
| --- | --- | --- | --- |
| 19 | Input is validated before it is written, not only styled as valid in the UI | Yes | `_save()` in `add_entry_sheet.dart` checks the trimmed title is not empty before a project or title is created. Durations and progress only change through `NumberStepper`, which clamps to its min and max, so progress can't pass a title's totals. The proxy only accepts search paths, cuts each parameter to 200 characters and caps RAWG results at 20. Not checked: title and notes length. |
| 20 | Nothing secret is recoverable from the built app, since a shipped binary can be unpacked | Yes | The built app contains only the proxy URL, which is not secret. The API keys stay in Cloudflare and are added to requests on the proxy's side. |

### Repository and privacy

| # | Check | Yes / No / N/A | Evidence |
| --- | --- | --- | --- |
| 21 | No student number, personal email, phone number or home address in the repository or in commit messages | Yes | Every commit uses a `@users.noreply.github.com` author address (`git log --format="%an %ae %s"`). `android/local.properties` and `media_proxy/.wrangler/` are gitignored and not in the repo. |
| 22 | No classmate's personal data in the repository | Yes | The app only stores the person's own entries and the project contains no data about anyone else. |
| 23 | Dependencies come from pub.dev, and `build/` and `.dart_tool/` are gitignored | Yes | Runtime dependencies are google_fonts, shared_preferences, http, url_launcher and device_preview, all from pub.dev. `.gitignore` lists `.dart_tool/` and `build/`. |
| 24 | Images, fonts and other assets are mine, licensed, or credited | Yes | Fonts are Space Grotesk and IBM Plex Sans (SIL OFL) via `google_fonts`. Search data comes from TMDB, RAWG, Open Library and AniList, credited in the README's Credits section; RAWG and TMDB are also credited in the app under their search results, as their terms require. Screenshots are my own captures. |
| 25 | Repository visibility is deliberate, and I checked it after my last push | Yes | Public, so the instructor can view it. Opened it signed out after the push: no `.dart_tool`, `build`, `.wrangler` or `local.properties` is in the repo. |

### Anything I found and fixed

Filling this in caught several things. The README said the app was fully
offline, but `google_fonts` downloads the fonts on first launch, so I
corrected it. A corrupted stored record used to leave a screen stuck on
its loading spinner; `ListStore.load()` now skips bad records. Adding
media search meant handling API keys: instead of putting them in the app,
they live as Cloudflare secrets in a proxy, and I removed the unused IGDB
code that would have needed a Twitch client secret. An old GitHub
secret-scanning alert was a false positive from a committed `.dart_tool`
browser profile; `.dart_tool/` is now gitignored. Checking row 8 showed the
first deploy ran with an empty proxy URL because I hadn't added the
`MEDIA_PROXY_URL` secret yet, so film and game search were off on the
website; I added the secret and re-ran the deploy. One item is still open:
workflow actions are pinned to tags, not commit SHAs (row 11).