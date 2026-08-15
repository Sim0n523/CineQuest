import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/watch_history_entry.dart';
import '../../utils/app_constants.dart';
import '../../utils/xp_config.dart';
import '../../utils/achievement_config.dart';
import '../../utils/quest_config.dart';
import '../models/quest_period_state.dart';
import 'achievement_service.dart';
import 'quest_service.dart';

class UnlockedAchievement {
  final AchievementDefinition definition;
  final int tier;
  const UnlockedAchievement({required this.definition, required this.tier});
}

class CompletedQuest {
  final QuestTemplate template;
  const CompletedQuest({required this.template});
}

class ProgressionResult {
  final int xpGained;
  final int newXp;
  final int newLevel;
  final bool leveledUp;
  final int totalAchievementsUnlocked;
  final List<UnlockedAchievement> newlyUnlockedAchievements;
  final List<CompletedQuest> newlyCompletedQuests;

  const ProgressionResult({
    required this.xpGained,
    required this.newXp,
    required this.newLevel,
    required this.leveledUp,
    required this.totalAchievementsUnlocked,
    required this.newlyUnlockedAchievements,
    required this.newlyCompletedQuests,
  });
}

/// Owns everything that happens when a movie gets logged for the first
/// time: XP, level recalculation, achievement tier checks, AND quest
/// completion checks. Nothing else should award XP directly — matches
/// blueprint section 7: "MovieService should never directly unlock
/// achievements... everything flows through the ProgressionService."
/// Quest completion (+250/+500 XP per section 12) flows through here
/// too, for the same reason.
///
/// Only called on a brand-new log, never an edit — see the note on
/// this class from Phase 3 for why (repeated edits shouldn't farm XP).
class ProgressionService {
  final FirebaseFirestore _firestore;
  final QuestService _questService;

  ProgressionService({FirebaseFirestore? firestore, QuestService? questService})
      : _firestore = firestore ?? FirebaseFirestore.instance,
        _questService = questService ?? QuestService();

  /// Exposed so the Quests screen can fetch/generate the current
  /// period's set on its own (e.g. just opening the tab), independent
  /// of whether a movie was just logged.
  Future<QuestBundle> ensureCurrentQuests(String uid) => _questService.ensureCurrentQuests(uid);

  Future<ProgressionResult> processMovieLogged({
    required String uid,
    required List<WatchHistoryEntry> updatedHistory,
    required bool wroteReview,
    required int currentXp,
  }) async {
    int xpGained = AppConstants.xpWatchMovie;
    if (wroteReview) xpGained += AppConstants.xpReviewMovie;

    // --- Achievements ---
    final achievementsRef = _firestore.collection('users').doc(uid).collection('achievements');
    final achievementSnapshot = await achievementsRef.get();

    final currentTiers = <AchievementCategory, int>{
      for (final def in achievementDefinitions) def.category: 0,
    };
    for (final doc in achievementSnapshot.docs) {
      try {
        final category = AchievementCategory.values.byName(doc.id);
        currentTiers[category] = (doc.data()['unlockedTier'] as int?) ?? 0;
      } catch (_) {
        // Unrecognized category id in Firestore — ignore rather than crash.
      }
    }

    final updatedTiers = Map<AchievementCategory, int>.from(currentTiers);
    final newlyUnlockedAchievements = <UnlockedAchievement>[];

    for (final def in achievementDefinitions) {
      final currentValue = AchievementService.currentValueFor(def.category, updatedHistory);
      final previousTier = currentTiers[def.category] ?? 0;
      final newTier = AchievementService.tierForValue(def, currentValue);

      if (newTier > previousTier) {
        updatedTiers[def.category] = newTier;
        xpGained += AppConstants.xpAchievementUnlock * (newTier - previousTier);
        newlyUnlockedAchievements.add(UnlockedAchievement(definition: def, tier: newTier));
        await achievementsRef.doc(def.category.name).set({'unlockedTier': newTier});
      }
    }

    // --- Quests ---
    final questBundle = await _questService.ensureCurrentQuests(uid);
    final newlyCompletedQuests = <CompletedQuest>[];

    for (final periodState in [questBundle.weekly, questBundle.monthly]) {
      final pool = periodState.type == QuestPeriodType.weekly ? weeklyQuestPool : monthlyQuestPool;
      final periodStart = QuestService.periodStartFor(periodState.type);
      final periodEntries = QuestService.entriesInPeriod(updatedHistory, periodStart);

      for (final activeQuest in periodState.quests) {
        if (activeQuest.completed) continue;
        final matches = pool.where((t) => t.id == activeQuest.templateId);
        if (matches.isEmpty) continue;
        final template = matches.first;
        final progress = QuestService.progressFor(template, periodEntries);

        if (progress >= template.target) {
          xpGained += template.xpReward;
          newlyCompletedQuests.add(CompletedQuest(template: template));
          await _questService.markCompleted(uid, periodState.type, template.id);
        }
      }
    }

    // --- Totals ---
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
      newlyUnlockedAchievements: newlyUnlockedAchievements,
      newlyCompletedQuests: newlyCompletedQuests,
    );
  }
}
