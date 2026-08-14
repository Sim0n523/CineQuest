import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/watch_history_entry.dart';
import '../../utils/app_constants.dart';
import '../../utils/xp_config.dart';
import '../../utils/achievement_config.dart';
import 'achievement_service.dart';

class UnlockedAchievement {
  final AchievementDefinition definition;
  final int tier;
  const UnlockedAchievement({required this.definition, required this.tier});
}

class ProgressionResult {
  final int xpGained;
  final int newXp;
  final int newLevel;
  final bool leveledUp;
  final int totalAchievementsUnlocked;
  final List<UnlockedAchievement> newlyUnlockedAchievements;

  const ProgressionResult({
    required this.xpGained,
    required this.newXp,
    required this.newLevel,
    required this.leveledUp,
    required this.totalAchievementsUnlocked,
    required this.newlyUnlockedAchievements,
  });
}

/// Owns everything that happens when a movie gets logged for the first
/// time: XP, level recalculation, and achievement tier checks. Nothing
/// else should award XP or unlock achievements directly — matches
/// blueprint section 7: "MovieService should never directly unlock
/// achievements... everything flows through the ProgressionService."
///
/// Only called on a brand-new log, never an edit — editing an existing
/// entry (e.g. adding a review after the fact) doesn't re-trigger XP or
/// achievement checks. That's a deliberate simplification: re-checking
/// on every edit would let repeated edits farm XP, and "Watch Movie" /
/// "Review Movie" read most naturally as one-time actions tied to the
/// initial log.
class ProgressionService {
  final FirebaseFirestore _firestore;

  ProgressionService({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  Future<ProgressionResult> processMovieLogged({
    required String uid,
    required List<WatchHistoryEntry> updatedHistory,
    required bool wroteReview,
    required int currentXp,
  }) async {
    int xpGained = AppConstants.xpWatchMovie;
    if (wroteReview) xpGained += AppConstants.xpReviewMovie;

    final achievementsRef = _firestore.collection('users').doc(uid).collection('achievements');
    final snapshot = await achievementsRef.get();

    final currentTiers = <AchievementCategory, int>{
      for (final def in achievementDefinitions) def.category: 0,
    };
    for (final doc in snapshot.docs) {
      try {
        final category = AchievementCategory.values.byName(doc.id);
        currentTiers[category] = (doc.data()['unlockedTier'] as int?) ?? 0;
      } catch (_) {
        // Unrecognized category id in Firestore — ignore rather than crash.
      }
    }

    final updatedTiers = Map<AchievementCategory, int>.from(currentTiers);
    final newlyUnlocked = <UnlockedAchievement>[];

    for (final def in achievementDefinitions) {
      final currentValue = AchievementService.currentValueFor(def.category, updatedHistory);
      final previousTier = currentTiers[def.category] ?? 0;
      final newTier = AchievementService.tierForValue(def, currentValue);

      if (newTier > previousTier) {
        updatedTiers[def.category] = newTier;
        // Usually crosses one tier at a time, but a long movie could
        // push Hours Watched up several tiers in a single log — award
        // XP for every tier actually crossed.
        xpGained += AppConstants.xpAchievementUnlock * (newTier - previousTier);
        newlyUnlocked.add(UnlockedAchievement(definition: def, tier: newTier));
        await achievementsRef.doc(def.category.name).set({'unlockedTier': newTier});
      }
    }

    final newTotalXp = currentXp + xpGained;
    final previousLevel = LevelConfig.levelForXp(currentXp);
    final newLevel = LevelConfig.levelForXp(newTotalXp);
    final totalAchievementsUnlocked = updatedTiers.values.fold<int>(0, (sum, t) => sum + t);

    await _firestore.collection('users').doc(uid).update({
      'xp': newTotalXp,
      'level': newLevel,
      'moviesWatched': updatedHistory.length,
      'reviewsWritten': updatedHistory.where((e) => (e.review ?? '').trim().isNotEmpty).length,
      'achievementsUnlocked': totalAchievementsUnlocked,
    });

    return ProgressionResult(
      xpGained: xpGained,
      newXp: newTotalXp,
      newLevel: newLevel,
      leveledUp: newLevel > previousLevel,
      totalAchievementsUnlocked: totalAchievementsUnlocked,
      newlyUnlockedAchievements: newlyUnlocked,
    );
  }
}
