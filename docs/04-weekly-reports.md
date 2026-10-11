# Weekly reports

Newest at the top. Weeks 1 and 2 were written during those weeks (they were
in `REPORT.md` until the docs moved into this folder). Weeks 3 and 4 were
written at hand-in from the commit history, so they are a summary, not a
diary.

---

## Week 4 (October 9 to October 11, 2026)

_Written at hand-in, from the commits._

**Done this week**
- Leisure search: typing a title searches TMDB (films, TV), RAWG (games),
  Open Library (books) and AniList (anime, manga) at the same time and
  fills in the totals of the picked result.
- A Cloudflare Worker (`media_proxy/`) holds the TMDB and RAWG keys as
  secrets, so no key is in the app or the repo.
- GitHub Actions workflow that publishes the web app to GitHub Pages and
  builds an APK.
- Security checklist filled in and confirmed, including opening a deploy
  log to check the secret shows as `***`.
- Rating in search suggestions, poster on the media detail screen.
- Undo after delete (5 seconds) and the TMDB credit under film and TV
  results.
- `AI-USAGE.md` written; repo reorganised into the course layout (`docs/`,
  `LICENSE`); the phone frame now shows on the live site too.

**In progress**
- Demo video and slides.

**Blocked or stuck on**
- IGDB for games needed a Twitch developer account, and I couldn't finish
  its 2FA setup in time. Switched games to RAWG, which only needs a free
  key.
- The first deploy ran without the `MEDIA_PROXY_URL` secret, so film and
  game search were off on the live site until I added it and re-ran.
- Open Library was unreachable from some networks, which leaves Book search
  with only AniList results there. Not fixable from the app; noted in the
  README.

**Decisions made, and why**
- Keys in a proxy, not in the app: a built web app or APK can be unpacked,
  so any key inside it is public.
- `dart_defines.json` is committed because it only holds the proxy URL,
  which is visible in the built web app anyway.
- Undo instead of a confirmation dialog, because a swipe is easy to do by
  accident. It disappears after 5 seconds; 10 felt too long.

**Hours spent, roughly:** about 8 hours

**Next week I will:**
- Hand in. After that: tests for the week-range logic, a "follow system"
  theme option, and pinning workflow actions to commit SHAs.

---

## Week 3 (October 2 to October 8, 2026)

_Written at hand-in, from the commits._

**Done this week**
- Swipe-to-delete on projects, workouts and titles.
- Detail screens from the mockup: project status, notes and due date on
  Work; Push / Pull / Legs / Cardio sessions with a done checkbox on Health;
  pages, seasons and episodes on Leisure.
- Dark mode toggle, rebuilt stat cards, and an All workouts screen.
- Typeable hours and minutes (`NumberStepper`).
- Leisure detail that changes per type and status, and Want / In progress /
  Done on one scrolling page (`SectionedList`), same for Work.
- Dashboard: today's workouts, active work and "done this week".
- Dead code removed and duplicated widgets merged.

**In progress**
- Media search (finished in week 4).

**Blocked or stuck on**
- Adding the done checkbox made every older workout read as not done, so my
  Health hours dropped. Fixed by reading old workouts as done.
- Notes and review shared one field, so finishing a title overwrote the
  notes. Split into two fields.

**Decisions made, and why**
- The pillar picker in the Add entry sheet only appears from the
  Dashboard. On a pillar's own tab the disabled picker looked like nothing
  was selected.

**Hours spent, roughly:** about 8 hours

**Next week I will:**
- Add leisure search, deploy the app, and fill in the security checklist.

---

## Week 2 (September 28 to October 1, 2026)

Baseline from week 1: theme, five models, the `shared_preferences` storage
layer, and working Work, Health and Leisure screens, with Home still a
placeholder and a separate Add entry sheet per pillar.

**Done this week**
- **Dashboard built** (was a placeholder). Shows the week's date range,
  three stat cards (hours worked, workouts, leisure hours) computed live
  from this week's entries, a nudge naming the thinnest pillar, and a
  "currently enjoying" shelf capped at two titles. Its **SEE ALL** jumps to
  the Leisure tab pre-filtered to In progress.
- **Media detail screen added.** Tapping a title in Leisure now opens a
  screen where its status (Want / In progress / Done) and star rating are
  set, total hours are shown, and more time can be logged. Before this,
  nothing in the app could set a rating.
