import 'package:flutter/material.dart';

/// Wraps a list/grid item so it fades and slides up into place shortly
/// after being built, staggered by [index] — turns a static list into
/// entries that feel like they're arriving one after another instead
/// of popping in all at once.
///
/// Caveat: inside `ListView.builder`/`GridView.builder`, a fast fling
/// through a long list can bring a whole fresh batch of off-screen
/// items into view at once. Since every item past roughly the 8th
/// shares the same capped delay, that batch can briefly sit at 0%
/// opacity together before fading in — reading as "nothing on screen"
/// rather than a staggered reveal. delay/duration below are kept short
/// (worst case per batch: ~340ms) to keep that window brief.
class FadeSlideIn extends StatefulWidget {
  final Widget child;
  final int index;
  final Duration baseDelay;
  final Duration duration;

  const FadeSlideIn({
    super.key,
    required this.child,
    this.index = 0,
    this.baseDelay = const Duration(milliseconds: 15),
    this.duration = const Duration(milliseconds: 220),
  });

  @override
  State<FadeSlideIn> createState() => _FadeSlideInState();
}

class _FadeSlideInState extends State<FadeSlideIn> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fade;
  late final Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.duration);
    _fade = CurvedAnimation(parent: _controller, curve: Curves.easeOut);
    _slide = Tween<Offset>(begin: const Offset(0, 0.08), end: Offset.zero).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
    );

    // Cap the stagger so a freshly-scrolled-into-view batch of items
    // doesn't sit invisible for long — see the class doc comment above.
    final rawDelay = widget.baseDelay * widget.index;
    const capMs = 120;
    final delay = rawDelay.inMilliseconds > capMs
        ? const Duration(milliseconds: capMs)
        : rawDelay;

    Future.delayed(delay, () {
      if (mounted) _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fade,
      child: SlideTransition(position: _slide, child: widget.child),
    );
  }
}
