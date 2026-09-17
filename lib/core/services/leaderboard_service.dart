import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/leaderboard_entry.dart';

/// Global XP ranking. Reads directly from the users collection —
/// Firestore rules already allow any signed-in user to read any user
/// document, so this needs no rules change of its own.
class LeaderboardService {
  final FirebaseFirestore _firestore;

  LeaderboardService({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  Future<List<LeaderboardEntry>> fetchTopUsers({int limit = 50}) async {
    final snapshot = await _firestore
        .collection('users')
        .orderBy('xp', descending: true)
        .limit(limit)
        .get();

    return [
      for (var i = 0; i < snapshot.docs.length; i++)
        LeaderboardEntry.fromMap(snapshot.docs[i].id, snapshot.docs[i].data(), rank: i + 1),
    ];
  }

  /// Live version of [fetchTopUsers] — emits a fresh ranking whenever any
  /// user's `xp` changes, instead of requiring the screen to be reopened
  /// to see the update.
  Stream<List<LeaderboardEntry>> watchTopUsers({int limit = 50}) {
    return _firestore
        .collection('users')
        .orderBy('xp', descending: true)
        .limit(limit)
        .snapshots()
        .map((snapshot) => [
              for (var i = 0; i < snapshot.docs.length; i++)
                LeaderboardEntry.fromMap(snapshot.docs[i].id, snapshot.docs[i].data(), rank: i + 1),
            ]);
  }

  /// Exact rank via a count aggregation, so a user outside the visible
  /// top N doesn't require fetching the entire user base just to find
  /// out where they stand.
  Future<int> fetchRankFor(String uid, int xp) async {
    final aggregate =
        await _firestore.collection('users').where('xp', isGreaterThan: xp).count().get();
    return (aggregate.count ?? 0) + 1;
  }
}
