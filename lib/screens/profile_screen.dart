import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../core/providers/auth_provider.dart';
import '../core/providers/watch_history_provider.dart';
import '../themes/app_colors.dart';
import '../themes/app_text_styles.dart';
import '../widgets/stat_tile.dart';
import '../widgets/xp_bar.dart';
import '../widgets/level_badge.dart';
import 'achievements_screen.dart';
import 'watch_history_screen.dart';
import 'watchlist_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final user = auth.currentUser;
    final stats = context.watch<WatchHistoryProvider>().stats;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Profile'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout_rounded),
            onPressed: () => context.read<AuthProvider>().signOut(),
          ),
        ],
      ),
      body: user == null
          ? const Center(child: CircularProgressIndicator(color: AppColors.primaryAccent))
          : ListView(
              padding: const EdgeInsets.all(20),
              children: [
                Row(
                  children: [
                    Stack(
                      clipBehavior: Clip.none,
                      children: [
                        CircleAvatar(
                          radius: 40,
                          backgroundColor: AppColors.card,
                          backgroundImage: user.avatarUrl != null
                              ? CachedNetworkImageProvider(user.avatarUrl!)
                              : null,
                          child: user.avatarUrl == null
                              ? Text(
                                  user.username.isNotEmpty ? user.username[0].toUpperCase() : '?',
                                  style: AppTextStyles.h1,
                                )
                              : null,
                        ),
                        Positioned(
                          bottom: -4,
                          right: -4,
                          child: LevelBadge(level: user.level),
                        ),
                      ],
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(user.username, style: AppTextStyles.h2),
                          Text(user.email, style: AppTextStyles.bodySecondary),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                XPBar(xp: user.xp, level: user.level),
                const SizedBox(height: 28),
                GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: 1.6,
                  children: [
                    StatTile(label: 'Movies Watched', value: '${stats.moviesWatched}'),
                    StatTile(label: 'Reviews Written', value: '${stats.reviewsWritten}'),
                    StatTile(
                      label: 'Average Rating',
                      value: stats.averageRating == 0 ? '—' : stats.averageRating.toStringAsFixed(1),
                    ),
                    StatTile(label: 'Hours Watched', value: '${stats.hoursWatched}'),
                    StatTile(label: 'Favorite Genre', value: stats.favoriteGenre ?? '—'),
                    StatTile(label: 'Achievements', value: '${user.achievementsUnlocked}'),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  'Collections and streaks unlock in later phases.',
                  textAlign: TextAlign.center,
                  style: AppTextStyles.caption,
                ),
                const SizedBox(height: 28),
                _ProfileLink(
                  icon: Icons.emoji_events_rounded,
                  label: 'Achievements',
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const AchievementsScreen()),
                  ),
                ),
                const SizedBox(height: 10),
                _ProfileLink(
                  icon: Icons.history_rounded,
                  label: 'Watch History',
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const WatchHistoryScreen()),
                  ),
                ),
                const SizedBox(height: 10),
                _ProfileLink(
                  icon: Icons.bookmark_border_rounded,
                  label: 'Watchlist',
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const WatchlistScreen()),
                  ),
                ),
              ],
            ),
    );
  }
}

class _ProfileLink extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _ProfileLink({required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: [
            Icon(icon, color: AppColors.textPrimary, size: 20),
            const SizedBox(width: 12),
            Expanded(child: Text(label, style: AppTextStyles.body)),
            const Icon(Icons.chevron_right_rounded, color: AppColors.textSecondary),
          ],
        ),
      ),
    );
  }
}
