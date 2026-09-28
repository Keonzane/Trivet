# Trivet

## 1. Overview

Trivet is a weekly balance tracker for university students and
early-career workers whose week isn't fixed by an employer, timetable, or
parent. It shows how many hours went into Work, Health, and Leisure this
week, side by side, so a person can see when one pillar is crowding out
the others — without a made-up "balance score" behind it.

## 2. Setup and installation

- Built against Flutter's stable channel, Dart SDK `>=3.3.0 <4.0.0` (see
  `pubspec.yaml`).
- Clone the repository, then from the project root:

  ```
  flutter pub get
  ```

- No configuration needed. Trivet is single-user with no backend — there's
  no backend URL, no API key, and nothing to place in an `.env` file. All
  of the person's data is stored locally on the device with
  `shared_preferences` and never sent anywhere. One caveat: the
  `google_fonts` package downloads the two font families (Space Grotesk,
  IBM Plex Sans) from Google Fonts the first time the app runs, so that
  first launch needs a network connection; after that they're cached.

## 3. How to run it

```
flutter run -d chrome
```

(or `flutter run` targeting a connected device/simulator). On launch you
should see a bottom navigation bar with four tabs — **Home**, **Work**,
**Health**, **Leisure** — and Design System v2's Paper/Ink colour scheme
(light by default, following the system theme). All four tabs are live.

To run the automated tests:

```
flutter test
```

This currently covers `WeekRange` (Monday-start week math) with four
hand-picked dates, per the proposal's own risk-mitigation plan.

## 4. Features and usage

**Work** — Filter projects by Active / Paused / Done. Each row shows the
project and hours logged this week. Tapping `+ Add project` opens the
Add entry sheet in "new project" mode — a title field, no picker — while
tapping an existing project's row opens the same sheet locked to that
project, to log more hours against it. Duration is set in 0.5 h steps.

**Health** — Shows your current day streak and total minutes this week,
a bar chart of minutes per day, today's session(s), and the rest of the
week's sessions below. `+ Log workout` opens the Add entry sheet: choose
a type (Push/Pull/Legs/Run/Swim), set duration in 5-minute steps, add
notes, set the date, and save. Tapping an existing session reopens the
sheet pre-filled, to edit it.

**Leisure** — Filter titles by Want / In progress / Done (opens on
Want). Each row shows the title, its kind and status, and either hours
logged this week or a star rating. `+ Add title` opens the Add entry
sheet in "new title" mode — title and kind, no picker. Tapping a row
(rather than `+ Add title`) opens that title's **detail screen** instead,
where its status and star rating are set, and where more time can be
logged against it.