- **One real Add entry sheet** with a pillar picker, replacing the three
  per-pillar sheets and the Dashboard's temporary "choose a pillar first"
  chooser. Opened from Work, Health or Leisure it is locked to that pillar;
  opened from the Dashboard's `+ Log entry` it starts unset and switchable.
- **Dropdown removed from the Add entry sheet.** `+ Add project` and
  `+ Add title` now always create a new one; tapping an existing row logs
  against that item. This replaces week 1's inline "+ New project" dropdown
  option.
- **Cleanup:** shared label extensions and `copyWith` on `MediaEntry`
  instead of duplicated label code; `EntryModal` now actually uses its
  `pillar` parameter; removed the placeholder screen and the two per-pillar
  sheets that nothing used any more; removed a stale `README_DAY8.md`.
- **Duplicated Add entry code removed.** The media detail screen now opens
  the one unified sheet, the date field is a single shared `DateField`
  widget, and the empty save callbacks for unreachable pillars are gone.
- **Documentation corrected:** the README now says the app needs a network
  connection on first launch for `google_fonts`; screenshots of Home, Work,
  Health, Leisure and the Add entry sheet were added.
- **Security checklist** filled in from the course template.

**In progress**
- Screenshots with data in them; the current ones are first-launch empty
  states.

**Blocked or stuck on**
- **The pillar lock was described but not built.** The first version left
  the picker switchable, so switching to another pillar from Work let me
  save an entry that was silently discarded. I only found this by using the
  app. Fixed by disabling the picker when opened from a pillar's own
  screen.
- **Add project defaulted to my oldest project.** Fixed by removing the
  dropdown.
- **My first attempt at "highlight the pillar" was wrong.** I replaced the
  locked picker with a single coloured pill; what I wanted was the normal
  three-segment picker with the current pillar filled in. Reverted.
- **Two claims in my own README were wrong:** that tabs "stay alive" when
  switching (only the active tab is mounted), and that the app is "fully
  offline" (`google_fonts`). Both corrected.

**Decisions made, and why**
- The Dashboard and media detail screen came first because they were the
  two MVP pieces with nothing behind them: the Dashboard is the app's
  purpose, and ratings had a display but no way to set them.
- One Add entry sheet with a picker, because that is what screen 05 of the
  mockup is.
- The dropdown went because it duplicated a choice already made by tapping
  a row, and it defaulted to the oldest entry, which made "add new" look
  broken.

**Hours spent, roughly:** about 8 hours

**Next week I will:**
- Add delete, screenshots with data, and the detail screens from the
  mockup. Stretch goals only if time allows.

---

## Week 1 (September 24 to September 27, 2026)

**Done this week**
- Built `lib/theme.dart` from Design System v2: light and dark
  `ColorScheme`, the `PillarColors` extension, the five-slot `TextTheme`,
  `AppSpacing`, and themed `Card`, buttons, inputs, `NavigationBar` /
  `NavigationRail`, `Chip` and `SegmentedButton`.
- Built all five data models (`Project`, `WorkLog`, `Workout`,
  `MediaEntry`, `LeisureLog`) with `toMap` / `fromMap`.
- Built the storage layer: a generic `ListStore<T>` over
  `shared_preferences`, one store per model, and a `WeekRange` helper for
  Monday-start weeks.
- Built the **Work**, **Health** and **Leisure** screens with their filters,
  lists and Add entry flows.
- Removed all seeded sample data, so every list starts empty.
- Fixed the selected `SegmentedButton` segment growing wider than the
  others (`showSelectedIcon: false`).
- Ran the app on a device for the first time and confirmed the three
  screens load, filter and save real entries.

**In progress**
- The Dashboard (still a placeholder) and a media detail screen.

**Blocked or stuck on**
- With seed data gone, `+ Add project` / `+ Add title` had nothing to
  select on first use. Added an inline "+ New project" / "+ New title"
  option, a judgment call not in the mockup.

**Decisions made, and why**
- Theme, models and storage first, because every screen needs them. Work
  and Health next, as the largest MVP estimates (7 h and 5 h); Leisure
  once the list → filter → sheet → store pattern was proven.
- The storage spike planned for September 24 is confirmed: a real project
  and workout persist through the app.

**Hours spent, roughly:** about 8 hours

**Next week I will:**
- Build the Dashboard, the media detail screen and one shared Add entry
  sheet with a pillar picker.