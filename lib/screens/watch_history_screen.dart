import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../core/providers/auth_provider.dart';
import '../core/providers/watch_history_provider.dart';
import '../core/providers/load_status.dart';
import '../core/models/watch_history_entry.dart';
import '../themes/app_colors.dart';
import '../themes/app_text_styles.dart';
import '../widgets/empty_state.dart';
import '../widgets/star_rating.dart';
import 'movie_details_screen.dart';

class WatchHistoryScreen extends StatelessWidget {
  const WatchHistoryScreen({super.key});

  Future<void> _confirmDelete(BuildContext context, WatchHistoryEntry entry) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: Text('Remove this log?', style: AppTextStyles.h3),
        content: Text(
          'This deletes your rating and review for "${entry.movieTitle}".',
          style: AppTextStyles.bodySecondary,
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Remove', style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      final uid = context.read<AuthProvider>().currentUser?.uid;
      if (uid != null) {
        await context.read<WatchHistoryProvider>().deleteLogEntry(uid, entry.movieId);
      }
    }
  }

  String _formatDate(DateTime date) =>
      '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';

  @override
  Widget build(BuildContext context) {
    final history = context.watch<WatchHistoryProvider>();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Watch History')),
      body: history.historyStatus == LoadStatus.loading && history.watchHistory.isEmpty
          ? const Center(child: CircularProgressIndicator(color: AppColors.primaryAccent))
          : history.watchHistory.isEmpty
              ? const EmptyState(
                  icon: Icons.movie_filter_rounded,
                  title: 'No movies logged yet',
                  message: 'Everything you watch and log will show up here.',
                )
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  itemCount: history.watchHistory.length,
                  itemBuilder: (context, index) {
                    final entry = history.watchHistory[index];
                    return ListTile(
                      leading: ClipRRect(
                        borderRadius: BorderRadius.circular(6),
                        child: SizedBox(
                          width: 46,
                          height: 69,
                          child: entry.posterUrl != null
                              ? CachedNetworkImage(imageUrl: entry.posterUrl!, fit: BoxFit.cover)
                              : Container(color: AppColors.card),
                        ),
                      ),
                      title: Text(entry.movieTitle, style: AppTextStyles.body),
                      subtitle: Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            StarRating(rating: entry.rating ?? 0, size: 14),
                            const SizedBox(height: 2),
                            Text(_formatDate(entry.watchDate), style: AppTextStyles.caption),
                          ],
                        ),
                      ),
                      isThreeLine: true,
                      trailing: IconButton(
                        icon: const Icon(Icons.delete_outline_rounded, color: AppColors.textSecondary),
                        onPressed: () => _confirmDelete(context, entry),
                      ),
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => MovieDetailsScreen(movieId: entry.movieId)),
                      ),
                    );
                  },
                ),
    );
  }
}
