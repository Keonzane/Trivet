# Demo video

**Link:** https://drive.google.com/file/d/1XRP4GOaSpIvjc_lH8UESwu4c6EDX7u3Y/view?usp=drive_link
**Recorded with:** with my own voice and screen

## What it shows, in order

1. **Intro (slides 1–3):** who I am, what Trivet is, the problem it
   solves, and why there is no "balance score"
2. **Live demo:** the Dashboard, adding a project and logging hours,
   ticking off a workout, searching for a title in Leisure (suggestions
   with year and rating, the poster), marking it done with a rating, and
   swipe to delete with Undo
3. **How it's built (slide 7, then the code in VS Code):**
   - `theme.dart` and `context.pillars` (the design system in code)
   - `setState` per screen (`work_screen.dart`)
   - `ListStore` on `shared_preferences` (`storage_service.dart`)
   - the Cloudflare Worker that holds the API keys (`media_proxy/worker.js`)
   - the GitHub Actions deploy (`deploy.yml`)
4. **Challenges (slide 8):** week logic, keeping API keys out of a public
   repo, switching games from IGDB to RAWG, and Open Library going down
5. **AI segment (slide 9):** how I used Claude, where it got things wrong,
   the media search I wrote (`media_search_service.dart`), the rating and
   the poster, and the AI-written `ListStore` I understand best
6. **What's next (slide 10):** weekly goals, previous weeks, tests, a
   "follow system" theme, Google Books as a backup, source credits, and
   moving to an offline local database

## Before recording

- Sample data only: no real names, messages or personal details on screen.
- Notifications off.
- Sensible sample entries (for example "Thesis chapter 2", "Push day",
  "Dune"), not "asdf".
