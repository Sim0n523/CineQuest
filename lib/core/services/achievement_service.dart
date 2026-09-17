import '../models/watch_history_entry.dart';
import '../../utils/achievement_config.dart';

/// Pure computation, same spirit as StatisticsService — no Firestore
/// access of its own, just deriving progress from already-fetched
/// watch history. This means the Achievements screen can compute
/// current tiers live without an extra fetch; ProgressionService uses
/// the same functions when deciding what just got unlocked.
///
/// collectionsCompleted is the one exception to "purely from history" —
/// it's a count that lives on UserModel, not WatchHistoryEntry, so it's
/// passed in rather than derived. Defaults to 0 so existing call sites
/// that don't care about that category don't need updating.
class AchievementService {
  AchievementService._();

  static int currentValueFor(
    AchievementCategory category,
    List<WatchHistoryEntry> history, {
    int collectionsCompleted = 0,
  }) {
    switch (category) {
      case AchievementCategory.moviesWatched:
        return history.length;
      case AchievementCategory.reviewsWritten:
        return history.where((e) => (e.review ?? '').trim().isNotEmpty).length;
      case AchievementCategory.genresExplored:
        return history.expand((e) => e.genreIds).toSet().length;
      case AchievementCategory.hoursWatched:
        final totalMinutes = history.fold<int>(0, (sum, e) => sum + (e.runtimeMinutes ?? 0));
        return totalMinutes ~/ 60;
      case AchievementCategory.cinemaVisits:
        return history.where((e) => (e.cinema ?? '').trim().isNotEmpty).length;
      case AchievementCategory.decadesWatched:
        return history
            .where((e) => e.releaseYear != null)
            .map((e) => e.releaseYear! ~/ 10)
            .toSet()
            .length;
      case AchievementCategory.fiveStarRatings:
        return history.where((e) => (e.rating ?? 0) >= 5).length;
      case AchievementCategory.directorsExplored:
        return history.where((e) => e.directorId != null).map((e) => e.directorId).toSet().length;
      case AchievementCategory.actorsExplored:
        return history.where((e) => e.leadActorId != null).map((e) => e.leadActorId).toSet().length;
      case AchievementCategory.collectionsCompleted:
        return collectionsCompleted;
      case AchievementCategory.moviesWithPhotos:
        return history.where((e) => (e.photoPath ?? '').trim().isNotEmpty).length;
      case AchievementCategory.longMovies:
        return history.where((e) => (e.runtimeMinutes ?? 0) >= 150).length;
      case AchievementCategory.classicMovies:
        return history.where((e) => e.releaseYear != null && e.releaseYear! < 1980).length;
      case AchievementCategory.weekendWatches:
        return history
            .where((e) => e.watchDate.weekday == DateTime.saturday || e.watchDate.weekday == DateTime.sunday)
            .length;
      case AchievementCategory.genreDevotion:
        final genreCounts = <int, int>{};
        for (final entry in history) {
          for (final genreId in entry.genreIds) {
            genreCounts[genreId] = (genreCounts[genreId] ?? 0) + 1;
          }
        }
        return genreCounts.values.isEmpty ? 0 : genreCounts.values.reduce((a, b) => a > b ? a : b);
    }
  }

  /// 0 = no tier unlocked yet. Same threshold-scanning pattern
  /// LevelConfig.levelForXp used to use (before it switched to a
  /// formula) — tiers are still a small fixed array, so this stays.
  static int tierForValue(AchievementDefinition definition, int value) {
    int tier = 0;
    for (int i = 0; i < definition.tierThresholds.length; i++) {
      if (value >= definition.tierThresholds[i]) {
        tier = i + 1;
      } else {
        break;
      }
    }
    return tier;
  }
}
