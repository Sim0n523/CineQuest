import 'package:flutter/material.dart';
import '../themes/app_colors.dart';

/// Base shimmer primitive — a rounded rect that sweeps a soft gradient
/// left-to-right on a loop. Composed into content-shaped skeleton
/// placeholders (see skeleton_loaders.dart) so loading states preview
/// the real layout instead of a generic spinner.
class ShimmerBox extends StatefulWidget {
  final double? width;
  final double height;
  final BorderRadius borderRadius;

  const ShimmerBox({
    super.key,
    this.width,
    required this.height,
    this.borderRadius = const BorderRadius.all(Radius.circular(8)),
  });

  @override
  State<ShimmerBox> createState() => _ShimmerBoxState();
}

class _ShimmerBoxState extends State<ShimmerBox> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        // Sweeps a highlight band across the box by shifting the
        // gradient's alignment each frame; going past [-1, 1] is
        // intentional so the band fully enters and exits the box
        // instead of jumping.
        final dx = -1.6 + 3.2 * _controller.value;
        return ClipRRect(
          borderRadius: widget.borderRadius,
          child: Container(
            width: widget.width,
            height: widget.height,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment(dx - 0.3, 0),
                end: Alignment(dx + 0.3, 0),
                colors: const [AppColors.card, AppColors.surface, AppColors.card],
                stops: const [0.0, 0.5, 1.0],
              ),
            ),
          ),
        );
      },
    );
  }
}
