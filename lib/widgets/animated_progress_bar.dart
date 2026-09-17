import 'package:flutter/material.dart';
import '../themes/app_colors.dart';

/// A progress bar that smoothly animates to a new [value] instead of
/// snapping instantly — used anywhere progress represents player
/// progression (XP, achievement tiers, quest and collection progress).
///
/// Manages its own AnimationController and only re-animates when
/// [value] genuinely changes, not on every unrelated parent rebuild.
class AnimatedProgressBar extends StatefulWidget {
  final double value;
  final double minHeight;
  final Color backgroundColor;
  final Color valueColor;
  final Duration duration;
  final BorderRadius borderRadius;

  /// If true (default), the very first time this bar appears it fills
  /// from 0 up to [value] — the "counting up" feel wanted for XP/tier
  /// bars. Pass false for bars where an instant initial read is more
  /// appropriate.
  final bool animateFromZeroOnFirstBuild;

  const AnimatedProgressBar({
    super.key,
    required this.value,
    this.minHeight = 8,
    this.backgroundColor = AppColors.surface,
    this.valueColor = AppColors.primaryAccent,
    this.duration = const Duration(milliseconds: 700),
    this.borderRadius = const BorderRadius.all(Radius.circular(6)),
    this.animateFromZeroOnFirstBuild = true,
  });

  @override
  State<AnimatedProgressBar> createState() => _AnimatedProgressBarState();
}

class _AnimatedProgressBarState extends State<AnimatedProgressBar>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late Animation<double> _animation;
  late double _targetValue;

  double get _clampedValue => widget.value.clamp(0.0, 1.0);

  @override
  void initState() {
    super.initState();
    _targetValue = _clampedValue;
    _controller = AnimationController(vsync: this, duration: widget.duration);
    final start = widget.animateFromZeroOnFirstBuild ? 0.0 : _targetValue;
    _animation = Tween<double>(begin: start, end: _targetValue).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
    );
    _controller.forward();
  }

  @override
  void didUpdateWidget(AnimatedProgressBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    final newTarget = _clampedValue;
    if (newTarget != _targetValue) {
      final start = _animation.value;
      _targetValue = newTarget;
      _animation = Tween<double>(begin: start, end: _targetValue).animate(
        CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
      );
      _controller
        ..duration = widget.duration
        ..forward(from: 0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: widget.borderRadius,
      child: AnimatedBuilder(
        animation: _animation,
        builder: (context, _) {
          return LinearProgressIndicator(
            value: _animation.value,
            minHeight: widget.minHeight,
            backgroundColor: widget.backgroundColor,
            valueColor: AlwaysStoppedAnimation(widget.valueColor),
          );
        },
      ),
    );
  }
}
