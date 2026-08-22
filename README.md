# CineQuest

A gamified movie-tracking app built with Flutter. Phases 1-4 complete.
Phase 5: Location, Camera, Collections, and Animations & Polish are all
done. Working through a round of post-Phase-5 fixes/notes now (see
"What's new" below) — batches 1-4 done, Documentation remains,
deliberately saved for last.

## Setup

Same as before (Firebase project, TMDB key). Nothing new to configure for
Collections — it's TMDB-only, no new services.

```
flutter pub get
flutter run
```

## What's new: Collections

- Resolved by **name** via TMDB's search endpoints at runtime
  (`/search/collection`, `/search/company`, `/search/person`) — not
  hardcoded numeric IDs, so there's no risk of a stale/wrong ID silently
  showing the wrong movies.
- 5 curated collections: Star Wars, Harry Potter, The Lord of the Rings
  (TMDB's own collection objects), Pixar (studio, via
  `/discover/movie?with_companies=`), Christopher Nolan (person, via
  `/discover/movie?with_crew=`).
- `core/services/collection_service.dart` — picks the right
  search-then-fetch path per source type; matches blueprint section 7's
  named "CollectionService".
- `core/providers/collection_provider.dart` — fetches all 5 collections
  **concurrently** (not sequentially) for speed; skips any that fail to
  resolve rather than failing the whole screen.
- `screens/collections_screen.dart` (list, progress bars, poster
  thumbnails) and `screens/collection_detail_screen.dart` (movie grid,
  checkmark overlay on logged ones), both reachable from Profile.
- **+400 XP per completed collection** (blueprint section 12), via a new
  `ProgressionService.checkCollectionCompletion()` — checked when the
  Collections screen detects completion, not during movie logging (would
  mean 5+ extra TMDB calls on every single log). Guarded by a persisted
  `completed` flag so XP is only ever awarded once.
- `CollectionCompleteDialog` — the celebration shown the moment a
  collection is finished.

## What's new: post-Phase-5 fixes, batch 4 — Camera gallery upload

- **Gallery upload option added, alongside the existing camera capture**
  — the custom live-preview `CameraCaptureScreen` stays as the
  first-listed, default option (it's the actual "camera services" rubric
  implementation, deliberately not displaced), with a new bottom-sheet
  choice between "Take a Photo" and "Choose from Gallery" wherever the
  photo picker opens (`log_movie_screen.dart`). Gallery path uses
  `image_picker`, returns a local file path exactly like the camera
  capture does, so nothing downstream (saving, display, tap-to-view)
  needed to change.
- **Package version pinned deliberately, not caret-ranged:**
  `image_picker: 1.2.1` exactly. Checked pub.dev first (learned from the
  `camera` package already breaking `pub get` once) — the current latest
  `image_picker` needs Dart 3.12+, and an intermediate version needs
  Dart 3.10+, both past this project's Dart 3.9.2 floor. 1.2.1 is
  confirmed (from its own published pubspec.yaml) to need only Dart
  ≥3.7.0. Used an exact pin rather than `^1.2.1` specifically because a
  caret range could still resolve to one of those newer, incompatible
  1.x versions.
- Not verified: whether `image_picker`'s gallery path needs any
  `AndroidManifest.xml` permission additions. Modern Android (13+) uses
  the system Photo Picker, which needs no permission declarations at
  all, and the plugin's own manifest merges in whatever it needs for
  older versions automatically in the normal case — but this couldn't be
  confirmed by actually building the APK. If a permission-related crash
  shows up on first test, that's the first thing to check.

## What's new: post-Phase-5 fixes, batch 3 continued — the two proposed items, now built

Both items flagged last round as "bigger than a config change, ask
first" are done — the user said go ahead on both:

