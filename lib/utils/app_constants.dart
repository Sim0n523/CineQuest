class AppConstants {
  AppConstants._();

  // --- TMDB ---
  static const String tmdbApiKey = '8fb06c7cadbf317c40320746d7d2d9cf';
  static const String tmdbBaseUrl = 'https://api.themoviedb.org/3';
  static const String tmdbImageBaseUrl = 'https://image.tmdb.org/t/p/w500';
  static const String tmdbBackdropBaseUrl = 'https://image.tmdb.org/t/p/original';

  // --- XP rewards (blueprint section 12, since reworked — see xp_config.dart
  // for the level curve and quest_config.dart for the actual quest values) ---
  static const int xpWatchMovie = 50;
  static const int xpReviewMovie = 20;
  // xpWeeklyQuest / xpMonthlyQuest are reference values only — the real
  // rewards live on each QuestTemplate.xpReward in quest_config.dart.
  static const int xpWeeklyQuest = 250;
  static const int xpMonthlyQuest = 1000;
  static const int xpAchievementUnlock = 100;
  // Collection completion is no longer a flat reward — small collections
  // (Lord of the Rings) shouldn't pay the same as large ones (Pixar).
  // ProgressionService.checkCollectionCompletion computes
  // xpCollectionBase + xpCollectionPerMovie * (movies in the collection).
  static const int xpCollectionBase = 500;
  static const int xpCollectionPerMovie = 50;
}
