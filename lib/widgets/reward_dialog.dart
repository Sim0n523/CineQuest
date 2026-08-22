import 'package:flutter/material.dart';
import '../themes/app_colors.dart';
import '../themes/app_text_styles.dart';
import '../core/services/progression_service.dart';
import '../utils/dialog_transitions.dart';
import 'primary_button.dart';
import 'fade_slide_in.dart';

/// The payoff moment for "every movie logged should feel rewarding"
/// (blueprint section 2). Shown once, right after a brand-new log —
/// never on an edit, since no XP or achievements fire there either.
class RewardDialog extends StatefulWidget {
  final ProgressionResult result;

  const RewardDialog({super.key, required this.result});

  static Future<void> show(BuildContext context, ProgressionResult result) {
    return showCelebrationDialog<void>(
      context,
      builder: (_) => RewardDialog(result: result),
    );
  }

  @override
  State<RewardDialog> createState() => _RewardDialogState();
}

class _RewardDialogState extends State<RewardDialog> with SingleTickerProviderStateMixin {
  late final AnimationController _iconController;
  late final Animation<double> _iconScale;

  @override
  void initState() {
    super.initState();
    _iconController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _iconScale = CurvedAnimation(parent: _iconController, curve: Curves.elasticOut);
    _iconController.forward();
  }

  @override
  void dispose() {
    _iconController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final result = widget.result;

    return Dialog(
      backgroundColor: AppColors.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ScaleTransition(
              scale: _iconScale,
              child: Icon(
                result.leveledUp ? Icons.military_tech_rounded : Icons.emoji_events_rounded,
                color: AppColors.primaryAccent,
                size: 56,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              result.leveledUp ? 'Level Up!' : 'Movie Logged!',
              style: AppTextStyles.h2,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            _AnimatedXPCounter(xpGained: result.xpGained),
            if (result.leveledUp) ...[
              const SizedBox(height: 4),
              Text('You reached Level ${result.newLevel}', style: AppTextStyles.bodySecondary),
            ],
            if (result.newlyUnlockedAchievements.isNotEmpty) ...[
              const SizedBox(height: 16),
              const Divider(color: AppColors.card),
              const SizedBox(height: 12),
              Text('Achievements Unlocked', style: AppTextStyles.body),
              const SizedBox(height: 8),
              ...result.newlyUnlockedAchievements.asMap().entries.map(
                (entry) => FadeSlideIn(
                  index: entry.key,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Row(
                      children: [
                        Icon(entry.value.definition.icon, color: AppColors.primaryAccent, size: 20),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            '${entry.value.definition.title} — Tier ${entry.value.tier}',
                            style: AppTextStyles.bodySecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
            if (result.newlyCompletedQuests.isNotEmpty) ...[
              const SizedBox(height: 16),
              const Divider(color: AppColors.card),
              const SizedBox(height: 12),
              Text('Quests Completed', style: AppTextStyles.body),
              const SizedBox(height: 8),
              ...result.newlyCompletedQuests.asMap().entries.map(
                (entry) => FadeSlideIn(
                  index: entry.key,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Row(
                      children: [
                        const Icon(Icons.flag_rounded, color: AppColors.success, size: 20),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(entry.value.template.title, style: AppTextStyles.bodySecondary),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
            const SizedBox(height: 20),
            PrimaryButton(label: 'Nice!', onPressed: () => Navigator.of(context).pop()),
          ],
        ),
      ),
    );
  }
}

/// Counts up from 0 to the XP gained instead of just displaying the
/// final number immediately.
class _AnimatedXPCounter extends StatelessWidget {
  final int xpGained;

  const _AnimatedXPCounter({required this.xpGained});

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<int>(
      tween: IntTween(begin: 0, end: xpGained),
      duration: const Duration(milliseconds: 800),
      curve: Curves.easeOutCubic,
      builder: (context, value, _) {
        return Text(
          '+$value XP',
          style: AppTextStyles.h3.copyWith(color: AppColors.xp),
        );
      },
    );
  }
}
