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
  moviesWithPhotos,
  longMovies,
  classicMovies,
  weekendWatches,
  genreDevotion,
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

/// Data-driven achievement definitions — each category has multiple
/// tiers, computed from AchievementService against watch history.
///
/// Not implemented: Streaks (needs real date-boundary logic) and
/// Special Events (needs a product decision on what the events are).
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
    // Top tier is deliberately the literal total collection count (see
    // collection_config.dart), so "complete them all" is a real top-tier
    // feat rather than capping out early.
    tierThresholds: [2, 5, 10, 16, 24, 31],
  ),
  AchievementDefinition(
    category: AchievementCategory.moviesWithPhotos,
    title: 'Movie Memories',
    description: 'Attach a photo when logging a movie',
    icon: Icons.photo_camera_rounded,
    tierThresholds: [1, 3, 8, 15, 30, 60],
  ),
  AchievementDefinition(
    category: AchievementCategory.longMovies,
    title: 'Long Haul',
    description: 'Watch movies 150 minutes or longer',
    icon: Icons.hourglass_bottom_rounded,
    tierThresholds: [1, 5, 10, 20, 40, 75],
  ),
  AchievementDefinition(
    category: AchievementCategory.classicMovies,
    title: 'Old Hollywood',
    description: 'Watch movies released before 1980',
    icon: Icons.theaters_outlined,
    tierThresholds: [1, 3, 8, 15, 30, 50],
  ),
  AchievementDefinition(
    category: AchievementCategory.weekendWatches,
    title: 'Weekend Warrior',
    description: 'Watch movies on a Saturday or Sunday',
    icon: Icons.weekend_rounded,
    tierThresholds: [1, 5, 15, 30, 60, 100],
  ),
  AchievementDefinition(
    category: AchievementCategory.genreDevotion,
    title: 'Genre Devotee',
    description: 'Watch many movies from a single genre — the opposite of Genre Explorer',
    icon: Icons.favorite_rounded,
    tierThresholds: [3, 8, 15, 30, 50, 80],
  ),
];
