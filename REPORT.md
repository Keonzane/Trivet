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
- Ran the app on a device for the first time and confirmed the Work,
  Health, and Leisure screens load, filter, and save real entries
  correctly — screenshots added to the documentation.

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
  read/write actually works, planned for Sept 24) is now confirmed —
  screenshots show a real logged project and workout persisting through
  the app, not seed data.

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
- A screenshot of the Add entry sheet itself for the documentation.
- Stretch goals: the triad chart and the Health routine builder.

---

## Week of: September 28, 2026

Baseline from week 1: theme, five models, the `shared_preferences`
storage layer, and working Work, Health and Leisure screens, with Home
still a placeholder and a separate Add entry sheet per pillar.

## What changed this week

- **Dashboard built** (was a placeholder). Shows the week's date range,
  three stat cards (hours worked, workouts, leisure hours) computed live
  from this week's entries, a nudge naming the thinnest pillar, and a
  "currently enjoying" shelf capped at two titles. Its **SEE ALL** jumps
  to the Leisure tab pre-filtered to In progress.
- **Media detail screen added.** Tapping a title in Leisure now opens a
  screen where its status (Want / In progress / Done) and star rating
  are set, total hours are shown, and more time can be logged. Before
  this, nothing in the app could set a rating.
- **One real Add entry sheet** with a pillar picker, replacing the three
  per-pillar sheets and the Dashboard's temporary "choose a pillar first"
  chooser. Opened from Work, Health or Leisure it is locked to that
  pillar (all three segments shown, current one filled in, picker
  disabled); opened from the Dashboard's `+ Log entry` it starts unset
  and switchable.
- **Dropdown removed from the Add entry sheet.** `+ Add project` and
  `+ Add title` now always create a new one; tapping an existing row
  logs against that item. This replaces week 1's inline "+ New project"
  dropdown option.
- **Cleanup:** shared label extensions and `copyWith` on `MediaEntry`
  instead of duplicated label code; `EntryModal` now actually uses its
  `pillar` parameter (it was previously stored and ignored); removed the
  placeholder screen and the two per-pillar sheets that nothing used any
  more; removed a stale `README_DAY8.md`.
- **Duplicated Add entry code removed.** There were two copies of the
  Leisure form (a narrower `leisure_entry_sheet.dart` for the media
  detail screen's `+ Log time`, plus the Leisure fields in
  `add_entry_sheet.dart`), and the date field (formatting, controller,
  picker) was written out in every form. The detail screen now opens the
  one unified sheet, the date field is a single shared `DateField` widget
  (`date_field.dart`), and the empty "unreachable" save callbacks that
  Work, Health and Leisure passed for pillars they can't reach are gone:
  the callbacks are optional and a debug-mode assert checks a caller
  passed the ones it needs.
- **Documentation corrected:** the README now says the app needs a
  network connection on first launch for `google_fonts` (it previously
  said "fully offline"), and a Home screenshot showing the old
  placeholder was removed. Screenshots of Home, Work, Health, Leisure and
  the Add entry sheet were added, and a README sentence claiming the
  Dashboard could log against an existing project (untrue since the
  dropdown was removed) was corrected.
- **Security checklist** filled in from the course template and placed at
  the bottom of the README.

## Why

The Dashboard and media detail screen were the two remaining MVP pieces
from the proposal that still had nothing behind them: the Dashboard is
the app's stated purpose (see hours per pillar side by side), and
ratings and status had a display but no way to set them. The unified
Add entry sheet closes the last stand-in from the mockup, where screen 05
is one sheet with a pillar picker. The dropdown was removed because it
duplicated a choice the person had already made by tapping a row, and it
defaulted to the oldest entry, which made "add new" look broken. 

## What broke or what I got stuck on

- **The pillar lock was described but not built.** The unified sheet's
  picker was meant to be locked to a screen's own pillar, but the first
  version left it switchable. Switching to another pillar from Work, for
  example, let me fill in and save an entry that was silently discarded,
  because Work only wires up saving for its own data. I only found this
  by using the app. Fixed by disabling the picker when opened from a
  pillar's own screen.
- **Add project defaulted to my oldest project.** With existing data,
  the dropdown pre-selected the first project instead of "new." Fixed by
  removing the dropdown (see above).
- **My first attempt at "highlight the pillar" was wrong.** I replaced
  the locked picker with a single coloured pill; what I actually wanted
  was the normal three-segment picker with the current pillar filled in.
  Reverted.
- **A claim in my own README was wrong.** It said tabs "stay alive" when
  switching. They don't: only the active tab's screen is mounted, so
  each switch rebuilds it. That means data stays fresh across tabs, but
  UI state such as the selected filter resets. Corrected in the README.
- **"Fully offline" was also wrong** because of `google_fonts` (see
  above). Corrected.

## What is left

- Screenshots with data in them: the current Home, Work, Health and
  Leisure screenshots are first-launch empty states, and the media detail
  screen has none.
- No delete: projects, workouts and titles can be added and edited but
  not removed.
- Loading assumes stored data is well-formed; a corrupted
  `shared_preferences` value would leave a screen on its spinner
  (documented in the README and checklist).
- Filter selection and scroll position reset when switching tabs.
- Stretch goals, only if time allows: the triad chart on the Dashboard
  and the Health routine builder.
- Final-week deliverables: presentation, video and slides.
