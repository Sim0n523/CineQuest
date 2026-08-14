import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../core/models/movie_model.dart';
import '../core/providers/movie_provider.dart';
import '../core/providers/auth_provider.dart';
import '../core/providers/watch_history_provider.dart';
import '../themes/app_colors.dart';
import '../themes/app_text_styles.dart';
import '../widgets/loading_indicator.dart';
import '../widgets/primary_button.dart';
import '../widgets/star_rating.dart';
import 'log_movie_screen.dart';

class MovieDetailsScreen extends StatefulWidget {
  final int movieId;

  const MovieDetailsScreen({super.key, required this.movieId});

  @override
  State<MovieDetailsScreen> createState() => _MovieDetailsScreenState();
}

class _MovieDetailsScreenState extends State<MovieDetailsScreen> {
  late Future<MovieModel> _future;

  @override
  void initState() {
    super.initState();
    _future = context.read<MovieProvider>().fetchMovieDetails(widget.movieId);
  }

  Future<void> _toggleWatchlist(MovieModel movie) async {
    final uid = context.read<AuthProvider>().currentUser?.uid;
    if (uid == null) return;
    final history = context.read<WatchHistoryProvider>();
    if (history.isOnWatchlist(movie.id)) {
      await history.removeFromWatchlist(uid, movie.id);
    } else {
      await history.addToWatchlist(uid, movie);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: FutureBuilder<MovieModel>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const LoadingIndicator();
          }
          if (snapshot.hasError || !snapshot.hasData) {
            return Center(
              child: Text('Could not load this movie', style: AppTextStyles.bodySecondary),
            );
          }
          return _buildContent(snapshot.data!);
        },
      ),
    );
  }

  Widget _buildContent(MovieModel movie) {
    final history = context.watch<WatchHistoryProvider>();
    final isLogged = history.isLogged(movie.id);
    final isOnWatchlist = history.isOnWatchlist(movie.id);
    final existingEntry = history.entryForMovie(movie.id);
    final isUpcoming = movie.releaseDate != null && movie.releaseDate!.isAfter(DateTime.now());

    return CustomScrollView(
      slivers: [
        SliverAppBar(
          backgroundColor: AppColors.background,
          expandedHeight: 320,
          pinned: true,
          actions: [
            if (!isLogged && !isUpcoming)
              IconButton(
                icon: Icon(
                  isOnWatchlist ? Icons.bookmark_rounded : Icons.bookmark_border_rounded,
                  color: AppColors.primaryAccent,
                ),
                onPressed: () => _toggleWatchlist(movie),
              ),
          ],
          flexibleSpace: FlexibleSpaceBar(
            background: movie.backdropUrl != null
                ? Stack(
                    fit: StackFit.expand,
                    children: [
                      CachedNetworkImage(imageUrl: movie.backdropUrl!, fit: BoxFit.cover),
                      const DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [Colors.transparent, AppColors.background],
                          ),
                        ),
                      ),
                    ],
                  )
                : Container(color: AppColors.surface),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.all(20),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              Text(movie.title, style: AppTextStyles.h1),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.star_rounded, color: AppColors.primaryAccent, size: 18),
                  const SizedBox(width: 4),
                  Text(movie.voteAverage.toStringAsFixed(1), style: AppTextStyles.body),
                  if (movie.releaseDate != null) ...[
                    const SizedBox(width: 16),
                    Text('${movie.releaseDate!.year}', style: AppTextStyles.bodySecondary),
                  ],
                  if (movie.runtime != null) ...[
                    const SizedBox(width: 16),
                    Text('${movie.runtime} min', style: AppTextStyles.bodySecondary),
                  ],
                ],
              ),
              const SizedBox(height: 20),
              Text('Overview', style: AppTextStyles.h3),
              const SizedBox(height: 8),
              Text(
                movie.overview.isNotEmpty ? movie.overview : 'No overview available.',
                style: AppTextStyles.bodySecondary,
              ),
              const SizedBox(height: 28),
              if (isLogged && existingEntry != null) ...[
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.check_circle_rounded, color: AppColors.success, size: 18),
                          const SizedBox(width: 6),
                          Text('You logged this', style: AppTextStyles.body),
                        ],
                      ),
                      const SizedBox(height: 10),
                      StarRating(rating: existingEntry.rating ?? 0, size: 20),
                      if ((existingEntry.review ?? '').isNotEmpty) ...[
                        const SizedBox(height: 10),
                        Text(existingEntry.review!, style: AppTextStyles.bodySecondary),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 16),
              ],
              if (isUpcoming) ...[
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.event_available_rounded, color: AppColors.xp),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          "Not released yet — add it to your watchlist and log it once it's out.",
                          style: AppTextStyles.bodySecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
              ],
              if (isUpcoming)
                PrimaryButton(
                  label: isOnWatchlist ? 'On Your Watchlist ✓' : 'Add to Watchlist',
                  onPressed: () => _toggleWatchlist(movie),
                )
              else
                PrimaryButton(
                  label: isLogged ? 'Edit Your Log' : 'Log This Movie',
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => LogMovieScreen(movie: movie, existingEntry: existingEntry),
                    ),
                  ),
                ),
              const SizedBox(height: 20),
            ]),
          ),
        ),
      ],
    );
  }
}
