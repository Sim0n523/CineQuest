class LeaderboardEntry {
  final String uid;
  final String username;
  final String? avatarBase64;
  final int level;
  final int xp;
  final int rank;

  const LeaderboardEntry({
    required this.uid,
    required this.username,
    this.avatarBase64,
    required this.level,
    required this.xp,
    required this.rank,
  });

  factory LeaderboardEntry.fromMap(String uid, Map<String, dynamic> map, {required int rank}) {
    return LeaderboardEntry(
      uid: uid,
      username: map['username'] as String? ?? 'Cinephile',
      avatarBase64: map['avatarBase64'] as String?,
      level: map['level'] as int? ?? 1,
      xp: map['xp'] as int? ?? 0,
      rank: rank,
    );
  }
}
