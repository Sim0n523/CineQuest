# CineQuest

A gamified movie-tracking app built with Flutter. This package now includes
**Phases 1-4** from the CineQuest blueprint: Auth/TMDB/Search, Movie
Logging/Watch History/Watchlist, XP/Levels/Achievements, and now
**Weekly/Monthly Quests + Leaderboard** — plus the Discover redesign,
Upcoming section, and half-star ratings picked up along the way.

## Setup

Nothing new to configure — same Firebase project and TMDB key as before.

```
flutter pub get
flutter run
```

## What's new in Phase 4

- **Leaderboard** — global ranking by total XP. Reads directly from the
  `users` collection; Phase 1's Firestore rules already allow any
  signed-in user to read any user doc, specifically so this wouldn't
  need a rules change now. If you're outside the visible top 50, your
  exact rank is still shown via a Firestore count aggregation rather
  than fetching the entire user base.
- **Weekly & Monthly Quests** — 3 quests are randomly selected each
  period from a small pool, tracked per-user in
  `users/{uid}/quests/{weekly|monthly}`, and automatically regenerated
  the moment the period rolls over (checked whenever the Quests tab
  opens, not just when you log a movie).
- **Quest completion awards XP** (+250 weekly, +500 monthly, matching
  blueprint section 12) through the same `ProgressionService` that
  already handles achievement XP — checked at the same moment a movie
  gets logged, alongside achievement checks.

## Architecture additions (Phase 4)

- `core/services/leaderboard_service.dart`, `core/providers/leaderboard_provider.dart`
- `utils/quest_config.dart` — the data-driven quest pool (`QuestTemplate`,
  `QuestMetric`) and period-boundary math (`QuestPeriodUtils`)
- `core/models/quest_period_state.dart` — the runtime state for an
  active quest set (`QuestPeriodState`, `ActiveQuest`, `QuestBundle`)
- `core/services/quest_service.dart` — fetch-or-generate the current
  period (Firestore I/O) plus pure progress computation, matching
  blueprint section 7's separate "QuestService" entry
- `core/services/progression_service.dart` — extended to check quest
  completion alongside achievements, still the only place XP gets
  awarded from

## Deliberate scope decisions

- **Two of the blueprint's own quest examples were swapped out**, not
  built as-is:
  - *"Complete Harry Potter Collection"* (monthly) needs the Collections
    system, which isn't built (see Phase 3's README notes on why).
  - *"Watch Movies From Five Countries"* (monthly) needs TMDB's
    `production_countries` field — nothing fetches or stores that today.
  - Replaced with "Genre Hopper," "Marathon Month," and "Prolific
    Critic" — same spirit, computable from data already collected.
  - A third blueprint example, *"Finish Three Weekly Quests"* (monthly),
    was also left out — it needs a new piece of persisted state (a
    history of weekly completions) that nothing else in the app
    produces yet. Rather than bolt on a special-cased, harder-to-verify
    meta-quest for this pass, every quest type here uses the same
    simple pattern: compute directly from watch history in the period.
- **Quest progress uses `loggedAt`, not `watchDate`.** `watchDate` can
  be freely backdated when logging a movie; using it for quest progress
  would let someone "complete" a weekly quest by backdating an old log.
  `loggedAt` (when the entry was actually created) can't be gamed that way.
- **Quest periods use "Monday of the current week" as both the boundary
  and the rollover-detection key**, not true ISO-8601 week numbering —
  ISO weeks have real edge cases around New Year's (week 1 can start in
  December). This is simpler and just as reliable for "has the week
  changed" purposes.
- **Leaderboard rank ties aren't specially broken** — two users with
  identical XP may show adjacent ranks in either order. Acceptable for
  this scale; worth revisiting if it matters later.

## What's still stubbed

Collections, and the achievement categories noted in the Phase 3
section of this file (Directors, Actors, Streaks, Special Events).

## Next: Phase 5

Camera, Location, Animations, Polish, Documentation — see the
conversation notes on why Camera/Location (both marked "Low priority"
in the blueprint itself) are worth treating as a separate decision from
the Animations/Polish/Documentation half of this phase.
