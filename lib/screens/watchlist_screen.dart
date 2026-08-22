import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../core/providers/auth_provider.dart';
import '../core/providers/watch_history_provider.dart';
import '../core/providers/load_status.dart';
import '../themes/app_colors.dart';
import '../themes/app_text_styles.dart';
import '../widgets/empty_state.dart';
import '../widgets/skeleton_loaders.dart';
import '../widgets/fade_slide_in.dart';
import 'movie_details_screen.dart';

class WatchlistScreen extends StatelessWidget {
  const WatchlistScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final history = context.watch<WatchHistoryProvider>();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Watchlist')),
      body: history.watchlistStatus == LoadStatus.loading && history.watchlist.isEmpty
          ? const MovieTileListSkeleton()
          : history.watchlist.isEmpty
              ? const EmptyState(
                  icon: Icons.bookmark_border_rounded,
                  title: 'Your watchlist is empty',
                  message: "Tap the bookmark icon on any movie's details page to save it here.",
                )
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  itemCount: history.watchlist.length,
                  itemBuilder: (context, index) {
                    final entry = history.watchlist[index];
                    return FadeSlideIn(
                      index: index,
                      child: ListTile(
                        leading: Hero(
                          tag: 'movie_hero_${entry.movieId}',
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(6),
                            child: SizedBox(
                              width: 46,
                              height: 69,
                              child: entry.posterUrl != null
                                  ? CachedNetworkImage(imageUrl: entry.posterUrl!, fit: BoxFit.cover)
                                  : Container(color: AppColors.card),
                            ),
                          ),
                        ),
                        title: Text(entry.movieTitle, style: AppTextStyles.body),
                        trailing: IconButton(
                          icon: const Icon(Icons.close_rounded, color: AppColors.textSecondary),
                          onPressed: () async {
                            final uid = context.read<AuthProvider>().currentUser?.uid;
                            if (uid != null) {
                              await context.read<WatchHistoryProvider>().removeFromWatchlist(uid, entry.movieId);
                            }
                          },
                        ),
                        onTap: () => Navigator.of(context).push(
                          MaterialPageRoute(builder: (_) => MovieDetailsScreen(movieId: entry.movieId)),
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
