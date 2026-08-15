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

  Future<void> load({required String currentUid, required int currentXp}) async {
    status = LoadStatus.loading;
    notifyListeners();
    try {
      topUsers = await _service.fetchTopUsers();
      final inTopList = topUsers.any((e) => e.uid == currentUid);
      currentUserRank = inTopList ? null : await _service.fetchRankFor(currentUid, currentXp);
      status = LoadStatus.loaded;
    } catch (e) {
      status = LoadStatus.error;
      errorMessage = e.toString();
    }
    notifyListeners();
  }
}
