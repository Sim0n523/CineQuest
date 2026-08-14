import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/providers/auth_provider.dart';
import '../themes/app_colors.dart';
import '../themes/app_text_styles.dart';
import '../utils/app_routes.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, auth, _) {
        if (auth.status != AuthStatus.unknown) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (!context.mounted) return;
            Navigator.of(context).pushReplacementNamed(
              auth.status == AuthStatus.authenticated
                  ? AppRoutes.main
                  : AppRoutes.login,
            );
          });
        }

        return Scaffold(
          backgroundColor: AppColors.background,
          body: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.local_movies_rounded, color: AppColors.primaryAccent, size: 72),
                const SizedBox(height: 16),
                Text('CineQuest', style: AppTextStyles.h1),
                const SizedBox(height: 8),
                Text('Level up your movie life', style: AppTextStyles.bodySecondary),
                const SizedBox(height: 32),
                const CircularProgressIndicator(color: AppColors.primaryAccent),
              ],
            ),
          ),
        );
      },
    );
  }
}