**Home (Dashboard)** — Shows the week's date range, three stat cards
(hours worked / workouts / leisure hours, all computed live from this
week's entries), a one-line nudge naming whichever pillar is thinnest,
and — when there's anything to show — a "currently enjoying" shelf of up
to two titles that aren't in Want status, with a **SEE ALL** that jumps
to the Leisure tab pre-filtered to In progress. `+ Log entry` opens the
real Add entry sheet with its pillar picker unset — pick Work, Health, or
Leisure and the fields underneath swap to match; from here each choice
creates something new (a new project, workout or title). The triad chart
(stretch, per the proposal) isn't built.

There's no dropdown anywhere in the Add entry sheet. Tapping a row
already says exactly which project/title you mean, and `+ Add project` /
`+ Add title` always means "create a new one" — the same way
`+ Log workout` always creates a new workout. A dropdown would just be a
second way to pick something you could already pick by tapping its row.

Every entry point opens the same sheet (`add_entry_sheet.dart`): Work's
`+ Add project` / row tap, Health's `+ Log workout` / row tap, Leisure's
`+ Add title`, the media detail screen's `+ Log time`, and Dashboard's
`+ Log entry`. There is no second copy of the form. Opened from a
specific pillar's own screen, the picker is pre-selected and locked to
that pillar (see Known issues for why); opened from the Dashboard, it's
unset and freely switchable.

## 5. Project structure

```
lib/
  main.dart                  # app entry point, theme wiring, tab shell
  theme.dart                 # ColorScheme (light+dark), PillarColors,
                              # TextTheme, AppSpacing, themed components
  models/
    project.dart              # Work: Project
    work_log.dart              # Work: WorkLog
    workout.dart                # Health: Workout
    media_entry.dart             # Leisure: MediaEntry
    leisure_log.dart              # Leisure: LeisureLog
  services/
    storage_service.dart       # ListStore<T> + one store per model,
                                # WeekRange (Monday-start week math)
  widgets/
    pillar_card.dart, pillar_button.dart, primary_button.dart,
    stat_card.dart, weekly_bar_chart.dart, media_card.dart, app_nav.dart,
    empty_state.dart, app_text_field.dart, duration_stepper.dart,
    date_field.dart            # date text field + picker, shared by every
                                # form (also holds formatShortDate)
    entry_modal.dart           # shared sheet shell (drag handle, title,
                                # Cancel/Save)
    add_entry_sheet.dart       # the one Add entry sheet — one pillar
                                # picker, three field sets
  screens/
    dashboard_screen.dart, work_screen.dart, health_screen.dart,
    leisure_screen.dart, media_detail_screen.dart
```

State is held per-screen with `StatefulWidget` + `setState`, loaded from
and saved back to the matching store — there's no separate state
management package.

## 6. Screenshots

Running on the phone frame (`flutter run`), light theme, per Design
System v2:

| Home (Dashboard) | Work |
| --- | --- |
| ![Home dashboard](screenshots/home.png) | ![Work screen](screenshots/work.png) |

| Health | Leisure |
| --- | --- |
| ![Health screen](screenshots/health.png) | ![Leisure screen](screenshots/leisure.png) |

| Add entry sheet (opened from Work) |
| --- |
| ![Add entry sheet](screenshots/add-entry.png) |

These are first-launch screens with nothing logged yet, so every list
shows its empty state and the Home stat cards read zero — the app ships
no sample data. The Add entry sheet screenshot shows the pillar picker
locked to Work (all three segments visible, Work filled in) with the
"new project" form underneath.

Still needed: screenshots with data in them (the Home nudge and
"currently enjoying" shelf, a populated Work/Health/Leisure list) and
the media detail screen.

## 7. Known issues and next steps

- **Dashboard's triad chart isn't built.** It's an explicit stretch goal
  in the proposal — the rest of the Dashboard (stat row, nudge, shelf) is
  done without it.
- **The pillar picker is locked when opened from Work, Health, or
  Leisure's own screen** (only Dashboard's `+ Log entry` allows switching
  freely). It still shows all three segments with the current pillar
  filled in — it just can't be changed. This is a deliberate trade-off, not an oversight: the unified
  sheet's picker lets you switch to *any* pillar and save against it, but
  saving requires that pillar's data already be loaded — Dashboard loads
  all five stores, but Work/Health/Leisure only load their own. Locking
  the picker in those three contexts avoids either (a) every screen
  loading all five stores just in case, or (b) a switch silently failing
  to save. Revisiting this would mean giving every screen the same
  five-store load Dashboard has, which is real duplicated work for a
  fairly narrow benefit (being able to log a workout without leaving the
  Work tab). Worth noting honestly: the first version of this lock was
  *described* but not actually wired up — the picker was switchable
  everywhere, and switching away from a screen's own pillar saved
  nothing, silently. Caught by testing the app, not by reviewing the
  code, and fixed by actually disabling the control.
- **Correction from an earlier version of this doc:** it used to say tabs
  "stay alive" when you switch between them. That was wrong — `main.dart`
  only ever mounts the active tab's screen, so switching tabs fully
  rebuilds it (`initState()` runs again) rather than preserving it. The
  upside: this means data *does* stay in sync across tabs automatically —
  logging a project from the Dashboard will show up on Work the next time
  you open that tab, since it reloads from `shared_preferences` fresh
  every time. The downside: any state that isn't persisted — the selected
  status filter, scroll position — resets to its default every time you
  leave a tab and come back. Worth an `IndexedStack` or real state
  management if that resetting starts to feel wrong.
