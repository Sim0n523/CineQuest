import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/providers/movie_provider.dart';
import '../core/models/movie_model.dart';
import '../themes/app_colors.dart';
import '../themes/app_text_styles.dart';
import '../widgets/movie_card.dart';
import '../widgets/loading_indicator.dart';
import 'movie_details_screen.dart';

class DiscoverScreen extends StatefulWidget {
  const DiscoverScreen({super.key});

  @override
  State<DiscoverScreen> createState() => _DiscoverScreenState();
}

class _DiscoverScreenState extends State<DiscoverScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<MovieProvider>();
      // Avoid a duplicate fetch if Home already populated this list.
      if (provider.popular.isEmpty) provider.loadHome();
    });
  }

  @override
  Widget build(BuildContext context) {
    final movies = context.watch<MovieProvider>();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: Text('Discover', style: AppTextStyles.h2)),
      body: _buildBody(movies),
    );
  }

  Widget _buildBody(MovieProvider movies) {
    if (movies.popularStatus == LoadStatus.loading && movies.popular.isEmpty) {
      return const LoadingIndicator();
    }
    if (movies.popularStatus == LoadStatus.error && movies.popular.isEmpty) {
      return Center(
        child: Text("Couldn't load movies", style: AppTextStyles.bodySecondary),
      );
    }
    return GridView.builder(
      padding: const EdgeInsets.all(20),
      // childAspectRatio kept generous so the poster + title + rating
      // block never overflows the cell across a range of phone widths.
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 20,
        crossAxisSpacing: 16,
        childAspectRatio: 0.52,
      ),
      itemCount: movies.popular.length,
      itemBuilder: (context, index) {
        final MovieModel movie = movies.popular[index];
        return MovieCard(
          movie: movie,
          expand: true,
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => MovieDetailsScreen(movieId: movie.id)),
          ),
        );
      },
    );
  }
}
