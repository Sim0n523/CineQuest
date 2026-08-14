import '../models/movie_model.dart';
import '../services/tmdb_service.dart';
import '../../utils/discover_sort.dart';

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

  Future<List<MovieModel>> discover({int? genreId, DiscoverSort sort = DiscoverSort.popular}) =>
      _tmdbService.discoverMovies(genreId: genreId, sortBy: sort.apiValue);
}
