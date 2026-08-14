import 'package:flutter/material.dart';
import '../themes/app_colors.dart';
import '../themes/app_text_styles.dart';

class LevelBadge extends StatelessWidget {
  final int level;
  final double size;

  const LevelBadge({super.key, required this.level, this.size = 32});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AppColors.background,
        border: Border.all(color: AppColors.primaryAccent, width: 2),
      ),
      child: Center(
        child: Text(
          '$level',
          style: AppTextStyles.caption.copyWith(
            color: AppColors.primaryAccent,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}
