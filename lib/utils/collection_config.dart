import 'package:flutter/material.dart';

/// person was split into director/actor once the director-only bug was
/// found: /discover/movie's with_crew filter (the old implementation)
/// matches ANY crew role — producer, writer, editor — not just
/// directing, and TMDB's discover endpoint has no job-level filter at
/// all. Both new types instead go through /person/{id}/movie_credits
/// (see TMDBService.getMoviesDirectedByPerson / getMoviesActedInByPerson),
/// which returns job- and cast-tagged credits directly.
enum CollectionSourceType { tmdbCollection, studio, director, actor }

class CollectionDefinition {
  final String id;
  final String title;
  final String description;
  final CollectionSourceType sourceType;
  final String searchQuery;
  final IconData icon;

  const CollectionDefinition({
    required this.id,
    required this.title,
    required this.description,
    required this.sourceType,
    required this.searchQuery,
    required this.icon,
  });
}

/// A curated set of collections, resolved by NAME at runtime via TMDB's
/// search endpoints rather than hardcoded numeric IDs — avoids the risk
/// of a wrong/stale ID silently showing the wrong movies.
///
/// Three tracks: TMDB's own collection objects (franchises/trilogies),
/// studio filmography (Pixar), and person filmography split into
/// director (crew job = Director) and actor (top-billed cast, capped —
/// see TMDBService for why). Not here: anything needing data TMDB
/// doesn't have at all (IMDb rankings, Oscar/Palme d'Or wins) — that
/// would mean fabricating movie-ID lists rather than resolving real data.
/// Also not here: cross-franchise "theme" collections like "shark
/// movies" (Jaws + The Meg + Sharknado) — those don't map to a single
/// TMDB entity the way everything below does; would need a new
/// multi-query source type. Flagged, not built.
const List<CollectionDefinition> collectionDefinitions = [
  // --- Franchises / trilogies (TMDB collection objects) ---
  CollectionDefinition(
    id: 'star_wars',
    title: 'Star Wars',
    description: 'The Skywalker saga and beyond',
    sourceType: CollectionSourceType.tmdbCollection,
    searchQuery: 'Star Wars Collection',
    icon: Icons.rocket_launch_rounded,
  ),
  CollectionDefinition(
    id: 'harry_potter',
    title: 'Harry Potter',
    description: 'The Wizarding World film series',
    sourceType: CollectionSourceType.tmdbCollection,
    searchQuery: 'Harry Potter Collection',
    icon: Icons.auto_fix_high_rounded,
  ),
  CollectionDefinition(
    id: 'lord_of_the_rings',
    title: 'The Lord of the Rings',
    description: 'The trilogy that redefined fantasy film',
    sourceType: CollectionSourceType.tmdbCollection,
    searchQuery: 'The Lord of the Rings Collection',
    icon: Icons.landscape_rounded,
  ),
  CollectionDefinition(
    id: 'hobbit',
    title: 'The Hobbit',
    description: "Bilbo's prequel trilogy in Middle-earth",
    sourceType: CollectionSourceType.tmdbCollection,
    searchQuery: 'The Hobbit Collection',
    icon: Icons.explore_rounded,
  ),
  CollectionDefinition(
    id: 'jurassic_park',
    title: 'Jurassic Park',
    description: 'Dinosaurs, chaos theory, and bad decisions',
    sourceType: CollectionSourceType.tmdbCollection,
    searchQuery: 'Jurassic Park Collection',
    icon: Icons.pets_rounded,
  ),
  CollectionDefinition(
    id: 'fast_and_furious',
    title: 'Fast & Furious',
    description: 'Family, cars, and increasingly physics-defying heists',
    sourceType: CollectionSourceType.tmdbCollection,
    searchQuery: 'Fast & Furious Collection',
    icon: Icons.directions_car_rounded,
  ),
  CollectionDefinition(
    id: 'godfather',
    title: 'The Godfather',
    description: "Coppola's Corleone family saga",
    sourceType: CollectionSourceType.tmdbCollection,
    searchQuery: 'The Godfather Collection',
    icon: Icons.theater_comedy_rounded,
  ),

  // --- Studio ---
  CollectionDefinition(
    id: 'pixar',
    title: 'Pixar',
    description: 'Feature films from Pixar Animation Studios',
    sourceType: CollectionSourceType.studio,
    searchQuery: 'Pixar',
    icon: Icons.animation_rounded,
  ),

  // --- Directors ---
  CollectionDefinition(
    id: 'nolan',
    title: 'Christopher Nolan',
    description: 'The complete directing filmography',
    sourceType: CollectionSourceType.director,
    searchQuery: 'Christopher Nolan',
    icon: Icons.movie_creation_rounded,
  ),
  CollectionDefinition(
    id: 'tarantino',
    title: 'Quentin Tarantino',
    description: 'The complete directing filmography',
    sourceType: CollectionSourceType.director,
    searchQuery: 'Quentin Tarantino',
    icon: Icons.local_fire_department_rounded,
  ),
  CollectionDefinition(
    id: 'spielberg',
    title: 'Steven Spielberg',
    description: 'The complete directing filmography',
    sourceType: CollectionSourceType.director,
    searchQuery: 'Steven Spielberg',
    icon: Icons.videocam_rounded,
  ),
  CollectionDefinition(
    id: 'james_gunn',
    title: 'James Gunn',
    description: 'The complete directing filmography',
    sourceType: CollectionSourceType.director,
    searchQuery: 'James Gunn',
    icon: Icons.groups_rounded,
  ),

  // --- Actors ---
  CollectionDefinition(
    id: 'dicaprio',
    title: 'Leonardo DiCaprio',
    description: 'Top-billed starring roles',
    sourceType: CollectionSourceType.actor,
    searchQuery: 'Leonardo DiCaprio',
    icon: Icons.star_rounded,
  ),
  CollectionDefinition(
    id: 'samuel_l_jackson',
    title: 'Samuel L. Jackson',
    description: 'Top-billed starring roles',
    sourceType: CollectionSourceType.actor,
    searchQuery: 'Samuel L. Jackson',
    icon: Icons.record_voice_over_rounded,
  ),
  CollectionDefinition(
    id: 'ryan_gosling',
    title: 'Ryan Gosling',
    description: 'Top-billed starring roles',
    sourceType: CollectionSourceType.actor,
    searchQuery: 'Ryan Gosling',
    icon: Icons.face_rounded,
  ),
];
