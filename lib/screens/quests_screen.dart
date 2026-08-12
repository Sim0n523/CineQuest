import 'package:flutter/material.dart';
import '../themes/app_colors.dart';
import '../widgets/empty_state.dart';

class QuestsScreen extends StatelessWidget {
  const QuestsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Quests')),
      body: const EmptyState(
        icon: Icons.flag_rounded,
        title: 'Quests are coming soon',
        message: 'Weekly and monthly quests unlock in Phase 4, once XP and levels are wired up.',
      ),
    );
  }
}
