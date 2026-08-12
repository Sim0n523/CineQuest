import 'package:flutter/material.dart';
import '../themes/app_colors.dart';
import '../widgets/empty_state.dart';

class LeaderboardScreen extends StatelessWidget {
  const LeaderboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Leaderboard')),
      body: const EmptyState(
        icon: Icons.leaderboard_rounded,
        title: 'Leaderboard is coming soon',
        message: 'Rankings go live in Phase 4, once players actually have XP to rank by.',
      ),
    );
  }
}
