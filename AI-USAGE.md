# AI Usage

I built Trivet with heavy help from Claude (Anthropic), used through the
Claude app. I designed the app first (the mockup, the design system and the
proposal), then asked Claude to turn those into Flutter code, day by day,
and kept asking for changes after testing each version myself. Most of the
code in `lib/` was written by Claude. This file says what I asked for, what
I kept or changed, where it went wrong, and which part is my own.

Repository: https://github.com/Keonzane/Trivet

## How I used AI

### 1. Building the first version of the app
- Date and tool: 2026-09-28, Claude
- What I asked for: to build Trivet from my mockup, design system and
  proposal PDFs, starting from day 8 of my 20-day plan, plus the week 1
  README and report.
- What it gave back: the models, a shared_preferences storage layer, the
  four tabs (Dashboard, Work, Health, Leisure), the add-entry sheet, and a
  theme using my colours and fonts.
- What I kept, changed, and why: I kept the structure. I asked it to remove
  the hard-coded sample entries, because they hid what the app looks like
  for a new user, and to build the Leisure screen next.
- Commit: https://github.com/Keonzane/Trivet/commit/6523181

### 2. The triangle chart and the Dashboard
- Date and tool: 2026-09-30, Claude
- What I asked for: the next days of my plan, including the Dashboard
  triangle from my mockup.
- What it gave back: `trivet_mark.dart` (the triangle chart drawn with
  CustomPaint), Dashboard changes, and safer loading in `ListStore` so one
  broken record no longer stops a whole list from loading.
- What I kept, changed, and why: I kept it all and checked the triangle
  against my mockup.
- Commit: https://github.com/Keonzane/Trivet/commit/1b1a26b

### 3. New leisure titles start as "Want"
- Date and tool: 2026-10-01, Claude
- What I asked for: to make "Want" the default for new leisure entries and
  the default filter.
- What it gave back: a one-line change in the add-entry sheet.
- What I kept, changed, and why: I asked for this after testing. A title
  you just added is one you haven't started, so "In progress" was wrong.
- Commit: https://github.com/Keonzane/Trivet/commit/afba6da

### 4. Swipe to delete
- Date and tool: 2026-10-03, Claude
- What I asked for: a way to delete projects, workouts and media.
- What it gave back: `DismissibleRow`, swipe-left-to-delete with a
  confirmation dialog, used on all three tabs.
- What I kept, changed, and why: I kept it. Delete stays out of the way of
  the tap that opens an entry. The trade-off is that it is easy to miss,
  which I noted in my README.
- Commit: https://github.com/Keonzane/Trivet/commit/80954b0

### 5. Making the screens match my mockup
- Date and tool: 2026-10-04, Claude
- What I asked for: the detail screens from my mockup: project status,
  notes and date on Work; push, pull, legs and cardio with a checklist and
  upcoming sessions on Health; pages, seasons and episodes on Leisure.
- What it gave back: `project_detail_screen.dart`, `workout_row.dart`, the
  per-type media detail screen, and new model fields.
- What I kept, changed, and why: I kept most of it, then sent screenshots
  where it did not match my mockup and asked for fixes (next entry).
- Commit: https://github.com/Keonzane/Trivet/commit/0218c26

### 6. Dark mode, stat cards and "See all workouts"
- Date and tool: 2026-10-04, Claude
- What I asked for: stat cards and segment buttons that look exactly like
  my mockup, a dark mode toggle at the top right, and a button to see all
  workouts.
- What it gave back: `ThemeController` (saves light or dark), the
  `ScreenHeader` with the toggle, a new `StatCard`, and
  `all_workouts_screen.dart`.
- What I kept, changed, and why: I kept them and compared each screen with
  my mockup.
- Commit: https://github.com/Keonzane/Trivet/commit/b5d3acc

### 7. Typeable hours and minutes
- Date and tool: 2026-10-04, Claude
- What I asked for: the duration picker to step by 1, accept typing, and
  show hours and minutes on one line.
- What it gave back: `NumberStepper` and a rebuilt `DurationStepper`.
- What I kept, changed, and why: I kept it. The old picker took too many
  taps to enter a long session.
- Commit: https://github.com/Keonzane/Trivet/commit/565d05f

### 8. Leisure detail per type and one-page sections
- Date and tool: 2026-10-05, Claude
- What I asked for: a different detail form per media type and status, and
  the Want / In progress / Done lists on one scrolling page.
- What it gave back: the redesigned media detail screen and
  `SectionedList`, a list whose top bar jumps to a section and follows your
  scrolling.
- What I kept, changed, and why: I kept it. Afterwards I asked for books to
  show pages and series to show season and episode on the card.
- Commit: https://github.com/Keonzane/Trivet/commit/9c3ec6f

### 9. Due dates on Work, and the Dashboard lists
- Date and tool: 2026-10-07, Claude
- What I asked for: a due date on projects instead of "Personal" and "last
  logged", no date on "Log hours", and Today's workouts, Active work and
  Done this week on the Dashboard.
