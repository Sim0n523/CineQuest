import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/watch_history_entry.dart';
import '../models/watchlist_entry.dart';

/// Firestore access for the user's own watch history and watchlist —
/// distinct from TMDBService, which only ever talks to TMDB's external
/// catalog.
class MovieService {
  final FirebaseFirestore _firestore;

  MovieService({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> _historyRef(String uid) =>
      _firestore.collection('users').doc(uid).collection('watchHistory');

  CollectionReference<Map<String, dynamic>> _watchlistRef(String uid) =>
      _firestore.collection('users').doc(uid).collection('watchlist');

  Future<List<WatchHistoryEntry>> fetchWatchHistory(String uid) async {
    final snapshot = await _historyRef(uid).orderBy('watchDate', descending: true).get();
    return snapshot.docs.map((d) => WatchHistoryEntry.fromMap(d.data())).toList();
  }

  Future<List<WatchlistEntry>> fetchWatchlist(String uid) async {
    final snapshot = await _watchlistRef(uid).orderBy('addedAt', descending: true).get();
    return snapshot.docs.map((d) => WatchlistEntry.fromMap(d.data())).toList();
  }

  /// Writes (or overwrites) the log entry, and clears the movie from the
  /// watchlist if it's there — you're done wanting to watch it.
  Future<void> logMovie(String uid, WatchHistoryEntry entry) async {
    await _historyRef(uid).doc('${entry.movieId}').set(entry.toMap());
    await _watchlistRef(uid).doc('${entry.movieId}').delete();
  }

  Future<void> deleteLogEntry(String uid, int movieId) {
    return _historyRef(uid).doc('$movieId').delete();
  }

  Future<void> addToWatchlist(String uid, WatchlistEntry entry) {
    return _watchlistRef(uid).doc('${entry.movieId}').set(entry.toMap());
  }

  Future<void> removeFromWatchlist(String uid, int movieId) {
    return _watchlistRef(uid).doc('$movieId').delete();
  }
}
