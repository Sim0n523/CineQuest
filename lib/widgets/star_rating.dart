import 'package:flutter/material.dart';
import '../themes/app_colors.dart';

/// A row of 5 tappable stars supporting half-star precision (0.5
/// increments). Pass onChanged for an editable rating input (Log
/// Movie), or leave it null for a read-only display (Movie Details,
/// Watch History).
///
/// Tapping the left half of a star sets a half value (e.g. 4.5),
/// tapping the right half sets a full value (e.g. 5.0) — same single-tap
/// gesture as before, just position-sensitive within each star now, so
/// full-star tapping still feels exactly as direct as it did.
class StarRating extends StatelessWidget {
  final double rating; // 0.0-5.0 in 0.5 steps; 0 means unrated
  final ValueChanged<double>? onChanged;
  final double size;

  const StarRating({
    super.key,
    required this.rating,
    this.onChanged,
    this.size = 32,
  });

  static const double _spacing = 4;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (index) {
        final starValue = index + 1;
        final IconData icon;
        if (rating >= starValue) {
          icon = Icons.star_rounded;
        } else if (rating >= starValue - 0.5) {
          icon = Icons.star_half_rounded;
        } else {
          icon = Icons.star_border_rounded;
        }

        return Padding(
          padding: EdgeInsets.only(right: index == 4 ? 0 : _spacing),
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTapUp: onChanged == null
                ? null
                : (details) {
                    final tappedLeftHalf = details.localPosition.dx < size / 2;
                    onChanged!(index + (tappedLeftHalf ? 0.5 : 1.0));
                  },
            child: Icon(icon, color: AppColors.primaryAccent, size: size),
          ),
        );
      }),
    );
  }
}
