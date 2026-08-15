import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/quest_period_state.dart';
import '../models/watch_history_entry.dart';
import '../../utils/quest_config.dart';

/// Unlike AchievementService (pure computation only), QuestService also
/// owns Firestore I/O for the quest period docs — matching blueprint
/// section 7's separate "QuestService" entry, and because "fetch or
/// generate a fresh set if the period rolled over" genuinely needs a
/// read (and sometimes a write) that pure computation can't do alone.
class QuestService {
  final FirebaseFirestore _firestore;

  QuestService({FirebaseFirestore? firestore}) : _firestore = firestore ?? FirebaseFirestore.instance;

  /// Fetches the current period's quest set, or generates a fresh
  /// random one (3 templates from the pool) if none exists yet or the
  /// stored period has rolled over. Safe to call anytime — e.g. just
  /// opening the Quests tab, independent of logging a movie.
  Future<QuestPeriodState> ensurePeriod(String uid, QuestPeriodType type) async {
    final pool = type == QuestPeriodType.weekly ? weeklyQuestPool : monthlyQuestPool;
    final currentKey = type == QuestPeriodType.weekly
        ? QuestPeriodUtils.weeklyKey(DateTime.now())
        : QuestPeriodUtils.monthlyKey(DateTime.now());

    final docRef = _firestore.collection('users').doc(uid).collection('quests').doc(type.name);
    final doc = await docRef.get();

    if (doc.exists && doc.data()?['periodKey'] == currentKey) {
      return QuestPeriodState.fromMap(doc.data()!, type);
    }

    final shuffled = List<QuestTemplate>.from(pool)..shuffle();
    final selected = shuffled.take(3).toList();
    final state = QuestPeriodState(
      periodKey: currentKey,
      type: type,
      quests: selected.map((t) => ActiveQuest(templateId: t.id, completed: false)).toList(),
    );
    await docRef.set(state.toMap());
    return state;
  }

  Future<QuestBundle> ensureCurrentQuests(String uid) async {
    final weekly = await ensurePeriod(uid, QuestPeriodType.weekly);
    final monthly = await ensurePeriod(uid, QuestPeriodType.monthly);
    return QuestBundle(weekly: weekly, monthly: monthly);
  }

  Future<void> markCompleted(String uid, QuestPeriodType type, String templateId) {
    return _firestore
        .collection('users')
        .doc(uid)
        .collection('quests')
        .doc(type.name)
        .update({'quests.$templateId.completed': true});
  }

  static DateTime periodStartFor(QuestPeriodType type) {
    return type == QuestPeriodType.weekly
        ? QuestPeriodUtils.startOfWeek(DateTime.now())
        : QuestPeriodUtils.startOfMonth(DateTime.now());
  }

  /// Filters to entries logged (not watched) within the period —
  /// deliberately loggedAt, not watchDate, since watchDate can be
  /// freely backdated when logging a movie and using it here would let
  /// someone "complete" a quest with an old backdated log.
  static List<WatchHistoryEntry> entriesInPeriod(
    List<WatchHistoryEntry> history,
    DateTime periodStart,
  ) {
    return history.where((e) => !e.loggedAt.isBefore(periodStart)).toList();
  }

  static int progressFor(QuestTemplate template, List<WatchHistoryEntry> periodEntries) {
    switch (template.metric) {
      case QuestMetric.moviesWatched:
        return periodEntries.length;
      case QuestMetric.reviewsWritten:
        return periodEntries.where((e) => (e.review ?? '').trim().isNotEmpty).length;
      case QuestMetric.genreCount:
        return periodEntries.where((e) => e.genreIds.contains(template.genreId)).length;
      case QuestMetric.distinctGenres:
        return periodEntries.expand((e) => e.genreIds).toSet().length;
      case QuestMetric.releasedBefore:
        return periodEntries
            .where((e) => e.releaseYear != null && e.releaseYear! < template.beforeYear!)
            .length;
      case QuestMetric.hoursWatched:
        final minutes = periodEntries.fold<int>(0, (sum, e) => sum + (e.runtimeMinutes ?? 0));
        return minutes ~/ 60;
    }
  }
}
