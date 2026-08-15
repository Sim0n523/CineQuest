import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../core/providers/auth_provider.dart';
import '../core/providers/leaderboard_provider.dart';
import '../core/providers/load_status.dart';
import '../core/models/leaderboard_entry.dart';
import '../themes/app_colors.dart';
import '../themes/app_text_styles.dart';
import '../widgets/empty_state.dart';
import '../widgets/level_badge.dart';

class LeaderboardScreen extends StatefulWidget {
  const LeaderboardScreen({super.key});

  @override
  State<LeaderboardScreen> createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends State<LeaderboardScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final user = context.read<AuthProvider>().currentUser;
      if (user != null) {
        context.read<LeaderboardProvider>().load(currentUid: user.uid, currentXp: user.xp);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final leaderboard = context.watch<LeaderboardProvider>();
    final currentUid = context.watch<AuthProvider>().currentUser?.uid;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Leaderboard')),
      body: _buildBody(leaderboard, currentUid),
    );
  }

  Widget _buildBody(LeaderboardProvider leaderboard, String? currentUid) {
    if (leaderboard.status == LoadStatus.loading && leaderboard.topUsers.isEmpty) {
      return const Center(child: CircularProgressIndicator(color: AppColors.primaryAccent));
    }
    if (leaderboard.status == LoadStatus.error && leaderboard.topUsers.isEmpty) {
      return Center(child: Text("Couldn't load the leaderboard", style: AppTextStyles.bodySecondary));
    }
    if (leaderboard.topUsers.isEmpty) {
      return const EmptyState(
        icon: Icons.leaderboard_rounded,
        title: 'No rankings yet',
        message: 'Log a movie to earn XP and claim the first spot.',
      );
    }

    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(20),
            itemCount: leaderboard.topUsers.length,
            itemBuilder: (context, index) {
              final entry = leaderboard.topUsers[index];
              return _LeaderboardTile(entry: entry, isCurrentUser: entry.uid == currentUid);
            },
          ),
        ),
        if (leaderboard.currentUserRank != null)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            decoration: const BoxDecoration(
              color: AppColors.surface,
              border: Border(top: BorderSide(color: AppColors.card)),
            ),
            child: Row(
              children: [
                Text(
                  '#${leaderboard.currentUserRank}',
                  style: AppTextStyles.h3.copyWith(color: AppColors.primaryAccent),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    "You're not in the top ${leaderboard.topUsers.length} yet — keep logging!",
                    style: AppTextStyles.bodySecondary,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

class _LeaderboardTile extends StatelessWidget {
  final LeaderboardEntry entry;
  final bool isCurrentUser;

  const _LeaderboardTile({required this.entry, required this.isCurrentUser});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isCurrentUser ? AppColors.primaryAccent.withValues(alpha: 0.12) : AppColors.card,
        borderRadius: BorderRadius.circular(14),
        border: isCurrentUser ? Border.all(color: AppColors.primaryAccent, width: 1) : null,
      ),
      child: Row(
        children: [
          SizedBox(
            width: 30,
            child: Text(
              '#${entry.rank}',
              style: AppTextStyles.body.copyWith(
                color: entry.rank <= 3 ? AppColors.primaryAccent : AppColors.textSecondary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          CircleAvatar(
            radius: 20,
            backgroundColor: AppColors.surface,
            backgroundImage:
                entry.avatarUrl != null ? CachedNetworkImageProvider(entry.avatarUrl!) : null,
            child: entry.avatarUrl == null
                ? Text(
                    entry.username.isNotEmpty ? entry.username[0].toUpperCase() : '?',
                    style: AppTextStyles.body,
                  )
                : null,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              entry.username,
              style: AppTextStyles.body,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          LevelBadge(level: entry.level, size: 26),
          const SizedBox(width: 10),
          Text('${entry.xp} XP', style: AppTextStyles.caption),
        ],
      ),
    );
  }
}
