import 'package:flutter/foundation.dart';
import '../models/movie_model.dart';
import '../repositories/movie_repository.dart';

enum LoadStatus { initial, loading, loaded, error }

class MovieProvider extends ChangeNotifier {
  final MovieRepository _repository;

  MovieProvider({MovieRepository? repository})
      : _repository = repository ?? MovieRepository();

  List<MovieModel> trending = [];
  List<MovieModel> popular = [];
  List<MovieModel> searchResults = [];

  LoadStatus trendingStatus = LoadStatus.initial;
  LoadStatus popularStatus = LoadStatus.initial;
  LoadStatus searchStatus = LoadStatus.initial;
  String? errorMessage;

  /// Loads both home rows in parallel. Safe to call repeatedly (e.g. on
  /// pull-to-refresh) — each call simply replaces the previous results.
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

  Future<MovieModel> fetchMovieDetails(int movieId) {
    return _repository.fetchDetails(movieId);
  }
}
