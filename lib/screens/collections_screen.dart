import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../core/providers/auth_provider.dart';
import '../core/providers/collection_provider.dart';
import '../core/providers/watch_history_provider.dart';
import '../core/providers/load_status.dart';
import '../core/models/collection_progress.dart';
import '../core/services/progression_service.dart';
import '../themes/app_colors.dart';
import '../themes/app_text_styles.dart';
import '../widgets/empty_state.dart';
import '../widgets/collection_complete_dialog.dart';
import '../widgets/skeleton_loaders.dart';
import '../widgets/fade_slide_in.dart';
import '../widgets/animated_progress_bar.dart';
import 'collection_detail_screen.dart';

class CollectionsScreen extends StatefulWidget {
  const CollectionsScreen({super.key});

  @override
  State<CollectionsScreen> createState() => _CollectionsScreenState();
}

class _CollectionsScreenState extends State<CollectionsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  Future<void> _load() async {
    final history = context.read<WatchHistoryProvider>().watchHistory;
    await context.read<CollectionProvider>().loadAll(history);
    await _checkCompletions();
  }

  /// After loading, checks any collection that came back complete
  /// against the persisted "already awarded" flag — only shows the
  /// celebration and grants XP the first time a collection is finished.
  Future<void> _checkCompletions() async {
    if (!mounted) return;
    final auth = context.read<AuthProvider>();
    final uid = auth.currentUser?.uid;
    if (uid == null) return;
    final history = context.read<WatchHistoryProvider>().watchHistory;

    final collections = context.read<CollectionProvider>().collections;
    for (final progress in collections) {
      if (!progress.isComplete) continue;
      final user = auth.currentUser;
      if (user == null) continue;

      final result = await ProgressionService().checkCollectionCompletion(
        uid: uid,
        collectionId: progress.definition.id,
        currentXp: user.xp,
        movieCount: progress.movies.length,
        currentCollectionsCompleted: user.collectionsCompleted,
        history: history,
      );

      if (result != null && mounted) {
        auth.applyCollectionReward(result);
        await CollectionCompleteDialog.show(
          context,
          collectionTitle: progress.definition.title,
          xpGained: result.xpGained,
          leveledUp: result.leveledUp,
          newLevel: result.newLevel,
          newlyUnlockedAchievements: result.newlyUnlockedAchievements,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<CollectionProvider>();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Collections')),
      body: _buildBody(provider),
    );
  }

  Widget _buildBody(CollectionProvider provider) {
    if (provider.status == LoadStatus.loading && provider.collections.isEmpty) {
      return const MovieTileListSkeleton();
    }
    if (provider.status == LoadStatus.error && provider.collections.isEmpty) {
      return Center(child: Text("Couldn't load collections", style: AppTextStyles.bodySecondary));
    }
    if (provider.collections.isEmpty) {
      return const EmptyState(
        icon: Icons.collections_bookmark_rounded,
        title: 'No collections available',
        message: 'Check your connection and try again.',
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: provider.collections.length,
      itemBuilder: (context, index) {
        final progress = provider.collections[index];
        return FadeSlideIn(
          index: index,
          child: _CollectionCard(
            progress: progress,
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => CollectionDetailScreen(progress: progress)),
            ),
          ),
        );
      },
    );
  }
}

class _CollectionCard extends StatelessWidget {
  final CollectionProgress progress;
  final VoidCallback onTap;

  const _CollectionCard({required this.progress, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final total = progress.movies.length;
    final ratio = total == 0 ? 0.0 : progress.loggedCount / total;
    final isComplete = progress.isComplete;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: AppColors.card, borderRadius: BorderRadius.circular(16)),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: total > 0 && progress.movies.first.posterUrl != null
                  ? CachedNetworkImage(
                      imageUrl: progress.movies.first.posterUrl!,
                      width: 56,
                      height: 84,
                      fit: BoxFit.cover,
                    )
                  : Container(
                      width: 56,
                      height: 84,
                      color: AppColors.surface,
                      child: Icon(progress.definition.icon, color: AppColors.textSecondary),
                    ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(child: Text(progress.definition.title, style: AppTextStyles.h3)),
                      if (isComplete)
                        const Icon(Icons.emoji_events_rounded, color: AppColors.primaryAccent, size: 20),
                    ],
                  ),
                  Text(
                    progress.definition.description,
                    style: AppTextStyles.caption,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  AnimatedProgressBar(
                    value: ratio,
                    minHeight: 6,
                    valueColor: isComplete ? AppColors.success : AppColors.primaryAccent,
                  ),
                  const SizedBox(height: 4),
                  Text('${progress.loggedCount} / $total logged', style: AppTextStyles.caption),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
