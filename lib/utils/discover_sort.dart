/// The sort/category options shown as chips on the Discover screen.
/// Each maps to a TMDB /discover/movie `sort_by` value.
enum DiscoverSort { popular, topRated, newest, upcoming }

extension DiscoverSortLabel on DiscoverSort {
  String get label => switch (this) {
        DiscoverSort.popular => 'Popular',
        DiscoverSort.topRated => 'Top Rated',
        DiscoverSort.newest => 'Newest',
        DiscoverSort.upcoming => 'Upcoming',
      };

  String get apiValue => switch (this) {
        DiscoverSort.popular => 'popularity.desc',
        DiscoverSort.topRated => 'vote_average.desc',
        DiscoverSort.newest => 'primary_release_date.desc',
        DiscoverSort.upcoming => 'primary_release_date.asc',
      };
}
