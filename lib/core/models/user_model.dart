/// Mirrors the Firestore `users/{uid}` document (blueprint section 19):
/// auth info, XP/level, and the denormalized stats shown on the profile.
///
/// XP/level/stats all start at zero on registration. Nothing writes to
/// them yet — that's ProgressionService's job starting in Phase 3.
class UserModel {
  final String uid;
  final String username;
  final String email;
  final String? avatarUrl;
  final int xp;
  final int level;
  final DateTime createdAt;

  // Denormalized stats (blueprint section 17), kept on the user document
  // so the profile and leaderboard can be read without extra queries.
  final int moviesWatched;
  final int reviewsWritten;
  final int currentStreak;
  final int longestStreak;
  final int achievementsUnlocked;
  final int collectionsCompleted;

  const UserModel({
    required this.uid,
    required this.username,
    required this.email,
    this.avatarUrl,
    this.xp = 0,
    this.level = 1,
    required this.createdAt,
    this.moviesWatched = 0,
    this.reviewsWritten = 0,
    this.currentStreak = 0,
    this.longestStreak = 0,
    this.achievementsUnlocked = 0,
    this.collectionsCompleted = 0,
  });

  factory UserModel.fromMap(String uid, Map<String, dynamic> map) {
    return UserModel(
      uid: uid,
      username: map['username'] as String? ?? 'Cinephile',
      email: map['email'] as String? ?? '',
      avatarUrl: map['avatarUrl'] as String?,
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
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'username': username,
      'email': email,
      'avatarUrl': avatarUrl,
      'xp': xp,
      'level': level,
      'createdAt': createdAt.toIso8601String(),
      'moviesWatched': moviesWatched,
      'reviewsWritten': reviewsWritten,
      'currentStreak': currentStreak,
      'longestStreak': longestStreak,
      'achievementsUnlocked': achievementsUnlocked,
      'collectionsCompleted': collectionsCompleted,
    };
  }

  UserModel copyWith({
    String? username,
    String? avatarUrl,
    int? xp,
    int? level,
    int? moviesWatched,
    int? reviewsWritten,
    int? currentStreak,
    int? longestStreak,
    int? achievementsUnlocked,
    int? collectionsCompleted,
  }) {
    return UserModel(
      uid: uid,
      username: username ?? this.username,
      email: email,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      xp: xp ?? this.xp,
      level: level ?? this.level,
      createdAt: createdAt,
      moviesWatched: moviesWatched ?? this.moviesWatched,
      reviewsWritten: reviewsWritten ?? this.reviewsWritten,
      currentStreak: currentStreak ?? this.currentStreak,
      longestStreak: longestStreak ?? this.longestStreak,
      achievementsUnlocked: achievementsUnlocked ?? this.achievementsUnlocked,
      collectionsCompleted: collectionsCompleted ?? this.collectionsCompleted,
    );
  }
}
