import 'package:flutter/material.dart';
import '../themes/app_colors.dart';
import '../themes/app_text_styles.dart';
import '../themes/app_shadows.dart';

class LevelBadge extends StatefulWidget {
  final int level;
  final double size;

  const LevelBadge({super.key, required this.level, this.size = 32});

  @override
  State<LevelBadge> createState() => _LevelBadgeState();
}

class _LevelBadgeState extends State<LevelBadge> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 500));
    _scale = CurvedAnimation(parent: _controller, curve: Curves.elasticOut);
    _controller.forward();
  }

  @override
  void didUpdateWidget(LevelBadge oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Replay the pop whenever the displayed level actually changes —
    // e.g. this badge on Profile updating right after a level-up.
    if (oldWidget.level != widget.level) {
      _controller.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _scale,
      child: Container(
        width: widget.size,
        height: widget.size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: AppColors.background,
          border: Border.all(color: AppColors.xp, width: 2),
          boxShadow: AppShadows.card,
        ),
        child: Center(
          child: Text(
            '${widget.level}',
            style: AppTextStyles.caption.copyWith(
              color: AppColors.xp,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ),
    );
  }
}
