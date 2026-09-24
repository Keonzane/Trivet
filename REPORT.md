# Weekly Increment Report

## Week of: September 24, 2026

## What changed this week

- Built `lib/theme.dart` from Design System v2: a light and dark
  `ColorScheme`, the `PillarColors` `ThemeExtension` for the three pillar
  accents, the five-slot `TextTheme` (Space Grotesk headings, IBM Plex
  Sans body), `AppSpacing` constants, and themed `Card`, `FilledButton`,
  `OutlinedButton`, input fields, `NavigationBar`/`NavigationRail`,
  `Chip` and `SegmentedButton`.
- Built all five data models — `Project`, `WorkLog`, `Workout`,
  `MediaEntry`, `LeisureLog` — each with `toMap`/`fromMap`.
- Built the storage layer: a generic `ListStore<T>` over
  `shared_preferences`, one store class per model (`ProjectStore`,
  `WorkLogStore`, `WorkoutStore`, `MediaStore`, `LeisureLogStore`), and a
  `WeekRange` helper for Monday-start week math.
- Built the **Work** screen: Active/Paused/Done filter, project list with
  hours logged this week, and an Add entry flow that can create a new
  project inline.
- Built the **Health** screen: streak count, weekly minutes, a
  `WeeklyBarChart`, today's session(s), earlier-this-week list, and an
  Add entry flow that can also edit an existing logged session.
- Built the **Leisure** screen: Want/In progress/Done filter (defaulting
  to Want), a `MediaCard` list, and an Add entry flow that can create a
  new title inline.
- Removed all seeded/sample data from the three list screens — every
  list now genuinely starts empty.
- Fixed a UI bug: the status filter's selected segment grew wider than
  the others because Flutter's `SegmentedButton` adds a checkmark icon to
  the selected segment by default; turned it off (`showSelectedIcon:
  false`) on both filters so segment width stays constant.

## Why

The theme, models, and storage layer are shared infrastructure every
screen needs, so they came first. Work and Health were built next because
they carry the largest MVP estimates in the proposal (7 h and 5 h), and
Leisure followed once the Add-entry pattern (list → filter → entry sheet
→ store) was proven out on the first two, since it follows the same
shape. Seed data was removed once real logging worked, so the app
reflects only what the person using it has actually entered — matching
the proposal's "no accounts, no shared data" design and giving an honest
starting state for testing. The filter-width fix was a straightforward
polish pass caught while re-testing the Leisure screen.

## What broke or what I got stuck on

- The mockup's `+ Add project` / `+ Add title` buttons assume a project
  or title already exists to select in the Add entry sheet. Once seed
  data was removed, that flow had nothing to select from on first use.
  I designed and added an inline "+ New project" / "+ New title" option
  to the dropdown so the first entry can be created without a separate
  screen — this wasn't specified in the mockup and is a judgment call I
  made to keep the sheet usable at zero state.
- The storage spike from the proposal (verifying `shared_preferences`
  read/write actually works, planned for Sept 24) hasn't been run yet —
  the code is written against the documented API but I have not run
  `flutter pub get` / `flutter run` against it myself this week.
- The week-range risk from the proposal (dated logs, streaks across week
  boundaries, planned test due Sept 28) also hasn't been tested yet —
  `WeekRange` is written but has no `flutter test` coverage.

## What is left

- Dashboard screen: triad chart (stretch, `TrivetMark` +
  `CustomPainter`), the three-stat-card row, the nudge text, and the
  "currently enjoying" shelf.
- A media detail screen for Leisure, where rating and completion percent
  get set — `MediaCard` can display a rating but nothing sets one yet.
- Unifying the Add entry sheet's pillar picker — each pillar currently
  opens its own sheet pre-selected, rather than one sheet with a
  `SegmentedButton` to switch pillars, since that switching is only
  reachable from the unbuilt Dashboard's unset `+ Log entry` button.
- Running the app for the first time (`flutter pub get`, `flutter run -d
  chrome`) and the week-range `flutter test`.
- Stretch goals: the triad chart and the Health routine builder.
