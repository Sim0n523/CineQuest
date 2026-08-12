import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/providers/auth_provider.dart';
import '../core/providers/movie_provider.dart';
import '../core/models/movie_model.dart';
import '../themes/app_colors.dart';
import '../themes/app_text_styles.dart';
import '../widgets/movie_card.dart';
import '../widgets/section_header.dart';
import '../widgets/loading_indicator.dart';
import 'movie_details_screen.dart';
import 'search_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<MovieProvider>().loadHome();
    });
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final movies = context.watch<MovieProvider>();
    final username = auth.currentUser?.username ?? 'Cinephile';

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: RefreshIndicator(
          color: AppColors.primaryAccent,
          backgroundColor: AppColors.surface,
          onRefresh: () => context.read<MovieProvider>().loadHome(),
          child: CustomScrollView(
            slivers: [
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                sliver: SliverToBoxAdapter(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Welcome back,', style: AppTextStyles.bodySecondary),
                          Text(username, style: AppTextStyles.h1),
                        ],
                      ),
                      IconButton(
                        icon: const Icon(Icons.search, color: AppColors.textPrimary),
                        onPressed: () => Navigator.of(context).push(
                          MaterialPageRoute(builder: (_) => const SearchScreen()),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SliverToBoxAdapter(child: SectionHeader(title: 'Trending This Week')),
              _buildMovieRow(movies.trending, movies.trendingStatus),
              const SliverToBoxAdapter(child: SectionHeader(title: 'Popular Right Now')),
              _buildMovieRow(movies.popular, movies.popularStatus),
              const SliverToBoxAdapter(child: SizedBox(height: 24)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMovieRow(List<MovieModel> movies, LoadStatus status) {
    if (status == LoadStatus.loading) {
      return const SliverToBoxAdapter(
        child: SizedBox(height: 240, child: LoadingIndicator()),
      );
    }
    if (status == LoadStatus.error) {
      return SliverToBoxAdapter(
        child: SizedBox(
          height: 240,
          child: Center(
            child: Text("Couldn't load movies", style: AppTextStyles.bodySecondary),
          ),
        ),
      );
    }
    return SliverToBoxAdapter(
      child: SizedBox(
        height: 240,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 20),
          itemCount: movies.length,
          separatorBuilder: (_, __) => const SizedBox(width: 12),
          itemBuilder: (context, index) {
            final movie = movies[index];
            return MovieCard(
              movie: movie,
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => MovieDetailsScreen(movieId: movie.id),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
