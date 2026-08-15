class LeaderboardEntry {
  final String uid;
  final String username;
  final String? avatarUrl;
  final int level;
  final int xp;
  final int rank;

  const LeaderboardEntry({
    required this.uid,
    required this.username,
    this.avatarUrl,
    required this.level,
    required this.xp,
    required this.rank,
  });

  factory LeaderboardEntry.fromMap(String uid, Map<String, dynamic> map, {required int rank}) {
    return LeaderboardEntry(
      uid: uid,
      username: map['username'] as String? ?? 'Cinephile',
      avatarUrl: map['avatarUrl'] as String?,
      level: map['level'] as int? ?? 1,
      xp: map['xp'] as int? ?? 0,
      rank: rank,
    );
  }
}
