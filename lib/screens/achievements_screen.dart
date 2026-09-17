import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/providers/auth_provider.dart';
import '../core/providers/watch_history_provider.dart';
import '../core/services/achievement_service.dart';
import '../themes/app_colors.dart';
import '../themes/app_text_styles.dart';
import '../utils/achievement_config.dart';
import '../widgets/fade_slide_in.dart';
import '../widgets/animated_progress_bar.dart';
import '../themes/app_shadows.dart';

/// Computes current tier for every category live from watch history
/// already sitting in WatchHistoryProvider — no separate Firestore read
/// needed here. The persisted `achievements` subcollection exists only
/// so ProgressionService can tell "did this tier just get crossed" when
/// a movie is logged; display doesn't need it.
class AchievementsScreen extends StatelessWidget {
  const AchievementsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final history = context.watch<WatchHistoryProvider>().watchHistory;
    final collectionsCompleted = context.watch<AuthProvider>().currentUser?.collectionsCompleted ?? 0;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Achievements')),
      body: ListView.builder(
        padding: const EdgeInsets.all(20),
        itemCount: achievementDefinitions.length,
        itemBuilder: (context, index) {
          final def = achievementDefinitions[index];
          final value = AchievementService.currentValueFor(
            def.category,
            history,
            collectionsCompleted: collectionsCompleted,
          );
          final tier = AchievementService.tierForValue(def, value);
          return FadeSlideIn(
            index: index,
            child: _AchievementCard(definition: def, currentValue: value, tier: tier),
          );
        },
      ),
    );
  }
}

class _AchievementCard extends StatelessWidget {
  final AchievementDefinition definition;
  final int currentValue;
  final int tier;

  const _AchievementCard({
    required this.definition,
    required this.currentValue,
    required this.tier,
  });

  void _openDetail(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => _AchievementDetailSheet(
        definition: definition,
        currentValue: currentValue,
        tier: tier,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final maxTier = definition.tierThresholds.length;
    final isMaxed = tier >= maxTier;
    final nextThreshold = isMaxed ? null : definition.tierThresholds[tier];
    final previousThreshold = tier == 0 ? 0 : definition.tierThresholds[tier - 1];
    final progress = isMaxed
        ? 1.0
        : ((currentValue - previousThreshold) / (nextThreshold! - previousThreshold))
            .clamp(0.0, 1.0);
    final unlocked = tier > 0;

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16),
        boxShadow: AppShadows.card,
        // A left accent bar when unlocked gives achievement cards their
        // own visual signature instead of being an icon-swapped copy of
        // every other card template in the app.
        border: Border(
          left: BorderSide(
            color: unlocked ? AppColors.xp : Colors.transparent,
            width: 4,
          ),
        ),
      ),
      child: InkWell(
        onTap: () => _openDetail(context),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: unlocked ? AppColors.xp.withValues(alpha: 0.15) : AppColors.surface,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      definition.icon,
                      color: unlocked ? AppColors.xp : AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(definition.title, style: AppTextStyles.h3),
                        Text(definition.description, style: AppTextStyles.caption),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    isMaxed ? 'MAX' : 'Tier $tier/$maxTier',
                    style: AppTextStyles.caption.copyWith(color: AppColors.xp, fontWeight: FontWeight.w700),
                  ),
                  const Icon(Icons.chevron_right_rounded, color: AppColors.textSecondary),
                ],
              ),
              const SizedBox(height: 12),
              AnimatedProgressBar(value: progress, minHeight: 8, valueColor: AppColors.xp),
              const SizedBox(height: 6),
              Text(
                isMaxed ? '$currentValue — maxed out' : '$currentValue / $nextThreshold',
                style: AppTextStyles.caption,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Full tier-by-tier breakdown for one achievement — every threshold,
/// which ones are already unlocked, and which one is next. The card
/// above only shows the current tier; this is the "view progress
/// better" detail view.
class _AchievementDetailSheet extends StatelessWidget {
  final AchievementDefinition definition;
  final int currentValue;
  final int tier;

  const _AchievementDetailSheet({
    required this.definition,
    required this.currentValue,
    required this.tier,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: tier > 0
                        ? AppColors.xp.withValues(alpha: 0.15)
                        : AppColors.card,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    definition.icon,
                    color: tier > 0 ? AppColors.xp : AppColors.textSecondary,
                    size: 26,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(definition.title, style: AppTextStyles.h2),
                      Text(definition.description, style: AppTextStyles.bodySecondary),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Current: $currentValue',
              style: AppTextStyles.body.copyWith(color: AppColors.xp),
            ),
            const SizedBox(height: 20),
            const Divider(color: AppColors.card),
            const SizedBox(height: 8),
            ...List.generate(definition.tierThresholds.length, (i) {
              final tierNumber = i + 1;
              final threshold = definition.tierThresholds[i];
              final unlocked = tierNumber <= tier;
              final isNext = tierNumber == tier + 1;

              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Row(
                  children: [
                    Icon(
                      unlocked ? Icons.check_circle_rounded : Icons.radio_button_unchecked_rounded,
                      color: unlocked ? AppColors.success : AppColors.textSecondary,
                      size: 20,
                    ),
                    const SizedBox(width: 10),
                    Text(
                      'Tier $tierNumber',
                      style: AppTextStyles.body.copyWith(
                        color: unlocked ? AppColors.textPrimary : AppColors.textSecondary,
                        fontWeight: isNext ? FontWeight.w700 : FontWeight.w400,
                      ),
                    ),
                    if (isNext) ...[
                      const SizedBox(width: 8),
                      Text('· next', style: AppTextStyles.caption.copyWith(color: AppColors.xp)),
                    ],
                    const Spacer(),
                    Text('$threshold', style: AppTextStyles.bodySecondary),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}
