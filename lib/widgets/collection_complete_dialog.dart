import 'package:flutter/material.dart';
import '../themes/app_colors.dart';
import '../themes/app_text_styles.dart';
import '../utils/dialog_transitions.dart';
import '../core/services/progression_service.dart';
import 'primary_button.dart';
import 'fade_slide_in.dart';

/// Shown once, when a collection is detected as newly complete —
/// distinct from RewardDialog (which is about a single movie log) since
/// this celebrates a much longer-arc achievement. Can also carry
/// achievement unlocks now (e.g. Collector) since completing a
/// collection is the only thing that can cross that category's tier.
class CollectionCompleteDialog extends StatefulWidget {
  final String collectionTitle;
  final int xpGained;
  final bool leveledUp;
  final int newLevel;
  final List<UnlockedAchievement> newlyUnlockedAchievements;

  const CollectionCompleteDialog({
    super.key,
    required this.collectionTitle,
    required this.xpGained,
    required this.leveledUp,
    required this.newLevel,
    this.newlyUnlockedAchievements = const [],
  });

  static Future<void> show(
    BuildContext context, {
    required String collectionTitle,
    required int xpGained,
    required bool leveledUp,
    required int newLevel,
    List<UnlockedAchievement> newlyUnlockedAchievements = const [],
  }) {
    return showCelebrationDialog<void>(
      context,
      builder: (_) => CollectionCompleteDialog(
        collectionTitle: collectionTitle,
        xpGained: xpGained,
        leveledUp: leveledUp,
        newLevel: newLevel,
        newlyUnlockedAchievements: newlyUnlockedAchievements,
      ),
    );
  }

  @override
  State<CollectionCompleteDialog> createState() => _CollectionCompleteDialogState();
}

class _CollectionCompleteDialogState extends State<CollectionCompleteDialog>
    with SingleTickerProviderStateMixin {
  late final AnimationController _iconController;
  late final Animation<double> _iconScale;

  @override
  void initState() {
    super.initState();
    _iconController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
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
              child: const Icon(
                Icons.collections_bookmark_rounded,
                color: AppColors.primaryAccent,
                size: 56,
              ),
            ),
            const SizedBox(height: 12),
            Text('Collection Complete!', style: AppTextStyles.h2, textAlign: TextAlign.center),
            const SizedBox(height: 4),
            Text(widget.collectionTitle, style: AppTextStyles.bodySecondary, textAlign: TextAlign.center),
            const SizedBox(height: 12),
            TweenAnimationBuilder<int>(
              tween: IntTween(begin: 0, end: widget.xpGained),
              duration: const Duration(milliseconds: 800),
              curve: Curves.easeOutCubic,
              builder: (context, value, _) => Text(
                '+$value XP',
                style: AppTextStyles.statNumber.copyWith(color: AppColors.xp, fontSize: 26),
              ),
            ),
            if (widget.leveledUp) ...[
              const SizedBox(height: 4),
              Text('You reached Level ${widget.newLevel}', style: AppTextStyles.bodySecondary),
            ],
            if (widget.newlyUnlockedAchievements.isNotEmpty) ...[
              const SizedBox(height: 16),
              const Divider(color: AppColors.card),
              const SizedBox(height: 12),
              Text('Achievements Unlocked', style: AppTextStyles.body),
              const SizedBox(height: 8),
              ...widget.newlyUnlockedAchievements.asMap().entries.map(
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
            const SizedBox(height: 20),
            PrimaryButton(label: 'Awesome!', onPressed: () => Navigator.of(context).pop()),
          ],
        ),
      ),
    );
  }
}
