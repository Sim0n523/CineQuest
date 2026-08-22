import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/providers/auth_provider.dart';
import '../themes/app_colors.dart';
import '../themes/app_text_styles.dart';
import '../utils/app_routes.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _iconScale;
  late final Animation<double> _textFade;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 900));
    _iconScale = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.6, curve: Curves.elasticOut),
    );
    _textFade = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.35, 1.0, curve: Curves.easeOut),
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

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
                ScaleTransition(
                  scale: _iconScale,
                  child: const Icon(Icons.local_movies_rounded, color: AppColors.primaryAccent, size: 72),
                ),
                const SizedBox(height: 16),
                FadeTransition(
                  opacity: _textFade,
                  child: Column(
                    children: [
                      Text('CineQuest', style: AppTextStyles.h1),
                      const SizedBox(height: 8),
                      Text('Level up your movie life', style: AppTextStyles.bodySecondary),
                    ],
                  ),
                ),
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
