import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../core/providers/movie_provider.dart';
import '../core/providers/load_status.dart';
import '../core/models/movie_model.dart';
import '../themes/app_colors.dart';
import '../themes/app_text_styles.dart';
import '../widgets/skeleton_loaders.dart';
import '../widgets/fade_slide_in.dart';
import 'movie_details_screen.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final movies = context.watch<MovieProvider>();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        title: TextField(
          controller: _controller,
          autofocus: true,
          style: AppTextStyles.body,
          cursorColor: AppColors.primaryAccent,
          decoration: const InputDecoration(
            hintText: 'Search movies...',
            border: InputBorder.none,
          ),
          onChanged: (value) => context.read<MovieProvider>().search(value),
        ),
      ),
      body: _buildBody(movies),
    );
  }

  Widget _buildBody(MovieProvider movies) {
    if (movies.searchStatus == LoadStatus.initial) {
      return Center(
        child: Text('Search for a movie to get started', style: AppTextStyles.bodySecondary),
      );
    }
    if (movies.searchStatus == LoadStatus.loading) {
      return const MovieTileListSkeleton();
    }
    if (movies.searchStatus == LoadStatus.error) {
      return Center(
        child: Text('Something went wrong. Try again.', style: AppTextStyles.bodySecondary),
      );
    }
    if (movies.searchResults.isEmpty) {
      return Center(
        child: Text('No movies found', style: AppTextStyles.bodySecondary),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: movies.searchResults.length,
      itemBuilder: (context, index) {
        final MovieModel movie = movies.searchResults[index];
        return FadeSlideIn(
          index: index,
          child: ListTile(
            leading: Hero(
              tag: 'movie_hero_${movie.id}',
              child: ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: SizedBox(
                  width: 46,
                  height: 69,
                  child: movie.posterUrl != null
                      ? CachedNetworkImage(imageUrl: movie.posterUrl!, fit: BoxFit.cover)
                      : Container(color: AppColors.card),
                ),
              ),
            ),
            title: Text(movie.title, style: AppTextStyles.body),
            subtitle: Text(
              movie.releaseDate != null ? '${movie.releaseDate!.year}' : 'Unknown year',
              style: AppTextStyles.caption,
            ),
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => MovieDetailsScreen(movieId: movie.id, seed: movie)),
            ),
          ),
        );
      },
    );
  }
}