- **Directors/Actors achievements are real now.** Required actually
  extending the data model, not just a new category:
  `TMDBService.getMovieDetails` now requests
  `append_to_response=credits` (one extra query param, no extra HTTP
  call), so `MovieModel` gets `directorId`/`directorName`/`leadActorId`/
  `leadActorName` populated (first crew credit with `job == 'Director'`;
  first, i.e. top-billed, cast credit). `WatchHistoryEntry` gained the
  same 4 fields, populated from the movie at log time
  (`log_movie_screen.dart`). Two new achievements read off this:
  **Behind the Camera** (distinct directors watched) and **Star Power**
  (distinct lead actors watched). Known limitation, documented in
  `MovieModel`'s comment: co-directed films only attribute the first
  director found, not all of them — an acceptable simplification for a
  diversity stat, not worth a schema change to a list field.
  **Also known:** if a user taps "Log This Movie" fast enough (before
  `MovieDetailsScreen`'s background detail fetch resolves — see batch
  1's `seed` optimization), that one log won't have director/actor
  attribution, same graceful-degradation shape as `photoPath` before
  Camera existed. Not worth blocking the button over.
- **Collector achievement is real now**, tiered on
  `collectionsCompleted`. This needed `ProgressionService`'s
  achievement-check loop pulled out of `processMovieLogged` into a
  shared private `_checkAchievements`, since `collectionsCompleted` only
  ever changes inside `checkCollectionCompletion` — a movie log alone
  can never move this achievement's value. Both entry points now run
  the same check; `CollectionCompleteDialog` can show achievement
  unlocks now too (previously only `RewardDialog` could).
- `AchievementService.currentValueFor` gained an optional
  `collectionsCompleted` parameter (defaults to 0) to support this,
  since that one category doesn't derive from `WatchHistoryEntry` like
  every other category does.

## What's new: post-Phase-5 fixes, batch 3 — collections, achievements

- **Nolan bug fixed.** `CollectionSourceType.person` (used `/discover/movie?with_crew=X`,
  which matches ANY crew role — producer, writer, editor, not just
  directing) is now split into `director` and `actor`, both going
  through `/person/{id}/movie_credits` instead:
  `TMDBService.getMoviesDirectedByPerson` filters crew entries to
  `job == 'Director'`; `getMoviesActedInByPerson` uses the cast list,
  capped to top-billed appearances (`order <= 5`) and then the 40 most
  popular of those — a prolific actor's complete cast credits can run
  into the hundreds once cameos and minor roles are counted, which would
  make "complete the collection" unreasonable.
- **7 new collections**, all resolved by name search like the original
  5 (verified the franchise names against real TMDB collection pages
  before adding, rather than guessing): The Hobbit, Jurassic Park,
  Fast & Furious, The Godfather (franchises); Quentin Tarantino, Steven
  Spielberg, James Gunn (directors); Leonardo DiCaprio, Samuel L.
  Jackson, Ryan Gosling (actors) — 10 new total including the Nolan
  fix's re-resolve, bringing the collection count to 15.
- **New achievement: Five-Star Fanatic** — tiers on how many movies
  you've rated the full 5 stars, same pure-computation pattern as the
  existing 6 (`WatchHistoryEntry.rating`, no new fetch needed).
- **Not built, honestly scoped in code comments this time:** Director/
  Actor achievement categories (the `/person/{id}/movie_credits` fetching
  this needs now exists, but `AchievementService` computes purely from
  `WatchHistoryEntry`, which doesn't store a logged movie's director/cast
  — real schema work, not a free follow-on) and a Collections-completed
  achievement (`collectionsCompleted` is already tracked on `UserModel`,
  but nothing currently runs an achievement check when it changes — that
  only happens inside `ProgressionService.processMovieLogged`, triggered
  by a log, and collection completion is a separate flow). Also not
  built: cross-franchise "theme" collections like shark movies (Jaws +
  The Meg + Sharknado) — doesn't map to a single TMDB entity the way
  everything else here does, would need a new multi-query source type.

## What's new: post-Phase-5 fixes, batch 2 — progression economy rework

- **Level cap removed.** `LevelConfig` (`utils/xp_config.dart`) was a
  fixed 10-entry array; it's now formula-based with no cap. Levels 1-6
  are unchanged (0/100/250/450/700/1000 XP) — nobody's existing progress
  shifts. From level 6 onward the climb is deliberately steeper than
  before: each level now costs 250 XP more than the last, forever
  (previously it was +100 per level, and stopped at level 10 entirely).
  Level 10 now needs 4700 XP (was 3200 and the end of the line); level 20
  needs ~31,450 XP — the pace itself keeps increasing, so higher levels
  stay meaningful rather than becoming a treadmill.
- **Monthly quest reward bumped 500 → 1000 XP** (`utils/quest_config.dart`)
  — now a clean 4x a weekly quest's 250, instead of 2x, to actually
  reflect the extra time/effort a monthly quest takes. Weekly rewards
  unchanged.
- **Collection completion XP now scales with collection size** instead
  of a flat 400 for all five. New formula in
  `ProgressionService.checkCollectionCompletion`:
  `500 base + 50 × (movies in the collection)`, computed live off the
  collection's actual resolved movie count
  (`AppConstants.xpCollectionBase` / `xpCollectionPerMovie`). Lord of the
  Rings (3 films) now pays out 650 XP; Pixar (~30 films) pays out ~2000.
  **Note:** Nolan's collection currently over-counts (31 movies instead
  of his real ~13 director credits — see batch 3 below), so its payout
  will drop once that's fixed. Nothing extra to do when that happens —
  the formula reads the movie count live, not a cached value.

## What's new: post-Phase-5 fixes, batch 1 of several

The user came back with a list of real-world usage notes after living
with the app for a while. Tackling them in batches rather than all at
once; this is the first — the low-risk, self-contained items:

- **Leaderboard now updates live.** It was a one-shot fetch on screen
  open; `LeaderboardService.watchTopUsers()` (new) uses Firestore's
  `.snapshots()` instead of `.get()`, and `LeaderboardProvider.listen()`
  replaces the old `load()`, holding a subscription for the screen's
  lifetime rather than fetching once. The out-of-top-50 exact rank is
  still a separate one-off aggregation query, recomputed each time the
  top list refreshes and the current user isn't in it — kept that way
  deliberately rather than adding a second permanently-open listener for
  a comparatively rare case.
