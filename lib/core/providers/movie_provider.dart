import 'package:flutter/foundation.dart';
import '../models/movie_model.dart';
import '../repositories/movie_repository.dart';
import '../../utils/discover_sort.dart';
import 'load_status.dart';

class MovieProvider extends ChangeNotifier {
  final MovieRepository _repository;

  MovieProvider({MovieRepository? repository})
      : _repository = repository ?? MovieRepository();

  List<MovieModel> trending = [];
  List<MovieModel> popular = [];
  List<MovieModel> searchResults = [];
  List<MovieModel> discoverResults = [];

  LoadStatus trendingStatus = LoadStatus.initial;
  LoadStatus popularStatus = LoadStatus.initial;
  LoadStatus searchStatus = LoadStatus.initial;
  LoadStatus discoverStatus = LoadStatus.initial;
  String? errorMessage;

  Future<void> loadHome() async {
    trendingStatus = LoadStatus.loading;
    popularStatus = LoadStatus.loading;
    notifyListeners();

    try {
      final results = await Future.wait([
        _repository.fetchTrending(),
        _repository.fetchPopular(),
      ]);
      trending = results[0];
      popular = results[1];
      trendingStatus = LoadStatus.loaded;
      popularStatus = LoadStatus.loaded;
    } catch (e) {
      trendingStatus = LoadStatus.error;
      popularStatus = LoadStatus.error;
      errorMessage = e.toString();
    }
    notifyListeners();
  }

  Future<void> search(String query) async {
    if (query.trim().isEmpty) {
      searchResults = [];
      searchStatus = LoadStatus.initial;
      notifyListeners();
      return;
    }

    searchStatus = LoadStatus.loading;
    notifyListeners();
    try {
      searchResults = await _repository.search(query);
      searchStatus = LoadStatus.loaded;
    } catch (e) {
      searchStatus = LoadStatus.error;
      errorMessage = e.toString();
    }
    notifyListeners();
  }

  /// Called whenever Discover's genre or sort selection changes — the
  /// screen owns which filter is currently selected and passes the full
  /// desired state each time, rather than this provider tracking it.
  Future<void> loadDiscover({required int? genreId, required DiscoverSort sort}) async {
    discoverStatus = LoadStatus.loading;
    notifyListeners();
    try {
      discoverResults = await _repository.discover(genreId: genreId, sort: sort);
      discoverStatus = LoadStatus.loaded;
    } catch (e) {
      discoverStatus = LoadStatus.error;
      errorMessage = e.toString();
    }
    notifyListeners();
  }

  Future<MovieModel> fetchMovieDetails(int movieId) {
    return _repository.fetchDetails(movieId);
  }
}