- What it gave back: `dueDate` on `Project`, a `DateField` that can be set
  to "None", and the new Dashboard sections.
- What I kept, changed, and why: I kept them. Asked afterwards for the
  green edge on workout rows so they match the other cards.
- Commits: https://github.com/Keonzane/Trivet/commit/cc1a154 and
  https://github.com/Keonzane/Trivet/commit/f12ecb3

### 10. Removing dead code and merging duplicates
- Date and tool: 2026-10-06 to 2026-10-08, Claude
- What I asked for: to remove dead code and combine anything that could be
  combined, so the code is shorter.
- What it gave back: shared widgets (`Section`, `ChoiceBar`,
  `DetailScaffold`, `Caption`), `put` and `removeWhere` on `ListStore`, and
  fixes it found on the way.
- What I kept, changed, and why: I kept it and asked what was removed
  before accepting it.
- Commits: https://github.com/Keonzane/Trivet/commit/342c242,
  https://github.com/Keonzane/Trivet/commit/fd42c3b and
  https://github.com/Keonzane/Trivet/commit/639378e

### 11. The search proxy, setup docs and deploy workflow
- Date and tool: 2026-10-09, Claude, in the Claude app
- What I asked for: a way to use TMDB and RAWG from my media search
  without putting their API keys in the app, plus a way to publish the app
  from GitHub.
- What it gave back: a Cloudflare Worker in `media_proxy/` that holds the
  TMDB and RAWG keys as secrets and only forwards search requests, the
  setup docs (`MEDIA_SEARCH_SETUP.md`, `DEPLOY.md`, `START_HERE.md`), the
  `setup.bat` and `run.bat` scripts, and a GitHub Actions workflow that
  builds the website and an APK.
- What I kept, changed, and why: I kept the proxy and the workflow. I
  removed the IGDB parts from the proxy and the setup doc. IGDB needs a
  Twitch developer account, and I couldn't finish its 2FA setup; I would
  have had to wait a day or two to try again and didn't have the time. I
  found RAWG instead, which only needs a free key, and switched games
  search to it. I committed `dart_defines.json`,
  because it only holds the proxy URL and without it film and game search
  are off for anyone who clones the repo. I later removed `setup.bat`,
  `tool/patch_android.ps1` and `START_HERE.md`, because the platform
  folders and the Android changes they made were already committed.
- Commit: https://github.com/Keonzane/Trivet/commit/d0cb68b

## Where the AI got it wrong

### 1. Old workouts disappeared from my stats
- What it gave me: when it added the "done" checkbox, saved workouts with
  no `done` value were read as not done (`?? false`).
- What was wrong: every workout I had logged before the checkbox existed
  stopped counting, so my Health hours dropped for no reason.
- What I did instead: I questioned the default, and the fix reads old
  workouts as done (`?? true`), since they were logged as finished.
- Commit: https://github.com/Keonzane/Trivet/commit/b33d133

### 2. The locked pillar picker looked broken
- What it gave me: when adding from the Work, Health or Leisure tab, the
  Work / Health / Leisure picker was locked by disabling it. Claude said
  the code was fine.
- What was wrong: my screenshot showed the disabled picker with nothing
  selected, so it looked like no pillar was chosen.
- What I did instead: I decided to remove the picker on those tabs and only
  show it when adding from the Dashboard, where you need to choose.
- Commit: https://github.com/Keonzane/Trivet/commit/5cd8b78

### 3. Notes and Review shared one field
- What it gave me: one `notes` field used both for notes while a title is
  in Want and for the review once it is Done.
- What was wrong: finishing a title overwrote my notes with the review, or
  the other way round. They are different things.
- What I did instead: I asked for them to be stored separately, so there is
  now a `review` field next to `notes`.
- Commit: https://github.com/Keonzane/Trivet/commit/fd42c3b

### 4. The proxy kept IGDB code nobody used
- What it gave me: a proxy with an IGDB route, Twitch token code, and
  `POST` allowed on every request, plus a setup section for switching games
  to IGDB, even though games search used RAWG.
- What was wrong: dead code that would have needed a Twitch client secret,
  and a route that accepted `POST` requests for no reason, which is more
  open than the proxy needs to be.
- What I did instead: I removed the IGDB route, the Twitch token code and
  the setup section, and limited the proxy to `GET` and `OPTIONS`. I did
  this before my first commit of the proxy, so the commit only shows the
  cleaned-up version.
- Commit: https://github.com/Keonzane/Trivet/commit/d0cb68b

## Who wrote what

### Parts I wrote myself

#### 1. The leisure media search
- Files: `lib/services/media_search/` (`media_search_service.dart`,
  `media_provider.dart`, `media_search_config.dart` and the TMDB, RAWG,
  Open Library and AniList providers), `lib/models/media_result.dart`, and
  the search suggestions in `lib/widgets/add_entry_sheet.dart`
- Commit: https://github.com/Keonzane/Trivet/commit/d0cb68b
- What it does: `media_search_service.dart` is the single entry point for
  the leisure search. It takes what the user typed and the selected kind
  (Film, Series, Book or Game), asks every API that handles that kind, and
  returns one combined list of results. Searches shorter than 2 characters
  return nothing, so the APIs aren't called on every letter.
