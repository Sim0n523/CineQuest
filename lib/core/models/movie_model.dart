import '../../utils/app_constants.dart';

class MovieModel {
  final int id;
  final String title;
  final String? posterPath;
  final String? backdropPath;
  final String overview;
  final double voteAverage;
  final DateTime? releaseDate;
  final List<int> genreIds;
  final int? runtime;

  // Only populated when fetched via TMDBService.getMovieDetails (which
  // requests append_to_response=credits) — never present on list/search
  // results. A movie can have multiple directors (e.g. the Coen
  // brothers); this deliberately keeps just the first crew entry with
  // job == "Director" rather than a list, since it's feeding a "how
  // many different directors have you watched" achievement stat, not
  // anything that needs full accuracy for co-directed films.
  final int? directorId;
  final String? directorName;
  final int? leadActorId;
  final String? leadActorName;

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
    this.directorId,
    this.directorName,
    this.leadActorId,
    this.leadActorName,
  });

  String? get posterUrl =>
      posterPath != null ? '${AppConstants.tmdbImageBaseUrl}$posterPath' : null;

  String? get backdropUrl => backdropPath != null
      ? '${AppConstants.tmdbBackdropBaseUrl}$backdropPath'
      : null;

  factory MovieModel.fromJson(Map<String, dynamic> json) {
    final credits = json['credits'] as Map<String, dynamic>?;

    Map<String, dynamic>? directorCredit;
    final crew = credits?['crew'] as List?;
    if (crew != null) {
      for (final entry in crew) {
        final c = entry as Map<String, dynamic>;
        if (c['job'] == 'Director') {
          directorCredit = c;
          break;
        }
      }
    }

    final cast = credits?['cast'] as List?;
    final leadCastCredit =
        (cast != null && cast.isNotEmpty) ? cast.first as Map<String, dynamic> : null;

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
      directorId: directorCredit?['id'] as int?,
      directorName: directorCredit?['name'] as String?,
      leadActorId: leadCastCredit?['id'] as int?,
      leadActorName: leadCastCredit?['name'] as String?,
    );
  }
}
