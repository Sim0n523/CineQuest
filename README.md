# CineQuest

A gamified movie-tracking app — level up your cinema life.

Flutter · Firebase (Auth + Firestore) · TMDB API

## 1. Overview

CineQuest is a Letterboxd-style movie diary built on top of a full
game-progression layer: every logged movie earns XP, contributes to
Achievements, Quests, and Collections, and feeds a global Leaderboard.
The core design goal is that every movie logged should feel rewarding.

**Tech stack**
- Framework: Flutter (Dart SDK ≥ 3.9)
- State management: Provider (ChangeNotifier)
- Backend: Firebase Authentication (email/password) + Cloud Firestore
- External data: The Movie Database (TMDB) REST API
- Maps/Location: OpenStreetMap via flutter_map + the Overpass API,
  geolocator for device position
- Camera: the `camera` package (custom live-preview capture), with an
  `image_picker` gallery alternative

OpenStreetMap and on-device/Base64 photo storage were chosen
specifically to avoid any Firebase billing ("Blaze plan") requirement —
both Google Maps and Firebase Storage need a linked payment method even
at zero usage.

## 2. Architecture

```
lib/
  core/
    models/        plain Dart data classes
    services/       the ONLY layer allowed to touch Firebase/TMDB/external APIs
    repositories/   a thin layer between services and providers
    providers/      one ChangeNotifier per feature area
  screens/          one file per screen
  widgets/          reusable UI components
  themes/           colors, text styles, shadows, the app ThemeData
  utils/            config/constants (achievements, quests, collections, routes, etc.)
```

**Services** — each owns exactly one external concern:

| Service | Owns |
|---|---|
| AuthService | Firebase Auth + the user's Firestore profile document |
| MovieService | Firestore watch history and watchlist reads/writes |
| TMDBService | the only place that calls the TMDB API directly |
| ProgressionService | the single authority that awards XP, levels, unlocks achievements, completes quests/collections |
| AchievementService | pure computation over watch history, no I/O |
| QuestService | quest selection/completion, Firestore I/O + computation |
| StatisticsService | pure computation of profile stats |
| LeaderboardService | live Firestore query + rank aggregation |
| CollectionService | resolves each collection by name at runtime via TMDB, never hardcoded IDs |
| LocationService | Overpass API queries for nearby cinemas, with multi-mirror fallback |
| LocalPhotoService | on-device storage for movie photos |
| FriendService | friend requests and username search |

**State management** — seven app-wide providers registered above the
navigator in `main.dart`: `AuthProvider`, `MovieProvider`,
`WatchHistoryProvider`, `LeaderboardProvider` (a live listener, not a
one-shot fetch), `QuestProvider`, `CollectionProvider`, `FriendProvider`
(also a live listener, started at login). A shared `LoadStatus` enum
(idle/loading/loaded/error) is used consistently across all of them.

**Data flow for a movie log** — `LogMovieScreen` collects
rating/review/date/cinema/photo → `MovieService` writes the entry to
Firestore → `ProgressionService.processMovieLogged()` computes XP
gained, any level-up, newly unlocked achievements, and newly completed
quests, returning one `ProgressionResult` → `RewardDialog` displays the
outcome. XP is only ever awarded on a brand-new log, never an edit.

## 3. Feature Coverage by Rubric Criterion

| Criterion | Weight | Where it's implemented |
|---|---|---|
| State management | 15% | Provider / ChangeNotifier across 7 app-wide providers |
| Authentication | 10% | Firebase Auth, email + password, session-aware navigation |
| Custom UI elements | 5% | XPBar, LevelBadge, StarRating, MovieCard, reward dialogs, skeleton loaders, custom theme + shadows |
| Web services | 5% | TMDB REST API (TMDBService) — trending, search, discover, collections, credits |
| Location services | 5% | OpenStreetMap via flutter_map + Overpass API + geolocator (NearbyCinemasScreen) |
| Camera services | 5% | camera package live-preview capture + gallery fallback (CameraCaptureScreen) |
| Data handling | 15% | Cloud Firestore (per-user documents/subcollections) + on-device photo storage |
| Navigation | 10% | Named routes, 5-tab IndexedStack bottom nav, custom page transitions |
| More than 7 screens | 10% | 24 screens (see Screen Inventory) |
| Innovation aspect | 10% | Full gamification layer: XP/Levels, Achievements, Quests, Leaderboard, Collections, Friends |
| Documentation | 10% |  this README |

### 3.1 Innovation — the gamification layer

