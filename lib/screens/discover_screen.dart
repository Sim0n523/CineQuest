import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/providers/movie_provider.dart';
import '../core/providers/load_status.dart';
import '../themes/app_colors.dart';
import '../themes/app_text_styles.dart';
import '../utils/discover_sort.dart';
import '../utils/genre_map.dart';
import '../widgets/movie_card.dart';
import '../widgets/loading_indicator.dart';
import 'movie_details_screen.dart';

/// Genuinely browsable, unlike Home's preview rows: filter by genre and
/// by sort order (Popular / Top Rated / Newest), both combinable via
/// TMDB's actual /discover/movie endpoint — e.g. top-rated horror.
class DiscoverScreen extends StatefulWidget {
  const DiscoverScreen({super.key});

  @override
  State<DiscoverScreen> createState() => _DiscoverScreenState();
}

class _DiscoverScreenState extends State<DiscoverScreen> {
  int? _selectedGenreId; // null = All genres
  DiscoverSort _selectedSort = DiscoverSort.popular;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  void _load() {
    context.read<MovieProvider>().loadDiscover(genreId: _selectedGenreId, sort: _selectedSort);
  }

  Widget _chip({required String label, required bool selected, required VoidCallback onTap}) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
        label: Text(label),
        selected: selected,
        onSelected: (_) => onTap(),
        selectedColor: AppColors.primaryAccent,
        backgroundColor: AppColors.surface,
        side: BorderSide.none,
        labelStyle: AppTextStyles.caption.copyWith(
          color: selected ? AppColors.background : AppColors.textSecondary,
          fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final movies = context.watch<MovieProvider>();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: Text('Discover', style: AppTextStyles.h2)),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 0, 0),
            child: SizedBox(
              height: 36,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: DiscoverSort.values.map((sort) {
                  return _chip(
                    label: sort.label,
                    selected: sort == _selectedSort,
                    onTap: () {
                      setState(() => _selectedSort = sort);
                      _load();
                    },
                  );
                }).toList(),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 0, 12),
            child: SizedBox(
              height: 34,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  _chip(
                    label: 'All',
                    selected: _selectedGenreId == null,
                    onTap: () {
                      setState(() => _selectedGenreId = null);
                      _load();
                    },
                  ),
                  ...tmdbGenreNames.entries.map(
                    (entry) => _chip(
                      label: entry.value,
                      selected: _selectedGenreId == entry.key,
                      onTap: () {
                        setState(() => _selectedGenreId = entry.key);
                        _load();
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
          Expanded(child: _buildGrid(movies)),
        ],
      ),
    );
  }

  Widget _buildGrid(MovieProvider movies) {
    if (movies.discoverStatus == LoadStatus.loading && movies.discoverResults.isEmpty) {
      return const LoadingIndicator();
    }
    if (movies.discoverStatus == LoadStatus.error && movies.discoverResults.isEmpty) {
      return Center(child: Text("Couldn't load movies", style: AppTextStyles.bodySecondary));
    }
    if (movies.discoverResults.isEmpty) {
      return Center(child: Text('No movies found for this filter', style: AppTextStyles.bodySecondary));
    }
    return GridView.builder(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 20,
        crossAxisSpacing: 16,
        childAspectRatio: 0.52,
      ),
      itemCount: movies.discoverResults.length,
      itemBuilder: (context, index) {
        final movie = movies.discoverResults[index];
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
