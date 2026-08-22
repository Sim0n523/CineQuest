import 'package:flutter/material.dart';
import '../themes/app_colors.dart';
import 'shimmer_box.dart';

/// Card-shaped skeleton matching MovieCard's poster + title + rating
/// layout — used wherever a row/grid of movies is still loading.
class MoviePosterSkeleton extends StatelessWidget {
  final bool expand;

  const MoviePosterSkeleton({super.key, this.expand = false});

  @override
  Widget build(BuildContext context) {
    final content = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        AspectRatio(
          aspectRatio: 2 / 3,
          child: ShimmerBox(
            width: double.infinity,
            height: double.infinity,
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        const SizedBox(height: 6),
        ShimmerBox(width: 80, height: 12, borderRadius: BorderRadius.circular(4)),
        const SizedBox(height: 6),
        ShimmerBox(width: 40, height: 10, borderRadius: BorderRadius.circular(4)),
      ],
    );
    return expand ? content : SizedBox(width: 120, child: content);
  }
}

/// A horizontal row of poster skeletons — matches Home's Trending /
/// Popular rows while they load.
class MovieRowSkeleton extends StatelessWidget {
  final int count;

  const MovieRowSkeleton({super.key, this.count = 4});

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      itemCount: count,
      separatorBuilder: (_, __) => const SizedBox(width: 12),
      itemBuilder: (_, __) => const MoviePosterSkeleton(),
    );
  }
}

/// A 2-column grid of poster skeletons — matches Discover's grid while
/// it loads.
class MovieGridSkeleton extends StatelessWidget {
  final int count;

  const MovieGridSkeleton({super.key, this.count = 6});

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 20,
        crossAxisSpacing: 16,
        childAspectRatio: 0.52,
      ),
      itemCount: count,
      itemBuilder: (_, __) => const MoviePosterSkeleton(expand: true),
    );
  }
}

/// A single list-tile-shaped skeleton — matches the 46x69-poster +
/// two-lines-of-text pattern used by Watch History, Watchlist, and
/// Search results.
class MovieTileSkeleton extends StatelessWidget {
  const MovieTileSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          ShimmerBox(width: 46, height: 69, borderRadius: BorderRadius.circular(6)),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ShimmerBox(height: 14, borderRadius: BorderRadius.circular(4)),
                const SizedBox(height: 8),
                const SizedBox(
                  width: 100,
                  child: ShimmerBox(height: 12, borderRadius: BorderRadius.all(Radius.circular(4))),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// A vertical list of tile skeletons — matches Watch History / Watchlist
/// / Search loading states.
class MovieTileListSkeleton extends StatelessWidget {
  final int count;

  const MovieTileListSkeleton({super.key, this.count = 6});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: count,
      itemBuilder: (_, __) => const MovieTileSkeleton(),
    );
  }
}

/// A card-shaped skeleton matching the Leaderboard tile layout
/// (rank + avatar + name).
class LeaderboardTileSkeleton extends StatelessWidget {
  const LeaderboardTileSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: AppColors.card, borderRadius: BorderRadius.circular(14)),
      child: Row(
        children: [
          const SizedBox(width: 30),
          const ShimmerBox(width: 40, height: 40, borderRadius: BorderRadius.all(Radius.circular(20))),
          const SizedBox(width: 12),
          Expanded(child: ShimmerBox(height: 14, borderRadius: BorderRadius.circular(4))),
        ],
      ),
    );
  }
}

/// A vertical list of leaderboard tile skeletons.
class LeaderboardListSkeleton extends StatelessWidget {
  final int count;

  const LeaderboardListSkeleton({super.key, this.count = 8});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: count,
      itemBuilder: (_, __) => const LeaderboardTileSkeleton(),
    );
  }
}