- **Backdrop image no longer visibly lags behind the Hero animation.**
  Root cause: `MovieDetailsScreen` was built from a bare movie id, so it
  always re-fetched full detail data before it could draw anything —
  even though the screen the user just tapped from almost always already
  had a full `MovieModel` in hand (TMDB's list/search/discover responses
  already include backdrop, poster, rating, and overview; only fields
  like `runtime` are detail-only). Added an optional `seed` parameter —
  when passed, the screen renders real content immediately, and the
  background fetch just fills in the rest silently once it lands. Wired
  into Home, Discover, Search, and Collection Detail (Watch History and
  Watchlist don't have a full `MovieModel` on hand — their Firestore
  entries only store a poster path — so those two still show the
  original loading state).
- **Tap the logged photo to view it full-screen**, pinch-to-zoom via
  Flutter's built-in `InteractiveViewer` (new `photo_viewer_screen.dart`)
  — no new package needed for this one.
- **Keyboard now dismisses on tap** anywhere on the Log Movie screen
  while the review field is focused.

## What's new: Animations & Polish

Four areas, all done in one pass:

- **XP & reward animations** — every progress bar in the app
  (`XPBar`, achievement tiers, quest progress, collection completion) now
  animates to its new value instead of snapping; new shared
  `widgets/animated_progress_bar.dart` backs all of them. `LevelBadge`
  pops in with a slight overshoot whenever the level it's showing
  changes. `RewardDialog` and `CollectionCompleteDialog` now scale+fade
  in (new `utils/dialog_transitions.dart`), the trophy/collection icon
  does an elastic "pop," the XP number counts up from 0, and newly
  unlocked achievements/quests stagger in one at a time.
- **Screen transitions & Hero** — a custom fade + upward-drift page
  transition is wired into `ThemeData.pageTransitionsTheme`
  (`themes/app_theme.dart`), so it applies to every push/pop app-wide
  without touching individual `Navigator.push` call sites. Movie posters
  now Hero-morph into `MovieDetailsScreen`'s backdrop from Discover,
  Search, Watch History, Watchlist, and Collection Detail.
  **Deliberately not on Home** — its Trending and Popular rows can both
  show the same movie at once (TMDB's lists overlap), and two Heroes
  sharing a tag on screen at once is a runtime crash, not just a visual
  glitch. `MovieDetailsScreen` was restructured so the Hero is present
  from the very first frame (a neutral placeholder during the TMDB
  fetch, swapped for the real backdrop once loaded) — a Hero that only
  appears after data loads is one frame too late for the flight to fire.
- **List/card interactions** — `MovieCard` now scales down slightly on
  press. New `widgets/fade_slide_in.dart` staggers list/grid items in
  (fade + slight upward slide, capped so long lists don't take forever)
  — wired into Discover, Achievements, Collections, Collection Detail,
  Leaderboard, Quests, Watch History, Watchlist, Search, Home, and
  Profile's stat grid and nav links.
- **Loading skeletons** — new `widgets/shimmer_box.dart` +
  `widgets/skeleton_loaders.dart` replace plain spinners with
  content-shaped placeholders (poster rows/grids, list tiles,
  leaderboard tiles) on Home, Discover, Search, Watch History,
  Watchlist, Leaderboard, and Collections. **Left as plain spinners,
  deliberately:** Camera and Nearby Cinemas (out of scope for this
  pass), Profile's initial `user == null` state and Quests' initial load
  (both brief, low value to reskin).

## Deliberate scope decisions

- **Not built:** anything needing data TMDB doesn't have at all (IMDb Top
  100, Oscar Winners, Palme d'Or Winners) — building those would mean
  fabricating movie-ID lists rather than resolving real TMDB data.
- **Studio/person collections only fetch 2 pages (~40 movies) from
  TMDB**, not the full filmography. Covers Nolan's ~13 films completely;
  Pixar's ~30 films should mostly fit but an edge case (a very obscure
  title ranked outside the top 40 by popularity) could theoretically
  never show as "logged" toward completion. Acceptable trade-off against
  the cost of full pagination for a rarely-hit edge case.
- **Collection completion is checked when the screen is viewed, not in
  real time as movies are logged.** Small trade-off: finishing a
  collection won't show the celebration until you next open the
  Collections tab, rather than immediately when you log the final movie.

## Everything else

Unchanged from before — see prior zips/git history for the full
changelog: Phases 1-4, Discover redesign, Upcoming section, half-star
ratings, Location (OpenStreetMap-based), Camera (local storage). Location
still has an open networking bug (deferred by user request); Camera has
unspecified "quality of life tweaks" still to be described.

## Next

Just the Location networking bug (waiting on the user's browser-test
result) and Documentation (10% of the grading rubric), deliberately
saved for last. Also sitting open, not yet confirmed by the user: a
shortlist of additional collections Claude offered (more directors/
actors/franchises) and the shark-movies "theme collection" idea — user
said hold off on shark movies for now, may not happen at all.
