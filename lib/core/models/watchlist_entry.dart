import '../../utils/app_constants.dart';

/// An unwatched movie the user has saved, stored at
/// users/{uid}/watchlist/{movieId}. Removed automatically when the same
/// movie gets logged (see MovieService.logMovie).
class WatchlistEntry {
  final int movieId;
  final String movieTitle;
  final String? moviePosterPath;
  final DateTime addedAt;

  const WatchlistEntry({
    required this.movieId,
    required this.movieTitle,
    this.moviePosterPath,
    required this.addedAt,
  });

  String? get posterUrl =>
      moviePosterPath != null ? '${AppConstants.tmdbImageBaseUrl}$moviePosterPath' : null;

  factory WatchlistEntry.fromMap(Map<String, dynamic> map) {
    return WatchlistEntry(
      movieId: map['movieId'] as int,
      movieTitle: map['movieTitle'] as String? ?? 'Untitled',
      moviePosterPath: map['moviePosterPath'] as String?,
      addedAt: DateTime.tryParse(map['addedAt'] as String? ?? '') ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'movieId': movieId,
      'movieTitle': movieTitle,
      'moviePosterPath': moviePosterPath,
      'addedAt': addedAt.toIso8601String(),
    };
  }
}
