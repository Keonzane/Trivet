# Proposal

This is proposal version 2, the one I submitted, with the final changes
listed at the end. The submitted PDF is in
[assets/proposal.pdf](assets/proposal.pdf).

**App name:** Trivet

## The problem, in one sentence

A second-year student juggling coursework, a part-time job, the gym and a
reading habit has no single place that shows how many hours each of those
took this week, and whether one is crowding out the others.

## Who it is for

- **Who:** university students and early-career workers aged 18–30 whose
  week is self-directed rather than fixed by an employer, timetable or
  parent.
- **What they do today:** a to-do app or notes for work, a separate workout
  app (or nothing) for exercise, and Goodreads or memory for books and
  shows. None of these compare time across areas.

## Core features

| # | Feature | In the MVP? | Flutter pieces it needs | Estimate |
| --- | --- | --- | --- | --- |
| 1 | Work: add project, log dated hours, set status | MVP | `ListView.builder`, `Card`, `TextField`, `showDialog`, Project and WorkLog models | 7 h |
| 2 | Health: log workout, weekly streak | MVP | `ListView.builder`, `TextField`, `showDatePicker`, Workout model, streak computed from dates | 5 h |
| 3 | Leisure: log media with status and rating, log time spent | MVP | `ListView.builder`, `SegmentedButton` (want / in progress / done), star icons, MediaEntry and LeisureLog models | 6 h |
| 4 | Dashboard: hours per pillar this week side by side, plus nudge text | MVP | three `Card`s, nudge text, a week-range filter over the logs | 5 h |
| 5 | Add Entry shared modal | MVP | `showModalBottomSheet`, `SegmentedButton` to pick the pillar, `Form` with validators | 4 h |
| 6 | Saving and loading | MVP | one store per model, `load()` in `initState`, save after `setState`, loading indicator | 3 h |
| 7 | Radar / triad chart on the Dashboard | stretch | `CustomPainter` on a `CustomPaint` widget | 4 h |
| 8 | Routine builder inside the Health screen | stretch | Routine model, nested list editing, `ReorderableListView` | 6 h |

MVP total: about 30 hours; with both stretch items, about 40 hours, over the
3–4 weeks left in the term.

## Out of scope, and why

- **Accounts, sync and sharing.** A person's work, workouts and reading are
  personal. There is no feature where one user reads another's data, so a
  backend would cost setup time and give no feature in return.
- **A single "balance score".** Hours, workouts and leisure sessions have no
  natural conversion rate, so any score would be a guess. Trivet shows the
  hours per pillar side by side instead.
- **Hardware features** (camera, GPS, sensors, notifications). Trivet
  doesn't need any of them, so nothing has to fall back to sample data.
- **The routine builder** (stretch 2). Left out to protect the MVP; see the
  changes below.

## Data the app remembers, and where it is saved

Everything is saved on the device with `shared_preferences`, one key per
model. Each key holds a list of JSON strings, one per record. A realistic
week is 30–50 small records, a few hundred over a term, which is well within
what `shared_preferences` handles. Firebase or Supabase would add setup with
no benefit for a single-user offline app; Hive and Drift add adapters, code
generation or a schema for relationships the app doesn't have.

Final fields, as built:

| Thing | Fields | Where it is saved |
| --- | --- | --- |
| Project | id, title, status, notes, dueDate | key `projects` |
| WorkLog | id, projectId, hours, date | key `worklogs` |
| Workout | id, type, durationMinutes, date, notes, done, completedAt | key `workouts` |
| MediaEntry | id, title, type, status, rating, time spent, pages, runtime, seasons and episodes (total and current), notes, review, completedAt, posterUrl, year, externalIds | key `media` |
| LeisureLog | id, mediaId, minutes, date | key `leisurelogs` |
| Light or dark mode | the chosen mode | key `themeMode` |
| Weekly hours per pillar, streak, nudge | derived | not saved; computed from the logs |

Tradeoff accepted: every change rewrites the whole list for that key, and
"this week" is filtered in Dart after loading. If the history grew into the
thousands, I would move to Hive.

## Risks

- **Three hour totals might not be enough to show balance** without a
  score. First step: write out one full example week and check the totals
  read clearly on their own. (Planned for September 24.)
- **Week logic is easy to get subtly wrong.** The Dashboard needs hours per
  pillar for a given week, filtered across three kinds of dated logs, and
  the streak crosses week boundaries. First step: one week-range function,
  tested with `flutter test` on hand-picked dates (Sunday night, Monday
  morning, a gap week). (Planned for September 28.)

## Changes since the last version

- **2026-09-28** (proposal v2): removed the Balance Score; moved the radar
  chart and routine builder from MVP to stretch; changed the data model to
  dated WorkLog and LeisureLog entries, because a weekly view can't be built
  from one running total; switched storage from Hive to
  `shared_preferences`.
- **2026-09-30:** built stretch 1, the triad chart (`TrivetMark`, drawn with
  `CustomPaint`). It is the first thing on the Dashboard.
- **2026-10-04:** workouts became planned sessions (Push, Pull, Legs,
  Cardio) with a done checkbox, so Health shows "X of Y sessions done" and
  only done sessions count. Projects got notes and a due date. Added a
  light/dark toggle at the top right of each tab.
- **2026-10-09:** added leisure search (TMDB, RAWG, Open Library, AniList).
  This was not in the proposal, which said no API keys were needed. The
  keys stay out of the app: TMDB and RAWG go through a Cloudflare Worker
  that holds them as secrets. The app still works without the network
  except for search and the first font download.
- **2026-10-11:** swipe-to-delete now has a 5-second Undo instead of a
  confirmation dialog.
- **Not done:** the routine builder (stretch 2) was not built; the time
  went into the leisure detail screens and search instead. The
  week-range test from the second risk was not written, so there are no
  automated tests yet.
