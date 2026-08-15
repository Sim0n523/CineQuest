import '../../utils/quest_config.dart';

class ActiveQuest {
  final String templateId;
  final bool completed;

  const ActiveQuest({required this.templateId, required this.completed});
}

/// The 3 quest templates selected for the current week or month, plus
/// which ones are already completed. Stored at
/// users/{uid}/quests/{weekly|monthly} — one doc per period type,
/// overwritten (not accumulated) whenever the period rolls over.
class QuestPeriodState {
  final String periodKey;
  final QuestPeriodType type;
  final List<ActiveQuest> quests;

  const QuestPeriodState({required this.periodKey, required this.type, required this.quests});

  factory QuestPeriodState.fromMap(Map<String, dynamic> map, QuestPeriodType type) {
    final questsData = map['quests'] as Map<String, dynamic>? ?? {};
    return QuestPeriodState(
      periodKey: map['periodKey'] as String? ?? '',
      type: type,
      quests: questsData.entries.map((entry) {
        final value = entry.value as Map<String, dynamic>? ?? {};
        return ActiveQuest(templateId: entry.key, completed: value['completed'] as bool? ?? false);
      }).toList(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'periodKey': periodKey,
      'quests': {
        for (final q in quests) q.templateId: {'completed': q.completed},
      },
    };
  }
}

class QuestBundle {
  final QuestPeriodState weekly;
  final QuestPeriodState monthly;

  const QuestBundle({required this.weekly, required this.monthly});
}