- Why it is built that way: it is built around a shared interface,
  `MediaProvider`, so TMDB, RAWG, Open Library and AniList are separate
  classes with the same methods and the service can treat them all the
  same way. Each API call is wrapped in a `try`/`catch` with an 8-second
  timeout, so if one source fails or is slow it just contributes nothing
  and the others still show results. The add-entry sheet only calls four
  methods and never needs to know which API answered: `search()` for
  results, `canSearch()` to check that at least one source for that kind
  is configured (for example TMDB is off without the proxy URL),
  `setupHint()` to show a "Search is off" message when none is, and
  `enrich()` after a result is picked, to fetch details the search leaves
  out (runtime, seasons, episodes) with the same timeout and `try`/`catch`.
- Key details: `Future.wait` sends the requests to all the relevant APIs
  at the same time, so a Book search through Open Library and AniList
  takes only as long as the slower one, not both added together. The
  results are interleaved, the first result from each source, then the
  second from each, and so on, so no single source floods the list, and a
  `Set` of keys removes duplicates along the way.
- The other files, in short:
  - `media_provider.dart`: the template every API class must follow. Each
    one needs a short `id` (like `tmdb`), a display `name`, the kinds it
    handles (`types`), a check for whether it's ready (`isConfigured`), and
    a `search()` method. `enrich()` does nothing by default because most
    APIs already give all the info in their search results; only TMDB
    needs it.
  - `tmdb_provider.dart`: searches films and TV shows through the proxy,
    so the TMDB key never goes into the app. Movie and TV IDs get a
    `movie/` or `tv/` prefix because TMDB can give a movie and a show the
    same number. When the user picks a result, `enrich()` gets extra
    details: the film's runtime, or the show's seasons and episodes.
  - `rawg_provider.dart`: searches games through the proxy. Results are
    re-sorted by popularity because RAWG sometimes puts fan-made games
    above the real ones. The image link is changed to a smaller size so it
    loads faster. The rating is out of 5, so it's doubled to fit the app's
    0–10 scale. The "Game data from RAWG" link is shown because RAWG's
    rules require giving them credit.
  - `anilist_provider.dart`: uses a GraphQL query to ask AniList for anime
    and manga by title. Anime shows up as Series and manga as Book, since
    the app has no separate anime or manga categories. AniList scores are
    out of 100, so they're divided by 10 to fit the 0–10 scale.
  - `open_library_provider.dart`: searches books and reads the title,
    author, page count and cover image. It needs no key because Open
    Library is free and open to everyone, so it doesn't go through the
    proxy.
  - `media_search_config.dart`: reads the proxy URL that is passed in when
    the app is built (`--dart-define-from-file=dart_defines.json`). It
    cleans the URL by removing extra spaces and any slash at the end, and
    ignores it if it's still the placeholder. If there's no valid URL,
    film, TV and game search turn off and show a "Search is off" message.
  - `media_result.dart`: the shared format for one search result, no
    matter which API it came from. It holds the title, year, poster,
    rating and other details. Its `key` joins the source and the ID (like
    `tmdb:movie/438631`), which makes each result unique so duplicates can
    be removed. `toEntry()` turns a picked result into a new Want entry.
  - `add_entry_sheet.dart` (search part): while the user types, the app
    waits a short moment before searching, so it doesn't search on every
    letter. When the user picks a suggestion, the title and kind are filled
    in, and extra details are loaded in the background. When those details
    arrive, the app checks `_picked?.key` to make sure the user didn't pick
    something else while waiting, so old details never replace a newer
    choice. Editing the title after picking clears the pick.

### One part the AI wrote: `ListStore` in `lib/services/storage_service.dart`

Claude wrote this. Below is what it does, why it is built that way, and why
I kept it.

- File: `lib/services/storage_service.dart`
- Commit: https://github.com/Keonzane/Trivet/commit/639378e
- What it does: `ListStore` is the part of the app that saves and loads all
  your data on the device. Trivet has five kinds of data (projects, work
  logs, workouts, media and leisure logs), and all five use this one class.
  Each item is turned into text (JSON), and the whole list is saved under
  one name using `shared_preferences`. When a screen opens, `load()` turns
  the text back into items. If one saved item is broken, it's skipped, so
  the rest still load. `put()` updates an item if one with the same id
  already exists, or adds it if it's new. `removeWhere()` deletes every
  item that matches a rule. That's how deleting a project also deletes all
  of its work logs.
- Why it is built that way: all five kinds of data are saved the same way.
  The only differences are the save name, how to turn the item into text
  and back, and how to find its id. So instead of writing the same code
  five times, there's one class, and each kind of data passes in its own
  differences. `shared_preferences` is enough because the app stores only
  a small amount of data on the phone, with no accounts or server.
- Why I kept it: because there's only one class, any improvement reaches
  every screen at once. When skipping broken records, `put()` and
  `removeWhere()` were added to this class, every tab got them without any
  other changes.