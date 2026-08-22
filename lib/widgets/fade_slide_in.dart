import 'package:flutter/material.dart';

/// Wraps a list/grid item so it fades and slides up into place shortly
/// after being built, staggered by [index] — turns a static list into
/// entries that feel like they're arriving one after another instead
/// of popping in all at once.
///
/// Safe to use inside `ListView.builder`/`GridView.builder`: each item
/// only plays its entrance once, the first time that item's State is
/// created (lazy-built items animate in as they're first scrolled into
/// view, which reads as an intentional effect rather than a bug).
class FadeSlideIn extends StatefulWidget {
  final Widget child;
  final int index;
  final Duration baseDelay;
  final Duration duration;

  const FadeSlideIn({
    super.key,
    required this.child,
    this.index = 0,
    this.baseDelay = const Duration(milliseconds: 40),
    this.duration = const Duration(milliseconds: 350),
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

    // Cap the stagger so long lists don't take forever to finish
    // appearing — items past ~index 12 all start together.
    final rawDelay = widget.baseDelay * widget.index;
    const capMs = 480;
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
