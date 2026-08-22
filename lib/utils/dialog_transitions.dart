import 'package:flutter/material.dart';

/// Shows a dialog with a scale+fade entrance (with a slight overshoot,
/// via [Curves.easeOutBack]) instead of Flutter's default abrupt
/// appearance. Used by RewardDialog and CollectionCompleteDialog — the
/// two "celebration" moments in the app — so the payoff of the
/// blueprint's "every movie logged should feel rewarding" philosophy
/// isn't undercut by the dialog just snapping into existence.
Future<T?> showCelebrationDialog<T>(
  BuildContext context, {
  required WidgetBuilder builder,
  bool barrierDismissible = true,
}) {
  return showGeneralDialog<T>(
    context: context,
    barrierDismissible: barrierDismissible,
    barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
    barrierColor: Colors.black54,
    transitionDuration: const Duration(milliseconds: 320),
    pageBuilder: (context, animation, secondaryAnimation) => builder(context),
    transitionBuilder: (context, animation, secondaryAnimation, child) {
      final scaleCurve = CurvedAnimation(parent: animation, curve: Curves.easeOutBack);
      final fadeCurve = CurvedAnimation(parent: animation, curve: Curves.easeOut);
      return FadeTransition(
        opacity: fadeCurve,
        child: ScaleTransition(
          scale: Tween<double>(begin: 0.85, end: 1.0).animate(scaleCurve),
          child: child,
        ),
      );
    },
  );
}
