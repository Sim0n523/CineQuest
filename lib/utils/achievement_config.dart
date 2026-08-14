import 'package:flutter/material.dart';

enum AchievementCategory {
  moviesWatched,
  reviewsWritten,
  genresExplored,
  hoursWatched,
  cinemaVisits,
  decadesWatched,
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
/// Only 6 of the blueprint's 11 categories are here. Not built yet:
/// - Directors, Actors — need TMDB's /movie/{id}/credits endpoint,
///   which nothing fetches today.
/// - Collections — its own system with genuinely different data
///   sources per collection (TMDB collections vs. studio filmography
///   vs. awards data), deserves a dedicated pass.
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
];
