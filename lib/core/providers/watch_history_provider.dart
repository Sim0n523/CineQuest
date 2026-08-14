import 'package:flutter/foundation.dart';
import '../models/watch_history_entry.dart';
import '../models/watchlist_entry.dart';
import '../models/movie_model.dart';
import '../services/movie_service.dart';
import '../services/statistics_service.dart';
import 'load_status.dart';

class WatchHistoryProvider extends ChangeNotifier {
  final MovieService _movieService;

  WatchHistoryProvider({MovieService? movieService})
      : _movieService = movieService ?? MovieService();

  List<WatchHistoryEntry> watchHistory = [];
  List<WatchlistEntry> watchlist = [];
  LoadStatus historyStatus = LoadStatus.initial;
  LoadStatus watchlistStatus = LoadStatus.initial;
  String? errorMessage;

  MovieStats get stats => StatisticsService.calculate(watchHistory);

  Future<void> loadAll(String uid) async {
    historyStatus = LoadStatus.loading;
    watchlistStatus = LoadStatus.loading;
    notifyListeners();

    final historyFuture = _movieService.fetchWatchHistory(uid);
    final watchlistFuture = _movieService.fetchWatchlist(uid);

    try {
      watchHistory = await historyFuture;
      historyStatus = LoadStatus.loaded;
    } catch (e) {
      historyStatus = LoadStatus.error;
      errorMessage = e.toString();
    }

    try {
      watchlist = await watchlistFuture;
      watchlistStatus = LoadStatus.loaded;
    } catch (e) {
      watchlistStatus = LoadStatus.error;
      errorMessage = e.toString();
    }

    notifyListeners();
  }

  WatchHistoryEntry? entryForMovie(int movieId) {
    for (final entry in watchHistory) {
      if (entry.movieId == movieId) return entry;
    }
    return null;
  }

  bool isLogged(int movieId) => entryForMovie(movieId) != null;

  bool isOnWatchlist(int movieId) => watchlist.any((e) => e.movieId == movieId);

  Future<bool> logMovie(String uid, WatchHistoryEntry entry) async {
    try {
      await _movieService.logMovie(uid, entry);
      watchHistory.removeWhere((e) => e.movieId == entry.movieId);
      watchHistory.insert(0, entry);
      watchlist.removeWhere((e) => e.movieId == entry.movieId);
      notifyListeners();
      return true;
    } catch (e) {
      errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteLogEntry(String uid, int movieId) async {
    try {
      await _movieService.deleteLogEntry(uid, movieId);
      watchHistory.removeWhere((e) => e.movieId == movieId);
      notifyListeners();
      return true;
    } catch (e) {
      errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> addToWatchlist(String uid, MovieModel movie) async {
    final entry = WatchlistEntry(
      movieId: movie.id,
      movieTitle: movie.title,
      moviePosterPath: movie.posterPath,
      addedAt: DateTime.now(),
    );
    try {
      await _movieService.addToWatchlist(uid, entry);
      watchlist.removeWhere((e) => e.movieId == movie.id);
      watchlist.insert(0, entry);
      notifyListeners();
      return true;
    } catch (e) {
      errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> removeFromWatchlist(String uid, int movieId) async {
    try {
      await _movieService.removeFromWatchlist(uid, movieId);
      watchlist.removeWhere((e) => e.movieId == movieId);
      notifyListeners();
      return true;
    } catch (e) {
      errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }
}
