import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../core/models/favorite_movie.dart';
import '../core/providers/auth_provider.dart';
import '../core/providers/watch_history_provider.dart';
import '../themes/app_colors.dart';
import '../themes/app_text_styles.dart';
import '../themes/app_shadows.dart';
import '../utils/image_compression.dart';
import '../utils/photo_source_picker.dart';
import '../utils/app_routes.dart';
import '../widgets/stat_tile.dart';
import '../widgets/xp_bar.dart';
import '../widgets/level_badge.dart';
import '../widgets/fade_slide_in.dart';
import '../widgets/user_avatar.dart';
import 'achievements_screen.dart';
import 'collections_screen.dart';
import 'edit_favorites_screen.dart';
import 'friends_list_screen.dart';
import 'nearby_cinemas_screen.dart';
import 'watch_history_screen.dart';
import 'watchlist_screen.dart';

/// Signs out AND explicitly navigates back to Login, clearing the whole
/// navigation stack. Necessary because SplashScreen is the only place
/// that reacts to AuthProvider.status, and only on cold start — without
/// this explicit navigation, nothing would redirect away from
/// MainNavigationScreen after signOut() runs.
Future<void> _signOut(BuildContext context) async {
  await context.read<AuthProvider>().signOut();
  if (context.mounted) {
    Navigator.of(context).pushNamedAndRemoveUntil(AppRoutes.login, (route) => false);
  }
}

/// Picks a new photo (camera or gallery, via the shared chooser),
/// compresses it (see utils/image_compression.dart), and saves it as
/// the user's avatar. A blocking loading dialog covers the compress+save
/// step so a briefly slow device doesn't make the tap feel like a no-op.
Future<void> _editAvatar(BuildContext context) async {
  final path = await pickPhotoFromCameraOrGallery(context);
  if (path == null || !context.mounted) return;

  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (_) => const Center(child: CircularProgressIndicator(color: AppColors.primaryAccent)),
  );

  String? errorMessage;
  try {
    final bytes = await File(path).readAsBytes();
    final base64 = await compressImageToBase64(bytes);
    final success = await context.read<AuthProvider>().updateAvatar(base64);
    if (!success) errorMessage = "Couldn't update your avatar — try again.";
  } catch (_) {
    errorMessage = "Couldn't process that photo — try a different one.";
  }

  if (!context.mounted) return;
  Navigator.of(context).pop(); // dismiss the loading dialog
  if (errorMessage != null) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(errorMessage)));
  }
}

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
            onPressed: () => _signOut(context),
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
                    GestureDetector(
                      onTap: () => _editAvatar(context),
                      child: Stack(
                        clipBehavior: Clip.none,
                        children: [
                          UserAvatar(avatarBase64: user.avatarBase64, username: user.username, radius: 40),
                          Positioned(
                            bottom: -4,
                            right: -4,
                            child: LevelBadge(level: user.level),
                          ),
                          Positioned(
                            top: -2,
                            left: -2,
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: const BoxDecoration(
                                color: AppColors.primaryAccent,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.camera_alt_rounded, color: Colors.black, size: 14),
                            ),
                          ),
                        ],
                      ),
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
                const SizedBox(height: 24),
                FadeSlideIn(
                  index: 0,
                  child: _FavoritesRow(
                    favorites: user.favoriteMovies,
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const EditFavoritesScreen()),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
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
                    FadeSlideIn(index: 1, child: StatTile(label: 'Movies Watched', value: '${stats.moviesWatched}')),
                    FadeSlideIn(index: 2, child: StatTile(label: 'Reviews Written', value: '${stats.reviewsWritten}')),
                    FadeSlideIn(
                      index: 3,
                      child: StatTile(
                        label: 'Average Rating',
                        value: stats.averageRating == 0 ? '—' : stats.averageRating.toStringAsFixed(1),
                      ),
                    ),
                    FadeSlideIn(index: 4, child: StatTile(label: 'Hours Watched', value: '${stats.hoursWatched}')),
                    FadeSlideIn(index: 5, child: StatTile(label: 'Favorite Genre', value: stats.favoriteGenre ?? '—')),
                    FadeSlideIn(index: 6, child: StatTile(label: 'Achievements', value: '${user.achievementsUnlocked}')),
                  ],
                ),
                const SizedBox(height: 28),
                FadeSlideIn(
                  index: 7,
                  child: _ProfileLink(
                    icon: Icons.emoji_events_rounded,
                    label: 'Achievements',
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const AchievementsScreen()),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                FadeSlideIn(
                  index: 8,
                  child: _ProfileLink(
                    icon: Icons.people_rounded,
                    label: 'Friends',
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const FriendsListScreen()),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                FadeSlideIn(
                  index: 9,
                  child: _ProfileLink(
                    icon: Icons.collections_bookmark_rounded,
                    label: 'Collections',
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const CollectionsScreen()),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                FadeSlideIn(
                  index: 10,
                  child: _ProfileLink(
                    icon: Icons.theaters_rounded,
                    label: 'Nearby Cinemas',
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const NearbyCinemasScreen()),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                FadeSlideIn(
                  index: 11,
                  child: _ProfileLink(
                    icon: Icons.history_rounded,
                    label: 'Watch History',
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const WatchHistoryScreen()),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                FadeSlideIn(
                  index: 12,
                  child: _ProfileLink(
                    icon: Icons.bookmark_border_rounded,
                    label: 'Watchlist',
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const WatchlistScreen()),
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}

class _FavoritesRow extends StatelessWidget {
  final List<FavoriteMovie> favorites;
  final VoidCallback onTap;

  const _FavoritesRow({required this.favorites, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Favorite Movies', style: AppTextStyles.h3),
            TextButton(
              onPressed: onTap,
              child: Text(
                favorites.isEmpty ? 'Add' : 'Edit',
                style: AppTextStyles.body.copyWith(color: AppColors.primaryAccent),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        // Always exactly 4 equal-width slots via Expanded, not a fixed
        // poster width in a scrolling row — so all 4 fit on any screen
        // width with no scrolling, and empty slots show a placeholder.
        Row(
          children: List.generate(4, (index) {
            final favorite = index < favorites.length ? favorites[index] : null;
            return Expanded(
              child: Padding(
                padding: EdgeInsets.only(right: index < 3 ? 10 : 0),
                child: GestureDetector(
                  onTap: onTap,
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: favorite != null ? AppShadows.card : null,
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: AspectRatio(
                        aspectRatio: 2 / 3,
                        child: favorite?.posterUrl != null
                            ? CachedNetworkImage(imageUrl: favorite!.posterUrl!, fit: BoxFit.cover)
                            : Container(
                                color: AppColors.surface,
                                child: favorite == null
                                    ? const Icon(Icons.add_rounded, color: AppColors.textSecondary)
                                    : null,
                              ),
                      ),
                    ),
                  ),
                ),
              ),
            );
          }),
        ),
      ],
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
          boxShadow: AppShadows.card,
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.primaryAccent.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: AppColors.primaryAccent, size: 18),
            ),
            const SizedBox(width: 12),
            Expanded(child: Text(label, style: AppTextStyles.body)),
            const Icon(Icons.chevron_right_rounded, color: AppColors.textSecondary),
          ],
        ),
      ),
    );
  }
}
