import 'package:flutter/material.dart';
import '../themes/app_colors.dart';
import '../themes/app_text_styles.dart';
import '../utils/xp_config.dart';

class XPBar extends StatelessWidget {
  final int xp;
  final int level;

  const XPBar({super.key, required this.xp, required this.level});

  @override
  Widget build(BuildContext context) {
    final progress = LevelConfig.progressToNextLevel(xp);
    final nextThreshold = LevelConfig.xpForNextLevel(level);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Level $level', style: AppTextStyles.body),
            Text(
              nextThreshold != null ? '$xp / $nextThreshold XP' : '$xp XP · Max Level',
              style: AppTextStyles.caption,
            ),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: LinearProgressIndicator(
            value: progress,
            minHeight: 10,
            backgroundColor: AppColors.card,
            valueColor: const AlwaysStoppedAnimation(AppColors.xp),
          ),
        ),
      ],
    );
  }
}
