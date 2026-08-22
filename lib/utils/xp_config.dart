/// Level curve — formula-based, no fixed cap.
///
/// Levels 1-5 keep the app's original early-game pace (+50 XP per level:
/// 100, 150, 200, 250, 300 to go from one level to the next). From level
/// 6 onward the climb is deliberately steeper — each level costs 250 XP
/// more than the last, forever, rather than the array running out at
/// level 10 the way it used to. There's always a next level; nothing
/// caps out.
class LevelConfig {
  LevelConfig._();

  /// XP required to go from [level] to [level] + 1.
  static int _costForLevel(int level) {
    if (level <= 5) return 50 * level + 50;
    return 300 + 250 * (level - 5);
  }

  /// Total XP needed to REACH [level] (i.e. the XP value at which that
  /// level begins). Level 1 begins at 0 XP by definition.
  static int xpForLevel(int level) {
    if (level <= 1) return 0;
    var total = 0;
    for (var n = 1; n < level; n++) {
      total += _costForLevel(n);
    }
    return total;
  }

  static int levelForXp(int totalXp) {
    var level = 1;
    var threshold = 0;
    while (true) {
      final nextThreshold = threshold + _costForLevel(level);
      if (nextThreshold > totalXp) break;
      threshold = nextThreshold;
      level++;
    }
    return level;
  }

  /// XP value at which [currentLevel] + 1 begins. Always defined now —
  /// there's no more "null means max level" case.
  static int xpForNextLevel(int currentLevel) => xpForLevel(currentLevel + 1);

  static double progressToNextLevel(int totalXp) {
    final level = levelForXp(totalXp);
    final currentThreshold = xpForLevel(level);
    final nextThreshold = xpForLevel(level + 1);
    final span = nextThreshold - currentThreshold;
    if (span <= 0) return 1.0;
    return ((totalXp - currentThreshold) / span).clamp(0.0, 1.0);
  }
}
