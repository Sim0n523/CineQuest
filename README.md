# CineQuest

A gamified movie-tracking app built with Flutter. This package now includes
**Phase 1** (Auth, Navigation, Firebase, TMDB, Movie Details, Search),
**Phase 2** (Movie Logging, Watch History, Watchlist, Profile Statistics),
and **Phase 3** (XP, Levels, Achievements) from the CineQuest blueprint —
plus a Discover redesign and an Upcoming section along the way.

## Setup

Nothing new to configure — same Firebase project and TMDB key as before.

```
flutter pub get
flutter run
```

## What's new since Phase 2

- **Discover redesign** — no longer duplicates Home. Filter by sort
  (Popular / Top Rated / Newest / **Upcoming**) and by genre, both
  combinable via TMDB's real `/discover/movie` endpoint.
- **Upcoming movies** — unreleased films are watchlist-only. Movie
  Details hides the Log button and shows an "Add to Watchlist" action
  instead when a movie's release date is in the future.
- **Half-star ratings** — 0.5 increments (e.g. 4.5 stars), not just whole
  stars. Tap the left half of a star for a half rating, right half for
  full — same single tap as before, just position-aware now.
- **XP, Levels, Achievements are live.** Logging a *brand-new* movie
  (not an edit) awards XP, may level you up, and checks 6 achievement
  categories — all through `ProgressionService`, matching blueprint
  section 7's "everything flows through the ProgressionService" rule.
  A `RewardDialog` shows the payoff immediately after saving.

## Architecture additions (Phase 3)

- `core/services/progression_service.dart` — the only thing that awards
  XP, recalculates level, or unlocks achievements. Reads/writes
  `users/{uid}` (xp, level, achievementsUnlocked) and
  `users/{uid}/achievements/{category}` (which tier is unlocked).
- `core/services/achievement_service.dart` — pure computation (no I/O)
  deriving each category's current value and tier from watch history.
  Used both by ProgressionService (to detect new unlocks) and the
  Achievements screen (to display current progress) — same numbers,
  computed the same way, in one place.
- `utils/achievement_config.dart` — the 6 data-driven achievement
  definitions, each with 6 tiers. Movies Watched matches the blueprint's
  own example thresholds exactly (1/10/50/100/250/500).
- `widgets/xp_bar.dart`, `widgets/level_badge.dart`,
  `widgets/reward_dialog.dart` — the three blueprint section 11 widgets
  this phase unlocks.
- `screens/achievements_screen.dart` — new, reachable from Profile.

## Deliberate scope decisions

- **Progression only fires on a brand-new log, never an edit.**
  Re-checking XP/achievements on every edit would let repeated edits
  farm XP. Editing a log later to add a review you skipped initially
  won't retroactively award review XP — a known, minor limitation.
- **Only 6 of the blueprint's 11 achievement categories are built:**
  Movies Watched, Reviews Written, Genres Explored, Hours Watched,
  Cinema Visits, Decades Watched — everything computable from data we
  already collect. Not built:
  - **Directors, Actors** — need TMDB's `/movie/{id}/credits` endpoint,
    which nothing fetches today (same gap as Favorite Director in
    Phase 2's stats).
  - **Streaks** — real date-boundary logic, deferred since Phase 2.
  - **Special Events** — needs a product decision on what the events
    even are before it can be data-driven at all.
- **Collections are not built.** The blueprint's examples (Marvel, Star
  Wars, Harry Potter, Pixar, Christopher Nolan, IMDb Top 100, Oscar
  Winners, Palme d'Or Winners) are genuinely three different data
  problems — TMDB's own "collections" concept (Star Wars, Harry Potter),
  studio/person filmography filters (Pixar, Nolan — buildable via
  `with_companies`/`with_people` on `/discover/movie`), and data TMDB
  doesn't have at all (IMDb rankings, Oscar/Palme d'Or wins, which
  aren't tracked by TMDB and would need a separate data source). Worth
  a dedicated design pass rather than a rushed, inconsistent mix.
- **`achievementsUnlocked` counts total tiers unlocked across all
  categories**, not just how many categories have been touched — e.g.
  Movies Watched at Tier 3 plus Reviews at Tier 1 counts as 4. Chosen
  because it grows with every tier-up, matching "every movie logged
  should feel rewarding" better than a category count would.

## What's still stubbed

Quests and Leaderboard tabs (Phase 4) — unchanged.

## Next: Phase 4

Weekly/Monthly Quests, Leaderboard — the last of the core progression
loop described in blueprint section 3.
