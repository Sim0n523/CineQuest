import 'dart:async';
import 'package:flutter/foundation.dart';
import '../models/leaderboard_entry.dart';
import '../services/leaderboard_service.dart';
import 'load_status.dart';

class LeaderboardProvider extends ChangeNotifier {
  final LeaderboardService _service;

  LeaderboardProvider({LeaderboardService? service}) : _service = service ?? LeaderboardService();

  List<LeaderboardEntry> topUsers = [];
  int? currentUserRank; // only set when the current user isn't in topUsers
  LoadStatus status = LoadStatus.initial;
  String? errorMessage;

  StreamSubscription<List<LeaderboardEntry>>? _subscription;
  String? _currentUid;
  int _currentXp = 0;

  /// Subscribes to live leaderboard updates via Firestore's snapshot
  /// listener, so the ranking refreshes as soon as anyone's XP changes
  /// instead of only when this screen happens to be (re)opened. Safe to
  /// call more than once — a new call just replaces the old listener.
  void listen({required String currentUid, required int currentXp}) {
    _currentUid = currentUid;
    _currentXp = currentXp;
    status = LoadStatus.loading;
    notifyListeners();

    _subscription?.cancel();
    _subscription = _service.watchTopUsers().listen(
      (users) async {
        topUsers = users;
        status = LoadStatus.loaded;
        final inTopList = users.any((e) => e.uid == _currentUid);
        if (inTopList) {
          currentUserRank = null;
          notifyListeners();
          return;
        }
        // Show the refreshed top list immediately; the exact
        // out-of-list rank is a separate query and can lag a beat
        // behind without it feeling stale.
        notifyListeners();
        try {
          currentUserRank = await _service.fetchRankFor(_currentUid!, _currentXp);
          notifyListeners();
        } catch (_) {
          // Leave whatever rank was already showing rather than
          // clearing it over a transient failure.
        }
      },
      onError: (e) {
        status = LoadStatus.error;
        errorMessage = e.toString();
        notifyListeners();
      },
    );
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}
