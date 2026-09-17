import 'app_secrets.dart';

class AppConstants {
  AppConstants._();

  // --- TMDB ---
  // The real key lives in app_secrets.dart, which is gitignored — see
  // app_secrets.example.dart for setup instructions.
  static const String tmdbApiKey = AppSecrets.tmdbApiKey;
  static const String tmdbBaseUrl = 'https://api.themoviedb.org/3';
  static const String tmdbImageBaseUrl = 'https://image.tmdb.org/t/p/w500';
  static const String tmdbBackdropBaseUrl = 'https://image.tmdb.org/t/p/original';

  // --- XP rewards (see xp_config.dart for the level curve and
  // quest_config.dart for the actual quest values) ---
  static const int xpWatchMovie = 50;
  static const int xpReviewMovie = 20;
  // Reference values only — the real rewards live on each
  // QuestTemplate.xpReward in quest_config.dart.
  static const int xpWeeklyQuest = 250;
  static const int xpMonthlyQuest = 1000;
  static const int xpAchievementUnlock = 100;
  // Scales with collection size — see ProgressionService.checkCollectionCompletion.
  static const int xpCollectionBase = 500;
  static const int xpCollectionPerMovie = 50;
}
