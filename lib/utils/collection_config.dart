import 'package:flutter/material.dart';

/// person sources are split into director/actor since TMDB's discover
/// endpoint has no job-level filter — both go through
/// /person/{id}/movie_credits instead (see TMDBService).
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
/// studio filmography, and person filmography split into director and
/// actor (see TMDBService). Not supported: anything TMDB has no data
/// for (e.g. award wins), or cross-franchise "theme" collections that
/// don't map to a single TMDB entity.
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

  // --- More franchises ---
  CollectionDefinition(
    id: 'the_matrix',
    title: 'The Matrix',
    description: 'The Wachowskis\' cyberpunk saga',
    sourceType: CollectionSourceType.tmdbCollection,
    searchQuery: 'The Matrix Collection',
    icon: Icons.code_rounded,
  ),
  CollectionDefinition(
    id: 'indiana_jones',
    title: 'Indiana Jones',
    description: "Archaeology's least cautious professor",
    sourceType: CollectionSourceType.tmdbCollection,
    searchQuery: 'Indiana Jones Collection',
    icon: Icons.map_rounded,
  ),
  CollectionDefinition(
    id: 'john_wick',
    title: 'John Wick',
    description: 'Excommunicado, repeatedly',
    sourceType: CollectionSourceType.tmdbCollection,
    searchQuery: 'John Wick Collection',
    icon: Icons.sports_martial_arts_rounded,
  ),
  CollectionDefinition(
    id: 'mission_impossible',
    title: 'Mission: Impossible',
    description: 'Ethan Hunt vs. gravity, repeatedly',
    sourceType: CollectionSourceType.tmdbCollection,
    searchQuery: 'Mission: Impossible Collection',
    icon: Icons.security_rounded,
  ),
  CollectionDefinition(
    id: 'alien',
    title: 'Alien',
    description: "In space, no one can hear you complete a collection",
    sourceType: CollectionSourceType.tmdbCollection,
    searchQuery: 'Alien Collection',
    icon: Icons.bug_report_rounded,
  ),
  CollectionDefinition(
    id: 'toy_story',
    title: 'Toy Story',
    description: "Pixar's flagship saga",
    sourceType: CollectionSourceType.tmdbCollection,
    searchQuery: 'Toy Story Collection',
    icon: Icons.toys_rounded,
  ),
  CollectionDefinition(
    id: 'back_to_the_future',
    title: 'Back to the Future',
    description: '1.21 gigawatts of trilogy',
    sourceType: CollectionSourceType.tmdbCollection,
    searchQuery: 'Back to the Future Collection',
    icon: Icons.history_toggle_off_rounded,
  ),
  CollectionDefinition(
    id: 'terminator',
    title: 'Terminator',
    description: "Skynet's ongoing filmography",
    sourceType: CollectionSourceType.tmdbCollection,
    searchQuery: 'The Terminator Collection',
    icon: Icons.smart_toy_rounded,
  ),

  // --- More directors ---
  CollectionDefinition(
    id: 'villeneuve',
    title: 'Denis Villeneuve',
    description: 'The complete directing filmography',
    sourceType: CollectionSourceType.director,
    searchQuery: 'Denis Villeneuve',
    icon: Icons.blur_on_rounded,
  ),
  CollectionDefinition(
    id: 'scorsese',
    title: 'Martin Scorsese',
    description: 'The complete directing filmography',
    sourceType: CollectionSourceType.director,
    searchQuery: 'Martin Scorsese',
    icon: Icons.local_bar_rounded,
  ),
  CollectionDefinition(
    id: 'gerwig',
    title: 'Greta Gerwig',
    description: 'The complete directing filmography',
    sourceType: CollectionSourceType.director,
    searchQuery: 'Greta Gerwig',
    icon: Icons.palette_rounded,
  ),
  CollectionDefinition(
    id: 'wes_anderson',
    title: 'Wes Anderson',
    description: 'The complete directing filmography',
    sourceType: CollectionSourceType.director,
    searchQuery: 'Wes Anderson',
    icon: Icons.color_lens_rounded,
  ),

  // --- More actors ---
  CollectionDefinition(
    id: 'tom_hanks',
    title: 'Tom Hanks',
    description: 'Top-billed starring roles',
    sourceType: CollectionSourceType.actor,
    searchQuery: 'Tom Hanks',
    icon: Icons.flight_rounded,
  ),
  CollectionDefinition(
    id: 'cillian_murphy',
    title: 'Cillian Murphy',
    description: 'Top-billed starring roles',
    sourceType: CollectionSourceType.actor,
    searchQuery: 'Cillian Murphy',
    icon: Icons.remove_red_eye_rounded,
  ),
  CollectionDefinition(
    id: 'zendaya',
    title: 'Zendaya',
    description: 'Top-billed starring roles',
    sourceType: CollectionSourceType.actor,
    searchQuery: 'Zendaya',
    icon: Icons.auto_awesome_rounded,
  ),
  CollectionDefinition(
    id: 'meryl_streep',
    title: 'Meryl Streep',
    description: 'Top-billed starring roles',
    sourceType: CollectionSourceType.actor,
    searchQuery: 'Meryl Streep',
    icon: Icons.emoji_events_rounded,
  ),
];
