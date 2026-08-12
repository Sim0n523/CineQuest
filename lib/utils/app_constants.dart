class AppConstants {
  AppConstants._();

  // --- TMDB ---
  // Get a free key at https://www.themoviedb.org/settings/api
  static const String tmdbApiKey = '8fb06c7cadbf317c40320746d7d2d9cf';
  static const String tmdbBaseUrl = 'https://api.themoviedb.org/3';
  static const String tmdbImageBaseUrl = 'https://image.tmdb.org/t/p/w500';
  static const String tmdbBackdropBaseUrl = 'https://image.tmdb.org/t/p/original';

  // --- XP rewards (blueprint section 12) ---
  // Not wired to any reward flow yet — that's ProgressionService, Phase 3.
  static const int xpWatchMovie = 50;
  static const int xpReviewMovie = 20;
  static const int xpWeeklyQuest = 250;
  static const int xpMonthlyQuest = 500;
  static const int xpAchievementUnlock = 100;
  static const int xpCollectionComplete = 400;
}
