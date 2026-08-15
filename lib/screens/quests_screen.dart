import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/providers/auth_provider.dart';
import '../core/providers/quest_provider.dart';
import '../core/providers/watch_history_provider.dart';
import '../core/providers/load_status.dart';
import '../core/models/watch_history_entry.dart';
import '../core/models/quest_period_state.dart';
import '../core/services/quest_service.dart';
import '../themes/app_colors.dart';
import '../themes/app_text_styles.dart';
import '../utils/quest_config.dart';

class QuestsScreen extends StatefulWidget {
  const QuestsScreen({super.key});

  @override
  State<QuestsScreen> createState() => _QuestsScreenState();
}

class _QuestsScreenState extends State<QuestsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final uid = context.read<AuthProvider>().currentUser?.uid;
      if (uid != null) context.read<QuestProvider>().load(uid);
    });
  }

  @override
  Widget build(BuildContext context) {
    final questProvider = context.watch<QuestProvider>();
    final history = context.watch<WatchHistoryProvider>().watchHistory;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Quests')),
      body: _buildBody(questProvider, history),
    );
  }

  Widget _buildBody(QuestProvider questProvider, List<WatchHistoryEntry> history) {
    if (questProvider.status == LoadStatus.loading && questProvider.bundle == null) {
      return const Center(child: CircularProgressIndicator(color: AppColors.primaryAccent));
    }
    if (questProvider.status == LoadStatus.error && questProvider.bundle == null) {
      return Center(child: Text("Couldn't load quests", style: AppTextStyles.bodySecondary));
    }
    final bundle = questProvider.bundle;
    if (bundle == null) return const SizedBox.shrink();

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Text('Weekly Quests', style: AppTextStyles.h3),
        const SizedBox(height: 4),
        Text('Resets every Monday', style: AppTextStyles.caption),
        const SizedBox(height: 12),
        ..._buildQuestCards(bundle.weekly, weeklyQuestPool, history),
        const SizedBox(height: 28),
        Text('Monthly Quests', style: AppTextStyles.h3),
        const SizedBox(height: 4),
        Text('Resets on the 1st of each month', style: AppTextStyles.caption),
        const SizedBox(height: 12),
        ..._buildQuestCards(bundle.monthly, monthlyQuestPool, history),
      ],
    );
  }

  List<Widget> _buildQuestCards(
    QuestPeriodState periodState,
    List<QuestTemplate> pool,
    List<WatchHistoryEntry> history,
  ) {
    final periodStart = QuestService.periodStartFor(periodState.type);
    final periodEntries = QuestService.entriesInPeriod(history, periodStart);

    return periodState.quests.map((activeQuest) {
      final matches = pool.where((t) => t.id == activeQuest.templateId);
      if (matches.isEmpty) return const SizedBox.shrink();
      final template = matches.first;
      final progress = QuestService.progressFor(template, periodEntries);
      return _QuestCard(template: template, progress: progress, completed: activeQuest.completed);
    }).toList();
  }
}

class _QuestCard extends StatelessWidget {
  final QuestTemplate template;
  final int progress;
  final bool completed;

  const _QuestCard({required this.template, required this.progress, required this.completed});

  @override
  Widget build(BuildContext context) {
    final clampedProgress = (progress / template.target).clamp(0.0, 1.0);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16),
        border: completed ? Border.all(color: AppColors.success, width: 1) : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                completed ? Icons.check_circle_rounded : Icons.flag_rounded,
                color: completed ? AppColors.success : AppColors.primaryAccent,
                size: 20,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(template.title, style: AppTextStyles.body),
                    Text(template.description, style: AppTextStyles.caption),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Text('+${template.xpReward} XP', style: AppTextStyles.caption.copyWith(color: AppColors.xp)),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: clampedProgress,
              minHeight: 8,
              backgroundColor: AppColors.surface,
              valueColor: AlwaysStoppedAnimation(completed ? AppColors.success : AppColors.primaryAccent),
            ),
          ),
          const SizedBox(height: 4),
          Text('${progress.clamp(0, template.target)} / ${template.target}', style: AppTextStyles.caption),
        ],
      ),
    );
  }
}
