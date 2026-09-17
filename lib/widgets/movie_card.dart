import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../core/models/movie_model.dart';
import '../themes/app_colors.dart';
import '../themes/app_text_styles.dart';
import '../themes/app_shadows.dart';

class MovieCard extends StatefulWidget {
  final MovieModel movie;
  final VoidCallback? onTap;
  final bool expand;

  /// When provided, wraps the poster in a Hero with this tag so tapping
  /// the card morphs smoothly into MovieDetailsScreen's backdrop.
  ///
  /// Only pass this from screens where a given movie can appear at
  /// most once on screen at a time — two simultaneous Heroes sharing a
  /// tag is a runtime error. Home's Trending/Popular rows can both
  /// show the same movie at once (TMDB's lists overlap), so Home
  /// deliberately leaves this null.
  final String? heroTag;

  const MovieCard({
    super.key,
    required this.movie,
    this.onTap,
    this.expand = false,
    this.heroTag,
  });

  @override
  State<MovieCard> createState() => _MovieCardState();
}

class _MovieCardState extends State<MovieCard> {
  bool _pressed = false;

  void _setPressed(bool value) {
    if (widget.onTap == null) return;
    setState(() => _pressed = value);
  }

  @override
  Widget build(BuildContext context) {
    final movie = widget.movie;

    Widget poster = movie.posterUrl != null
        ? CachedNetworkImage(
            imageUrl: movie.posterUrl!,
            fit: BoxFit.cover,
            placeholder: (_, __) => Container(color: AppColors.card),
            errorWidget: (_, __, ___) => Container(
              color: AppColors.card,
              child: const Icon(Icons.movie_rounded, color: AppColors.textSecondary),
            ),
          )
        : Container(
            color: AppColors.card,
            child: const Icon(Icons.movie_rounded, color: AppColors.textSecondary),
          );

    if (widget.heroTag != null) {
      poster = Hero(tag: widget.heroTag!, child: poster);
    }

    final content = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            boxShadow: AppShadows.card,
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: AspectRatio(
              aspectRatio: 2 / 3,
              child: poster,
            ),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          movie.title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: AppTextStyles.body,
        ),
        const SizedBox(height: 2),
        Row(
          children: [
            const Icon(Icons.star_rounded, color: AppColors.primaryAccent, size: 14),
            const SizedBox(width: 2),
            Text(movie.voteAverage.toStringAsFixed(1), style: AppTextStyles.caption),
          ],
        ),
      ],
    );

    return GestureDetector(
      onTap: widget.onTap,
      onTapDown: (_) => _setPressed(true),
      onTapUp: (_) => _setPressed(false),
      onTapCancel: () => _setPressed(false),
      child: AnimatedScale(
        scale: _pressed ? 0.96 : 1.0,
        duration: const Duration(milliseconds: 120),
        curve: Curves.easeOut,
        child: widget.expand ? content : SizedBox(width: 120, child: content),
      ),
    );
  }
}
