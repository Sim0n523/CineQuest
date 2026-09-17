import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/models/collection_progress.dart';
import '../core/providers/watch_history_provider.dart';
import '../themes/app_colors.dart';
import '../themes/app_text_styles.dart';
import '../widgets/movie_card.dart';
import '../widgets/animated_progress_bar.dart';
import '../widgets/fade_slide_in.dart';
import 'movie_details_screen.dart';

class CollectionDetailScreen extends StatelessWidget {
  final CollectionProgress progress;

  const CollectionDetailScreen({super.key, required this.progress});

  @override
  Widget build(BuildContext context) {
    final history = context.watch<WatchHistoryProvider>();
    final total = progress.movies.length;
    // Computed live against current watch history, not the snapshot
    // loggedCount from when the list screen loaded — stays accurate if
    // a movie gets logged and the user navigates back here.
    final loggedCount = progress.movies.where((m) => history.isLogged(m.id)).length;
    final ratio = total == 0 ? 0.0 : loggedCount / total;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: Text(progress.definition.title)),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(progress.definition.description, style: AppTextStyles.bodySecondary),
                const SizedBox(height: 12),
                AnimatedProgressBar(
                  value: ratio,
                  minHeight: 8,
                  valueColor: ratio >= 1.0 ? AppColors.success : AppColors.xp,
                ),
                const SizedBox(height: 6),
                Text('$loggedCount / $total logged', style: AppTextStyles.caption),
              ],
            ),
          ),
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 20,
                crossAxisSpacing: 16,
                childAspectRatio: 0.52,
              ),
              itemCount: progress.movies.length,
              itemBuilder: (context, index) {
                final movie = progress.movies[index];
                final isLogged = history.isLogged(movie.id);
                return FadeSlideIn(
                  index: index,
                  child: Stack(
                    children: [
                      MovieCard(
                        movie: movie,
                        expand: true,
                        heroTag: 'movie_hero_${movie.id}',
                        onTap: () => Navigator.of(context).push(
                          MaterialPageRoute(builder: (_) => MovieDetailsScreen(movieId: movie.id, seed: movie)),
                        ),
                      ),
                      if (isLogged)
                        Positioned(
                          top: 4,
                          right: 4,
                          child: Container(
                            padding: const EdgeInsets.all(2),
                            decoration: const BoxDecoration(color: AppColors.background, shape: BoxShape.circle),
                            child: const Icon(Icons.check_circle_rounded, color: AppColors.success, size: 22),
                          ),
                        ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
