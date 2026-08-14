class LevelConfig {
  LevelConfig._();

  static const List<int> xpThresholds = [
    0, 100, 250, 450, 700, 1000, 1400, 1900, 2500, 3200,
  ];

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

  static int? xpForNextLevel(int currentLevel) {
    if (currentLevel >= xpThresholds.length) return null;
    return xpThresholds[currentLevel];
  }

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
