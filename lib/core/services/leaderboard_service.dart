import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/leaderboard_entry.dart';

/// Global XP ranking, per blueprint section 18. Reads directly from the
/// users collection — Phase 1's Firestore rules already allow any
/// signed-in user to read any user document, specifically so this
/// wouldn't need a rules change later.
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

  /// Exact rank via a count aggregation, so a user outside the visible
  /// top N doesn't require fetching the entire user base just to find
  /// out where they stand.
  Future<int> fetchRankFor(String uid, int xp) async {
    final aggregate =
        await _firestore.collection('users').where('xp', isGreaterThan: xp).count().get();
    return (aggregate.count ?? 0) + 1;
  }
}
