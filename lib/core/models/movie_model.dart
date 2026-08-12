import '../../utils/app_constants.dart';

/// A movie as returned by TMDB. Covers the fields shared by the
/// trending/popular/search endpoints and the single-movie details
/// endpoint (which additionally includes `runtime` and `genres` instead
/// of `genre_ids`).
class MovieModel {
  final int id;
  final String title;
  final String? posterPath;
  final String? backdropPath;
  final String overview;
  final double voteAverage;
  final DateTime? releaseDate;
  final List<int> genreIds;
  final int? runtime; // minutes; only present from the details endpoint

  const MovieModel({
    required this.id,
    required this.title,
    this.posterPath,
    this.backdropPath,
    this.overview = '',
    this.voteAverage = 0.0,
    this.releaseDate,
    this.genreIds = const [],
    this.runtime,
  });

  String? get posterUrl =>
      posterPath != null ? '${AppConstants.tmdbImageBaseUrl}$posterPath' : null;

  String? get backdropUrl => backdropPath != null
      ? '${AppConstants.tmdbBackdropBaseUrl}$backdropPath'
      : null;

  factory MovieModel.fromJson(Map<String, dynamic> json) {
    return MovieModel(
      id: json['id'] as int,
      title: (json['title'] ?? json['original_title'] ?? 'Untitled') as String,
      posterPath: json['poster_path'] as String?,
      backdropPath: json['backdrop_path'] as String?,
      overview: json['overview'] as String? ?? '',
      voteAverage: (json['vote_average'] as num?)?.toDouble() ?? 0.0,
      releaseDate: (json['release_date'] as String?)?.isNotEmpty == true
          ? DateTime.tryParse(json['release_date'] as String)
          : null,
      genreIds: json['genre_ids'] != null
          ? List<int>.from(json['genre_ids'] as List)
          : (json['genres'] != null
              ? List<int>.from(
                  (json['genres'] as List).map((g) => g['id'] as int))
              : const []),
      runtime: json['runtime'] as int?,
    );
  }
}