- **A corrupted or hand-edited `shared_preferences` value would break
  loading.** `fromMap` uses `byName` and `jsonDecode` without guards, so
  an unknown enum value or malformed JSON throws inside a screen's
  `_load()` and leaves it on its loading spinner. Fine while the only
  writer is the app itself; worth a try/catch that skips bad records if
  this ever handles imported data.
- **No delete.** Projects, workouts, and titles can be added and edited
  but not removed.
- **No picker for an existing project/title from `+ Add project` /
  `+ Add title`.** An earlier version had a dropdown there that defaulted
  to whichever project was added first, which read as broken (you'd tap
  "add new" and land on old data). Fixed by removing the dropdown
  entirely: `+ Add project` / `+ Add title` now always creates a new one,
  and logging against an existing project/title happens by tapping its
  row instead — the same pattern Health already used.
- **Duplication in the Add entry code was removed.** There used to be a
  second, narrower Leisure sheet (`leisure_entry_sheet.dart`) for the
  media detail screen's `+ Log time`, and the date field (formatting,
  controller, picker) was written out in every form. The detail screen
  now opens the same `add_entry_sheet.dart` as everything else, and the
  date field is one shared `DateField` widget. Screens also no longer
  pass empty "unreachable" save callbacks for pillars they can't reach:
  the callbacks are optional, and a debug-mode assert checks that a
  screen passed the ones it needs.

## AI usage

This project was built with AI assistance. See `AI-USAGE.md` for the
tool, prompts, and what was kept or changed.

## Weekly records

- `REPORT.md` — weekly increment reports (week 1 and week 2).
- `journal/` — weekly reflection journal entries.


# Security checklist

## Secrets and credentials

| # | Check | Yes / No / N/A | Evidence |
| --- | --- | --- | --- |
| 1 | No API key, token or password is hardcoded in `lib/`, including in comments and commented-out code | Yes | Searched `lib/` and `pubspec.yaml` for key, secret, password, token, http, firebase and supabase, comments included: no matches. The app has no backend, so there is nothing to hardcode. |
| 2 | Anything private is in a gitignored config or passed with `--dart-define`, with an example file committed | N/A | The app has nothing private: no backend, no API and no config values, so there is no config file or `--dart-define` to use. |
| 3 | No keystore, `key.properties` or signing credential is in the repository | Yes | No .jks, .keystore, key.properties, .pem or .env file exists. Ran `git ls-files \| Select-String -Pattern "jks\|keystore\|key\.properties\|\.pem\|\.env"`|
| 4 | Git history is clean: I searched `git log -p` for password, secret, api key and token | Yes | Ran `git log -p \| Select-String -Pattern "password\|secret\|api.?key\|token" -CaseSensitive:$false` on the single-commit history. The only matches were prose in README.md and REPORT.md stating the app has no secrets; no credential values in code or config. |
| 5 | Any credential that was ever committed has been rotated | N/A | No credential was ever created for this app, so there is nothing to rotate (this holds only if row 4 finds nothing). |

## GitHub Actions

The project has no workflows, so every row in this section is N/A.

