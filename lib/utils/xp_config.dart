/// XP required to reach each level, stored as data rather than derived
/// from a formula — per blueprint section 13, so balancing is just
/// editing this list, with no logic changes needed.
///
/// Not used by any reward flow yet (Levels are Phase 3). It lives here
/// now because UserModel needs a level from the moment someone
/// registers, and it seemed better to define the shape once than
/// migrate it later.
class LevelConfig {
  LevelConfig._();

  /// Index 0 = XP needed for Level 1, index 1 = Level 2, and so on.
  /// Early levels are cheap; the gap widens later, per the blueprint's
  /// "early levels quick, late levels slower" instruction.
  static const List<int> xpThresholds = [
    0, // Level 1
    100, // Level 2
    250, // Level 3
    450, // Level 4
    700, // Level 5
    1000, // Level 6
    1400, // Level 7
    1900, // Level 8
    2500, // Level 9
    3200, // Level 10
    // Add more entries to extend progression — no code changes required.
  ];

  /// Derives the current level from total XP.
  static int levelForXp(int totalXp) {
    int level = 1;
    for (int i = 0; i < xpThresholds.length; i++) {
      if (totalXp >= xpThresholds[i]) {
        level = i + 1;
      } else {
        break;
      }
    }
    return level;
  }

  /// XP threshold for the next level, or null if already at the highest
  /// configured level.
  static int? xpForNextLevel(int currentLevel) {
    if (currentLevel >= xpThresholds.length) return null;
    return xpThresholds[currentLevel];
  }

  /// Progress toward the next level, from 0.0 to 1.0 — handy for an
  /// XPBar widget once one exists.
  static double progressToNextLevel(int totalXp) {
    final level = levelForXp(totalXp);
    if (level >= xpThresholds.length) return 1.0;
    final currentThreshold = xpThresholds[level - 1];
    final nextThreshold = xpThresholds[level];
    final span = nextThreshold - currentThreshold;
    if (span <= 0) return 1.0;
    return ((totalXp - currentThreshold) / span).clamp(0.0, 1.0);
  }
}
