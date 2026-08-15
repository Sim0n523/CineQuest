import 'package:flutter/foundation.dart';
import '../models/quest_period_state.dart';
import '../services/quest_service.dart';
import 'load_status.dart';

class QuestProvider extends ChangeNotifier {
  final QuestService _questService;

  QuestProvider({QuestService? questService}) : _questService = questService ?? QuestService();

  QuestBundle? bundle;
  LoadStatus status = LoadStatus.initial;
  String? errorMessage;

  Future<void> load(String uid) async {
    status = LoadStatus.loading;
    notifyListeners();
    try {
      bundle = await _questService.ensureCurrentQuests(uid);
      status = LoadStatus.loaded;
    } catch (e) {
      status = LoadStatus.error;
      errorMessage = e.toString();
    }
    notifyListeners();
  }
}
