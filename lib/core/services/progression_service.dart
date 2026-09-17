import 'package:cloud_firestore/cloud_firestore.dart';
// quest_service.dart imports this but doesn't re-export it, so it must
// be imported directly here too for QuestBundle/QuestPeriodState.
import '../models/quest_period_state.dart';
import '../models/watch_history_entry.dart';
import '../../utils/app_constants.dart';
import '../../utils/xp_config.dart';
import '../../utils/achievement_config.dart';
import '../../utils/quest_config.dart';
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

class CollectionCompletionResult {
  final int xpGained;
  final int newXp;
  final int newLevel;
  final bool leveledUp;
  final List<UnlockedAchievement> newlyUnlockedAchievements;
  final int totalAchievementsUnlocked;

  const CollectionCompletionResult({
    required this.xpGained,
    required this.newXp,
    required this.newLevel,
    required this.leveledUp,
    required this.newlyUnlockedAchievements,
    required this.totalAchievementsUnlocked,
  });
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

/// Shared by processMovieLogged and checkCollectionCompletion — both
/// need the same "did any tier just get crossed" logic against the
/// same persisted tier docs.
class _AchievementCheckResult {
  final int xpGained;
  final List<UnlockedAchievement> newlyUnlocked;
  final int totalAchievementsUnlocked;
  const _AchievementCheckResult({
    required this.xpGained,
    required this.newlyUnlocked,
    required this.totalAchievementsUnlocked,
  });
}

/// Owns everything that happens when a movie gets logged for the first
/// time: XP, level recalculation, achievement tier checks, and quest
/// completion. Nothing else should award XP directly. Collection
/// completion (checkCollectionCompletion) is a separate entry point but
/// shares the achievement-check logic via _checkAchievements below.
///
/// Only called on a brand-new log, never an edit, so repeated edits
/// can't be used to farm XP.
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

  /// Checks every achievement category against its current value,
  /// persists any newly-crossed tier, and returns the XP/unlock summary.
  /// collectionsCompleted is passed in rather than read from Firestore
  /// here — callers already have it as a snapshot value (currentUser or
  /// a param), same pattern as currentXp elsewhere in this class.
  Future<_AchievementCheckResult> _checkAchievements({
    required String uid,
    required List<WatchHistoryEntry> history,
    required int collectionsCompleted,
  }) async {
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
    final newlyUnlocked = <UnlockedAchievement>[];
    var xpGained = 0;

    for (final def in achievementDefinitions) {
      final currentValue = AchievementService.currentValueFor(
        def.category,
        history,
        collectionsCompleted: collectionsCompleted,
      );
      final previousTier = currentTiers[def.category] ?? 0;
      final newTier = AchievementService.tierForValue(def, currentValue);

      if (newTier > previousTier) {
        updatedTiers[def.category] = newTier;
        xpGained += AppConstants.xpAchievementUnlock * (newTier - previousTier);
        newlyUnlocked.add(UnlockedAchievement(definition: def, tier: newTier));
        await achievementsRef.doc(def.category.name).set({'unlockedTier': newTier});
      }
    }

    return _AchievementCheckResult(
      xpGained: xpGained,
      newlyUnlocked: newlyUnlocked,
      totalAchievementsUnlocked: updatedTiers.values.fold<int>(0, (sum, t) => sum + t),
    );
  }

  Future<ProgressionResult> processMovieLogged({
    required String uid,
    required List<WatchHistoryEntry> updatedHistory,
    required bool wroteReview,
    required int currentXp,
    required int currentCollectionsCompleted,
  }) async {
    int xpGained = AppConstants.xpWatchMovie;
    if (wroteReview) xpGained += AppConstants.xpReviewMovie;

    final achievementResult = await _checkAchievements(
      uid: uid,
      history: updatedHistory,
      collectionsCompleted: currentCollectionsCompleted,
    );
    xpGained += achievementResult.xpGained;

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

    final newTotalXp = currentXp + xpGained;
    final previousLevel = LevelConfig.levelForXp(currentXp);
    final newLevel = LevelConfig.levelForXp(newTotalXp);

    await _firestore.collection('users').doc(uid).update({
      'xp': newTotalXp,
      'level': newLevel,
      'moviesWatched': updatedHistory.length,
      'reviewsWritten': updatedHistory.where((e) => (e.review ?? '').trim().isNotEmpty).length,
      'achievementsUnlocked': achievementResult.totalAchievementsUnlocked,
    });

    return ProgressionResult(
      xpGained: xpGained,
      newXp: newTotalXp,
      newLevel: newLevel,
      leveledUp: newLevel > previousLevel,
      totalAchievementsUnlocked: achievementResult.totalAchievementsUnlocked,
      newlyUnlockedAchievements: achievementResult.newlyUnlocked,
      newlyCompletedQuests: newlyCompletedQuests,
    );
  }

  /// Called from the Collections screen when it detects a collection is
  /// fully logged, not from processMovieLogged — checking every
  /// collection against history on every log would mean several extra
  /// TMDB round trips per log. Guarded by a persisted `completed` flag
  /// so XP is only ever awarded once per collection.
  Future<CollectionCompletionResult?> checkCollectionCompletion({
    required String uid,
    required String collectionId,
    required int currentXp,
    required int movieCount,
    required int currentCollectionsCompleted,
    required List<WatchHistoryEntry> history,
  }) async {
    final ref = _firestore.collection('users').doc(uid).collection('collections').doc(collectionId);
    final doc = await ref.get();
    final alreadyCompleted = doc.exists && (doc.data()?['completed'] as bool? ?? false);
    if (alreadyCompleted) return null;

    await ref.set({'completed': true});

    // Scales with collection size so a 3-film collection doesn't pay
    // out the same as a 30-film one.
    var xpGained = AppConstants.xpCollectionBase + AppConstants.xpCollectionPerMovie * movieCount;
    final newCollectionsCompleted = currentCollectionsCompleted + 1;

    final achievementResult = await _checkAchievements(
      uid: uid,
      history: history,
      collectionsCompleted: newCollectionsCompleted,
    );
    xpGained += achievementResult.xpGained;

    final newTotalXp = currentXp + xpGained;
    final previousLevel = LevelConfig.levelForXp(currentXp);
    final newLevel = LevelConfig.levelForXp(newTotalXp);

    await _firestore.collection('users').doc(uid).update({
      'xp': newTotalXp,
      'level': newLevel,
      'collectionsCompleted': FieldValue.increment(1),
      'achievementsUnlocked': achievementResult.totalAchievementsUnlocked,
    });

    return CollectionCompletionResult(
      xpGained: xpGained,
      newXp: newTotalXp,
      newLevel: newLevel,
      leveledUp: newLevel > previousLevel,
      newlyUnlockedAchievements: achievementResult.newlyUnlocked,
      totalAchievementsUnlocked: achievementResult.totalAchievementsUnlocked,
    );
  }
}
