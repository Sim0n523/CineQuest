import 'package:flutter/foundation.dart';
import '../models/collection_progress.dart';
import '../models/watch_history_entry.dart';
import '../services/collection_service.dart';
import '../../utils/collection_config.dart';
import 'load_status.dart';

class CollectionProvider extends ChangeNotifier {
  final CollectionService _service;

  CollectionProvider({CollectionService? service}) : _service = service ?? CollectionService();

  List<CollectionProgress> collections = [];
  LoadStatus status = LoadStatus.initial;
  String? errorMessage;

  /// Fetches all curated collections in parallel — sequential would mean
  /// 5+ round trips one after another for a screen that's just meant to
  /// give a quick browse. Any collection that fails to resolve (e.g. a
  /// TMDB search returning nothing) is skipped rather than failing the
  /// whole screen.
  Future<void> loadAll(List<WatchHistoryEntry> watchHistory) async {
    status = LoadStatus.loading;
    notifyListeners();

    final loggedMovieIds = watchHistory.map((e) => e.movieId).toSet();

    final futures = collectionDefinitions.map((def) async {
      try {
        final movies = await _service.fetchMovies(def);
        final loggedCount = movies.where((m) => loggedMovieIds.contains(m.id)).length;
        return CollectionProgress(
          definition: def,
          movies: movies,
          loggedCount: loggedCount,
          isComplete: movies.isNotEmpty && loggedCount == movies.length,
        );
      } catch (_) {
        return null;
      }
    });

    try {
      final results = await Future.wait(futures);
      collections = results.whereType<CollectionProgress>().toList();
      status = LoadStatus.loaded;
    } catch (e) {
      status = LoadStatus.error;
      errorMessage = e.toString();
    }
    notifyListeners();
  }
}