| # | Check | Yes / No / N/A | Evidence |
| --- | --- | --- | --- |
| 6 | No secret value is written literally in any workflow YAML file | N/A | There is no .github/workflows folder in the project, so no workflows exist (covers rows 6-12). Confirmed `Test-Path .github` returns False.|
| 7 | Secrets are stored in repository Actions secrets and read with `${{ secrets.NAME }}` | N/A | No workflows, so no secrets are used (see row 6). |
| 8 | No workflow step echoes, dumps or debug-prints a secret, and I opened a recent run's log to confirm | N/A | No workflows, so there are no runs or logs (see row 6). |
| 9 | If I build a signed APK: the keystore is a base64 secret decoded to a file at build time, never printed | N/A | I do not build a signed APK and have no workflows (see row 6). |
| 10 | Uploaded build artifacts contain no key file, keystore or generated config | N/A | No workflows upload artifacts (see row 6). |
| 11 | Third-party actions are pinned to a commit SHA, not a moveable tag | N/A | No workflows use any actions (see row 6). |
| 12 | Secret scanning and push protection are enabled on the repository | N/A | There are no secrets or workflows to protect (see row 6); I could still switch this on in the repository settings. |

## Backend and security rules

The app has no backend: all data is stored on the device with `shared_preferences`. Rows 13–17 are therefore N/A.

| # | Check | Yes / No / N/A | Evidence |
| --- | --- | --- | --- |
| 13 | Firestore and Storage rules are not left open to anyone; they require an authenticated user | N/A | No Firebase or Supabase is used, so there are no rules to write (covers rows 13–17). |
| 14 | Rules restrict a user to their own documents where that makes sense | N/A | No backend and no accounts (see row 13). |
| 15 | If Supabase: Row Level Security is on for every table | N/A | Supabase is not used (see row 13). |
| 16 | Firebase and Google API keys are restricted in the Google Cloud console to the APIs and app they are for | N/A | The app uses no Firebase or Google API keys (see row 13). |
| 17 | I opened the app signed out and confirmed I could not read or write data I should not | N/A | There is no sign-in and no shared data: each install only holds its own entries (see row 13). |
| 18 | Seed and sample data is invented, not real people's data | N/A | The app has no seed or sample data, so there is nothing to check. |

## Input and app surface

| # | Check | Yes / No / N/A | Evidence |
| --- | --- | --- | --- |
| 19 | Input is validated before it is written, not only styled as valid in the UI | Yes | `_save()` in `add_entry_sheet.dart` checks the trimmed title is not empty before a project or title is created, and durations can only change through `DurationStepper`, which stops at zero. Not checked: title and notes length, and a duration of zero is allowed. |
| 20 | Nothing secret is recoverable from the built app, since a shipped binary can be unpacked | Yes | The app contains no keys, tokens or credentials to recover. The person's entries live in on-device storage, not in the binary. |

## Repository and privacy

| # | Check | Yes / No / N/A | Evidence |
| --- | --- | --- | --- |
| 21 | No student number, personal email, phone number or home address in the repository or in commit messages | Yes | Commit author is the GitHub noreply address (checked with `git log --format="%an %ae %s"`). No personal email appears in commit messages.|
| 22 | No classmate's personal data in the repository | Yes | The app only stores the person's own entries and the project contains no data about anyone else. |
| 23 | Dependencies come from pub.dev, and `build/` and `.dart_tool/` are gitignored | Yes | Runtime dependencies are google_fonts, shared_preferences, device_preview and cupertino_icons, all from pub.dev. Confirmed .gitignore lists .dart_tool/ and build/. |
| 24 | Images, fonts and other assets are mine, licensed, or credited | Yes | The fonts are Space Grotesk and IBM Plex Sans, both open-licensed (SIL OFL) and loaded through `google_fonts`; no image assets are bundled; the screenshots are my own captures of the app. |
| 25 | Repository visibility is deliberate, and I checked it after my last push | Yes | Opened the repo in a private window after the final push. It is **public**, which is intended so the instructor can view it. No journal, .dart_tool or build folder is visible. |

## Anything I found and fixed

Filling this in caught two things. The README said the app was fully
offline, but `google_fonts` downloads the two fonts from Google the first
time the app runs, so I corrected the README and it now says so. I also
noticed that stored data is read back without any guard (`jsonDecode` and
`byName` in the models), so a corrupted value would leave a screen on its
loading spinner; I have not fixed that, only documented it under Known
issues. The checklist found no secrets because the app never needed any.
