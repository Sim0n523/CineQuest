import '../models/movie_model.dart';
import '../services/tmdb_service.dart';

/// Thin layer over TMDBService. Today it just forwards calls, but it's
/// the seam where local caching (a Firestore "recently viewed" cache,
/// offline support, combining TMDB with our own Firestore data) gets
/// added later without touching providers or screens.
class MovieRepository {
  final TMDBService _tmdbService;

  MovieRepository({TMDBService? tmdbService})
      : _tmdbService = tmdbService ?? TMDBService();

  Future<List<MovieModel>> fetchTrending() => _tmdbService.getTrending();

  Future<List<MovieModel>> fetchPopular({int page = 1}) =>
      _tmdbService.getPopular(page: page);

  Future<List<MovieModel>> search(String query, {int page = 1}) =>
      _tmdbService.searchMovies(query, page: page);

  Future<MovieModel> fetchDetails(int movieId) =>
      _tmdbService.getMovieDetails(movieId);
}
