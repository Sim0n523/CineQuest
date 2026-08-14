import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../core/models/movie_model.dart';
import '../themes/app_colors.dart';
import '../themes/app_text_styles.dart';

class MovieCard extends StatelessWidget {
  final MovieModel movie;
  final VoidCallback? onTap;
  final bool expand;

  const MovieCard({
    super.key,
    required this.movie,
    this.onTap,
    this.expand = false,
  });

  @override
  Widget build(BuildContext context) {
    final content = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(14),
          child: AspectRatio(
            aspectRatio: 2 / 3,
            child: movie.posterUrl != null
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
      onTap: onTap,
      child: expand ? content : SizedBox(width: 120, child: content),
    );
  }
}
