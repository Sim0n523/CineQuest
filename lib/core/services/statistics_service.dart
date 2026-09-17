import '../models/watch_history_entry.dart';
import '../../utils/genre_map.dart';

/// Computed, derived stats — no Firestore/TMDB access of its own, just
/// pure calculation over already-fetched watch history.
///
/// Deliberately not computed here yet:
/// - Favorite Director: needs TMDB's /movie/{id}/credits endpoint,
///   which nothing fetches today.
/// - Streaks: real date-boundary logic (weekly windows, timezones)
///   deserves its own careful pass rather than a rushed addition here.
class MovieStats {
  final int moviesWatched;
  final int reviewsWritten;
  final double averageRating; // 0.0 if nothing rated yet
  final int hoursWatched;
  final String? favoriteGenre;

  const MovieStats({
    required this.moviesWatched,
    required this.reviewsWritten,
    required this.averageRating,
    required this.hoursWatched,
    required this.favoriteGenre,
  });

  factory MovieStats.empty() => const MovieStats(
        moviesWatched: 0,
        reviewsWritten: 0,
        averageRating: 0,
        hoursWatched: 0,
        favoriteGenre: null,
      );
}

class StatisticsService {
  StatisticsService._();

  static MovieStats calculate(List<WatchHistoryEntry> history) {
    if (history.isEmpty) return MovieStats.empty();

    final rated = history.where((e) => e.rating != null).toList();
    final averageRating = rated.isEmpty
        ? 0.0
        : rated.map((e) => e.rating!).reduce((a, b) => a + b) / rated.length;

    final totalMinutes = history.fold<int>(0, (sum, e) => sum + (e.runtimeMinutes ?? 0));

    final genreCounts = <int, int>{};
    for (final entry in history) {
      for (final genreId in entry.genreIds) {
        genreCounts[genreId] = (genreCounts[genreId] ?? 0) + 1;
      }
    }

    String? favoriteGenre;
    if (genreCounts.isNotEmpty) {
      final topGenreId =
          genreCounts.entries.reduce((a, b) => a.value >= b.value ? a : b).key;
      favoriteGenre = tmdbGenreNames[topGenreId];
    }

    return MovieStats(
      moviesWatched: history.length,
      reviewsWritten: history.where((e) => (e.review ?? '').trim().isNotEmpty).length,
      averageRating: averageRating,
      hoursWatched: (totalMinutes / 60).round(),
      favoriteGenre: favoriteGenre,
    );
  }
}
