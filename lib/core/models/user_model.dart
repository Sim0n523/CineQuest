import 'favorite_movie.dart';

class UserModel {
  final String uid;
  final String username;
  final String email;

  // Lowercased copy of username, used only for Find Friends' prefix
  // search — Firestore's orderBy/startAt is case-sensitive, so
  // searching raw `username` would miss most real queries. Backfilled
  // on login for older accounts (see AuthProvider._onAuthChanged).
  final String usernameLower;

  // A small (~240px) image stored directly on this document rather
  // than a URL — see utils/image_compression.dart for why.
  final String? avatarBase64;

  final int xp;
  final int level;
  final DateTime createdAt;

  final int moviesWatched;
  final int reviewsWritten;
  final int currentStreak;
  final int longestStreak;
  final int achievementsUnlocked;
  final int collectionsCompleted;

  // Up to 4, ordered — see EditFavoritesScreen for the picker UI.
  final List<FavoriteMovie> favoriteMovies;

  const UserModel({
    required this.uid,
    required this.username,
    required this.email,
    String? usernameLower,
    this.avatarBase64,
    this.xp = 0,
    this.level = 1,
    required this.createdAt,
    this.moviesWatched = 0,
    this.reviewsWritten = 0,
    this.currentStreak = 0,
    this.longestStreak = 0,
    this.achievementsUnlocked = 0,
    this.collectionsCompleted = 0,
    this.favoriteMovies = const [],
  }) : usernameLower = usernameLower ?? '';

  factory UserModel.fromMap(String uid, Map<String, dynamic> map) {
    final favoritesData = map['favoriteMovies'] as List? ?? const [];
    final username = map['username'] as String? ?? 'Cinephile';
    return UserModel(
      uid: uid,
      username: username,
      email: map['email'] as String? ?? '',
      usernameLower: (map['usernameLower'] as String?) ?? username.toLowerCase(),
      avatarBase64: map['avatarBase64'] as String?,
      xp: map['xp'] as int? ?? 0,
      level: map['level'] as int? ?? 1,
      createdAt: map['createdAt'] != null
          ? (DateTime.tryParse(map['createdAt'] as String) ?? DateTime.now())
          : DateTime.now(),
      moviesWatched: map['moviesWatched'] as int? ?? 0,
      reviewsWritten: map['reviewsWritten'] as int? ?? 0,
      currentStreak: map['currentStreak'] as int? ?? 0,
      longestStreak: map['longestStreak'] as int? ?? 0,
      achievementsUnlocked: map['achievementsUnlocked'] as int? ?? 0,
      collectionsCompleted: map['collectionsCompleted'] as int? ?? 0,
      favoriteMovies: favoritesData
          .map((f) => FavoriteMovie.fromMap(f as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'username': username,
      'usernameLower': usernameLower,
      'email': email,
      'avatarBase64': avatarBase64,
      'xp': xp,
      'level': level,
      'createdAt': createdAt.toIso8601String(),
      'moviesWatched': moviesWatched,
      'reviewsWritten': reviewsWritten,
      'currentStreak': currentStreak,
      'longestStreak': longestStreak,
      'achievementsUnlocked': achievementsUnlocked,
      'collectionsCompleted': collectionsCompleted,
      'favoriteMovies': favoriteMovies.map((f) => f.toMap()).toList(),
    };
  }

  UserModel copyWith({
    String? username,
    String? avatarBase64,
    int? xp,
    int? level,
    int? moviesWatched,
    int? reviewsWritten,
    int? currentStreak,
    int? longestStreak,
    int? achievementsUnlocked,
    int? collectionsCompleted,
    List<FavoriteMovie>? favoriteMovies,
  }) {
    return UserModel(
      uid: uid,
      username: username ?? this.username,
      email: email,
      usernameLower: username != null ? username.toLowerCase() : usernameLower,
      avatarBase64: avatarBase64 ?? this.avatarBase64,
      xp: xp ?? this.xp,
      level: level ?? this.level,
      createdAt: createdAt,
      moviesWatched: moviesWatched ?? this.moviesWatched,
      reviewsWritten: reviewsWritten ?? this.reviewsWritten,
      currentStreak: currentStreak ?? this.currentStreak,
      longestStreak: longestStreak ?? this.longestStreak,
      achievementsUnlocked: achievementsUnlocked ?? this.achievementsUnlocked,
      collectionsCompleted: collectionsCompleted ?? this.collectionsCompleted,
      favoriteMovies: favoriteMovies ?? this.favoriteMovies,
    );
  }
}
