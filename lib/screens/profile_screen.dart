import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../core/providers/auth_provider.dart';
import '../themes/app_colors.dart';
import '../themes/app_text_styles.dart';
import '../widgets/stat_tile.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final user = auth.currentUser;

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
                const SizedBox(height: 16),
                Center(child: Text(user.username, style: AppTextStyles.h2)),
                Center(child: Text(user.email, style: AppTextStyles.bodySecondary)),
                const SizedBox(height: 8),
                Center(
                  child: Text(
                    'Level ${user.level} · ${user.xp} XP',
                    style: AppTextStyles.body.copyWith(color: AppColors.xp),
                  ),
                ),
                const SizedBox(height: 28),
                GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: 1.6,
                  children: [
                    StatTile(label: 'Movies Watched', value: '${user.moviesWatched}'),
                    StatTile(label: 'Reviews Written', value: '${user.reviewsWritten}'),
                    StatTile(label: 'Current Streak', value: '${user.currentStreak}'),
                    StatTile(label: 'Achievements', value: '${user.achievementsUnlocked}'),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  'Full statistics, achievements, and collections unlock in later phases.',
                  textAlign: TextAlign.center,
                  style: AppTextStyles.caption,
                ),
              ],
            ),
    );
  }
}
