import '../models/watch_history_entry.dart';
import '../../utils/achievement_config.dart';

/// Pure computation, same spirit as StatisticsService — no Firestore
/// access of its own, just deriving progress from already-fetched
/// watch history. This means the Achievements screen can compute
/// current tiers live without an extra fetch; ProgressionService uses
/// the same functions when deciding what just got unlocked.
class AchievementService {
  AchievementService._();

  static int currentValueFor(AchievementCategory category, List<WatchHistoryEntry> history) {
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
    }
  }

  /// 0 = no tier unlocked yet. Same threshold-scanning pattern as
  /// LevelConfig.levelForXp, for consistency across the codebase.
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
