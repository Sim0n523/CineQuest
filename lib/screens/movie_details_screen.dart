import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../core/models/movie_model.dart';
import '../core/providers/movie_provider.dart';
import '../themes/app_colors.dart';
import '../themes/app_text_styles.dart';
import '../widgets/loading_indicator.dart';
import '../widgets/primary_button.dart';

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
    // Goes through MovieProvider (not straight to MovieRepository) so
    // data fetching stays in the provider layer, per the blueprint's
    // "business logic stays in Services and Providers" rule.
    _future = context.read<MovieProvider>().fetchMovieDetails(widget.movieId);
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
    return CustomScrollView(
      slivers: [
        SliverAppBar(
          backgroundColor: AppColors.background,
          expandedHeight: 320,
          pinned: true,
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
              PrimaryButton(
                label: 'Log This Movie',
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Movie logging arrives in Phase 2 🎬'),
                      backgroundColor: AppColors.card,
                    ),
                  );
                },
              ),
              const SizedBox(height: 20),
            ]),
          ),
        ),
      ],
    );
  }
}
