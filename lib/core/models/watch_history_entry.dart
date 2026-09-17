import '../../utils/app_constants.dart';

/// A single logged movie, stored at users/{uid}/watchHistory/{movieId}.
/// Uses the TMDB movie ID as the document ID — one entry per movie,
/// overwritten on re-log — which keeps "is this logged" and "edit this
/// log" both a single doc lookup instead of a query. Logging the same
/// film for a second watch as a separate entry is a nice future
/// enhancement, not built here.
class WatchHistoryEntry {
  final int movieId;
  final String movieTitle;
  final String? moviePosterPath;
  final int? runtimeMinutes;
  final List<int> genreIds;
  final int? releaseYear;
  final double? rating; // 0.5-5.0 in 0.5 steps; null = not rated
  final String? review;
  final DateTime watchDate;
  final String? cinema;
  final String? photoPath; // local file path (Camera / Movie Memories)
  final DateTime loggedAt;

  // Snapshotted from MovieModel at log time — powers the Behind the
  // Camera / Star Power achievements. Null on entries logged before
  // this field existed.
  final int? directorId;
  final String? directorName;
  final int? leadActorId;
  final String? leadActorName;

  const WatchHistoryEntry({
    required this.movieId,
    required this.movieTitle,
    this.moviePosterPath,
    this.runtimeMinutes,
    this.genreIds = const [],
    this.releaseYear,
    this.rating,
    this.review,
    required this.watchDate,
    this.cinema,
    this.photoPath,
    required this.loggedAt,
    this.directorId,
    this.directorName,
    this.leadActorId,
    this.leadActorName,
  });

  String? get posterUrl =>
      moviePosterPath != null ? '${AppConstants.tmdbImageBaseUrl}$moviePosterPath' : null;

  factory WatchHistoryEntry.fromMap(Map<String, dynamic> map) {
    return WatchHistoryEntry(
      movieId: map['movieId'] as int,
      movieTitle: map['movieTitle'] as String? ?? 'Untitled',
      moviePosterPath: map['moviePosterPath'] as String?,
      runtimeMinutes: map['runtimeMinutes'] as int?,
      genreIds: map['genreIds'] != null ? List<int>.from(map['genreIds'] as List) : const [],
      releaseYear: map['releaseYear'] as int?,
      // num, not double: entries logged before half-star support was
      // added are stored as whole-number ints in Firestore — this reads
      // both cleanly without needing any data migration.
      rating: (map['rating'] as num?)?.toDouble(),
      review: map['review'] as String?,
      watchDate: DateTime.tryParse(map['watchDate'] as String? ?? '') ?? DateTime.now(),
      cinema: map['cinema'] as String?,
      photoPath: map['photoPath'] as String?,
      loggedAt: DateTime.tryParse(map['loggedAt'] as String? ?? '') ?? DateTime.now(),
      directorId: map['directorId'] as int?,
      directorName: map['directorName'] as String?,
      leadActorId: map['leadActorId'] as int?,
      leadActorName: map['leadActorName'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'movieId': movieId,
      'movieTitle': movieTitle,
      'moviePosterPath': moviePosterPath,
      'runtimeMinutes': runtimeMinutes,
      'genreIds': genreIds,
      'releaseYear': releaseYear,
      'rating': rating,
      'review': review,
      'watchDate': watchDate.toIso8601String(),
      'cinema': cinema,
      'photoPath': photoPath,
      'loggedAt': loggedAt.toIso8601String(),
      'directorId': directorId,
      'directorName': directorName,
      'leadActorId': leadActorId,
      'leadActorName': leadActorName,
    };
  }
}