- **XP & Levels** — uncapped, formula-based level curve; from level 6
  onward each level costs progressively more XP.
- **Achievements** — 15 categories × 6 tiers each, computed live from
  watch history.
- **Quests** — a rotating pool of weekly (resets Monday) and monthly
  (resets on the 1st) objectives, based on when a movie was logged, not
  its watch date.
- **Leaderboard** — a live, real-time global XP ranking.
- **Collections** — 31 curated franchises/studios/directors/actors,
  resolved by name against TMDB at runtime, each with its own
  completion bonus.
- **Friends & Public Profiles** — username search, friend requests, and
  a read-only public profile view of any other user.

## 4. Screen Inventory

24 screens, comfortably exceeding the minimum of 7:

SplashScreen, LoginScreen, RegisterScreen, MainNavigationScreen,
HomeScreen, DiscoverScreen, SearchScreen, MovieDetailsScreen,
LogMovieScreen, WatchHistoryScreen, WatchlistScreen,
CameraCaptureScreen, PhotoViewerScreen, QuestsScreen,
AchievementsScreen, CollectionsScreen, CollectionDetailScreen,
LeaderboardScreen, ProfileScreen, EditFavoritesScreen,
PublicProfileScreen, FindFriendsScreen, FriendsListScreen,
NearbyCinemasScreen.

See the docx for a one-line purpose next to each.

## 5. Data Model

**Cloud Firestore**

```
users/{uid}
  — profile fields: username, usernameLower, avatarBase64, favoriteMovies,
    xp, level, collectionsCompleted
  watchHistory/{movieId}      one doc per logged movie (movie id = doc id)
  watchlist/{movieId}         one doc per saved movie
  achievements/{categoryName} unlockedTier
  quests/{weekly|monthly}     selected quest set + completion state
  collections/{collectionId}  completed (bool)

friendships/{friendshipId}    top-level collection; id = both uids, sorted
                               and joined, so exactly one doc can exist per pair
```

**On-device storage** — movie photos live at
`movie_photos/{movieId}.jpg` in the app's local documents directory,
not a cloud bucket, since a photo only needs to be visible to its own
owner.

**Avatars** — need to be visible to other users, so they're downsized
(~240px), compressed via `dart:ui`, and stored as a Base64 string
directly on the user's Firestore document (well within the 1MB
document limit at this size).

## 6. Navigation

Auth-adjacent navigation (Splash → Login/Register → Main) uses named
routes with `pushNamedAndRemoveUntil`, fully clearing the stack on
every sign-in/sign-out. The main app uses a 5-tab bottom nav built on
`IndexedStack`, keeping each tab's state alive when switching. A custom
`PageTransitionsBuilder` (fade + upward drift) is wired into
`ThemeData.pageTransitionsTheme` for consistent transitions app-wide.
Movie posters Hero-animate into Movie Details wherever a given movie
can only appear on screen once at a time — deliberately not used on
Home, where Trending/Popular can legitimately show the same movie
twice at once.

## 7. Known Limitations & Deliberate Scope Decisions

- **No billing services used, by design.** OpenStreetMap/Overpass
  replaces Google Maps; on-device/Base64 storage replaces Firebase
  Storage.
- **Collection completion is detected on screen view**, not the instant
  the final movie is logged — checking on every log would mean several
  extra TMDB calls per log.
- **Studio/director/actor collections resolve via TMDB at runtime**,
  not hand-curated ID lists, trading a small runtime dependency for
  never showing the wrong movies from a stale ID.
- **Location lookups use sequential mirror fallback** (worst case
  ~30s), not a concurrent "race all mirrors" pattern — the simpler
  approach is proven working; a concurrent rewrite was deferred as
  higher-risk for a marginal further speed gain.
- **Co-directed films only attribute the first director found** for the
  Director/Actor achievements — a diversity-of-viewing stat, not a
  full filmography record.

## 8. Setup & Running the Project

1. Create a Firebase project with Authentication (email/password) and
   Firestore enabled.
2. Copy `lib/utils/app_secrets.example.dart` to `lib/utils/app_secrets.dart`
   (gitignored) and put your TMDB API key in it.
3. Deploy `firestore.rules` (Firestore → Rules in the Firebase console).
4. `flutter pub get`
5. `flutter run`

**One-time steps after pulling this version** — both are config-only in
this repo; actually generating the platform files needs the Flutter
toolchain, so run these once locally and then do a full restart (not
hot reload):

```
dart run flutter_launcher_icons      # app icon, from assets/icon/icon.png
dart run flutter_native_splash:create # native splash, navy background + same icon
```

