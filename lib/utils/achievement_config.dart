import 'package:flutter/material.dart';

enum AchievementCategory {
  moviesWatched,
  reviewsWritten,
  genresExplored,
  hoursWatched,
  cinemaVisits,
  decadesWatched,
  fiveStarRatings,
  directorsExplored,
  actorsExplored,
  collectionsCompleted,
}

class AchievementDefinition {
  final AchievementCategory category;
  final String title;
  final String description;
  final IconData icon;
  final List<int> tierThresholds;

  const AchievementDefinition({
    required this.category,
    required this.title,
    required this.description,
    required this.icon,
    required this.tierThresholds,
  });
}

/// Data-driven achievement definitions, per blueprint section 14 ("data
/// driven whenever possible") and modeled on Clash Royale Masteries —
/// each has multiple tiers. Movies Watched matches the blueprint's own
/// example thresholds exactly (1/10/50/100/250/500); the rest follow
/// the same spirit.
///
/// 10 of the blueprint's 11 categories are here now (fiveStarRatings,
/// directorsExplored, actorsExplored, collectionsCompleted are all
/// post-launch additions, not from the original 11 — user ideas during
/// a later polish pass). directorsExplored/actorsExplored needed
/// WatchHistoryEntry extended with director/lead-actor attribution
/// (snapshotted from MovieModel at log time — see TMDBService.getMovieDetails'
/// append_to_response=credits); collectionsCompleted needed the
/// achievement-check loop pulled out of ProgressionService.processMovieLogged
/// into something checkCollectionCompletion could call too, since that's
/// the only place this category's value actually changes. Still not
/// built:
/// - Streaks — real date-boundary logic, deferred since Phase 2.
/// - Special Events — needs a product decision on what the events are
///   before it can be data-driven at all.
const List<AchievementDefinition> achievementDefinitions = [
  AchievementDefinition(
    category: AchievementCategory.moviesWatched,
    title: 'Movies Watched',
    description: "Log movies you've watched",
    icon: Icons.movie_rounded,
    tierThresholds: [1, 10, 50, 100, 250, 500],
  ),
  AchievementDefinition(
    category: AchievementCategory.reviewsWritten,
    title: 'Critic',
    description: 'Write reviews for movies you log',
    icon: Icons.rate_review_rounded,
    tierThresholds: [1, 5, 15, 30, 75, 150],
  ),
  AchievementDefinition(
    category: AchievementCategory.genresExplored,
    title: 'Genre Explorer',
    description: 'Watch movies across different genres',
    icon: Icons.category_rounded,
    tierThresholds: [3, 6, 9, 12, 15, 19],
  ),
  AchievementDefinition(
    category: AchievementCategory.hoursWatched,
    title: 'Marathoner',
    description: 'Rack up hours of watch time',
    icon: Icons.timer_rounded,
    tierThresholds: [10, 50, 100, 250, 500, 1000],
  ),
  AchievementDefinition(
    category: AchievementCategory.cinemaVisits,
    title: 'On the Big Screen',
    description: 'Log movies watched at a cinema',
    icon: Icons.theaters_rounded,
    tierThresholds: [1, 5, 10, 25, 50, 100],
  ),
  AchievementDefinition(
    category: AchievementCategory.decadesWatched,
    title: 'Time Traveler',
    description: 'Watch movies spanning different decades',
    icon: Icons.public_rounded,
    tierThresholds: [2, 3, 4, 5, 6, 7],
  ),
  AchievementDefinition(
    category: AchievementCategory.fiveStarRatings,
    title: 'Five-Star Fanatic',
    description: 'Rate movies the full five stars',
    icon: Icons.star_rounded,
    tierThresholds: [1, 5, 10, 25, 50, 100],
  ),
  AchievementDefinition(
    category: AchievementCategory.directorsExplored,
    title: 'Behind the Camera',
    description: 'Watch movies from different directors',
    icon: Icons.movie_creation_rounded,
    tierThresholds: [3, 8, 15, 25, 40, 60],
  ),
  AchievementDefinition(
    category: AchievementCategory.actorsExplored,
    title: 'Star Power',
    description: 'Watch movies with different leading actors',
    icon: Icons.theater_comedy_rounded,
    tierThresholds: [3, 8, 15, 30, 50, 75],
  ),
  AchievementDefinition(
    category: AchievementCategory.collectionsCompleted,
    title: 'Collector',
    description: 'Complete curated movie collections',
    icon: Icons.collections_bookmark_rounded,
    // Deliberately modest — there are 15 collections total right now
    // (see collection_config.dart). Revisit these if that count grows a
    // lot; completing "all of them" should stay a real top-tier feat,
    // not something that caps out with room to spare.
    tierThresholds: [1, 3, 5, 8, 12, 15],
  ),
];
