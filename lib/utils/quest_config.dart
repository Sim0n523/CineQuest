enum QuestPeriodType { weekly, monthly }

enum QuestMetric {
  moviesWatched,
  reviewsWritten,
  genreCount, // count of movies in ONE specific genre (uses genreId)
  distinctGenres, // count of DIFFERENT genres watched
  releasedBefore, // count of movies released before a given year (uses beforeYear)
  hoursWatched,
}

class QuestTemplate {
  final String id;
  final String title;
  final String description;
  final QuestMetric metric;
  final int target;
  final int? genreId;
  final int? beforeYear;
  final QuestPeriodType period;
  final int xpReward;

  const QuestTemplate({
    required this.id,
    required this.title,
    required this.description,
    required this.metric,
    required this.target,
    this.genreId,
    this.beforeYear,
    required this.period,
    required this.xpReward,
  });
}

/// Weekly pool — 3 are randomly selected each week. XP reward (250)
/// matches blueprint section 12 exactly.
///
/// Two of the blueprint's own weekly examples ("Watch 3 Horror Movies",
/// "Watch a Movie Released Before 1990") work as-is with data we
/// already collect (genreIds, releaseYear on WatchHistoryEntry).
const List<QuestTemplate> weeklyQuestPool = [
  QuestTemplate(
    id: 'weekly_watch_5',
    title: 'Watch 5 Movies',
    description: 'Log 5 movies this week',
    metric: QuestMetric.moviesWatched,
    target: 5,
    period: QuestPeriodType.weekly,
    xpReward: 250,
  ),
  QuestTemplate(
    id: 'weekly_horror_3',
    title: 'Horror Night',
    description: 'Watch 3 horror movies this week',
    metric: QuestMetric.genreCount,
    target: 3,
    genreId: 27, // Horror, from utils/genre_map.dart
    period: QuestPeriodType.weekly,
    xpReward: 250,
  ),
  QuestTemplate(
    id: 'weekly_reviews_2',
    title: 'Speak Your Mind',
    description: 'Write 2 reviews this week',
    metric: QuestMetric.reviewsWritten,
    target: 2,
    period: QuestPeriodType.weekly,
    xpReward: 250,
  ),
  QuestTemplate(
    id: 'weekly_before_1990',
    title: 'Blast From the Past',
    description: 'Watch a movie released before 1990',
    metric: QuestMetric.releasedBefore,
    target: 1,
    beforeYear: 1990,
    period: QuestPeriodType.weekly,
    xpReward: 250,
  ),
  QuestTemplate(
    id: 'weekly_genres_3',
    title: 'Mix It Up',
    description: 'Watch movies from 3 different genres this week',
    metric: QuestMetric.distinctGenres,
    target: 3,
    period: QuestPeriodType.weekly,
    xpReward: 250,
  ),
];

/// Monthly pool — 3 are randomly selected each month. XP reward is 1000
/// (deliberately 4x a weekly quest's 250 — monthly quests take
/// meaningfully longer and were previously only worth 2x, which didn't
/// feel proportionate).
///
/// The blueprint's own monthly examples "Complete Harry Potter
/// Collection" and "Watch Movies From Five Countries" are NOT here —
/// the first needs the Collections system (not built, see README), the
/// second needs TMDB's production_countries field (nothing fetches or
/// stores that today). Replaced with quests using data we already have.
const List<QuestTemplate> monthlyQuestPool = [
  QuestTemplate(
    id: 'monthly_watch_15',
    title: 'Watch 15 Movies',
    description: 'Log 15 movies this month',
    metric: QuestMetric.moviesWatched,
    target: 15,
    period: QuestPeriodType.monthly,
    xpReward: 1000,
  ),
  QuestTemplate(
    id: 'monthly_genres_4',
    title: 'Genre Hopper',
    description: 'Watch movies from 4 different genres this month',
    metric: QuestMetric.distinctGenres,
    target: 4,
    period: QuestPeriodType.monthly,
    xpReward: 1000,
  ),
  QuestTemplate(
    id: 'monthly_hours_10',
    title: 'Marathon Month',
    description: 'Log 10+ hours of movies this month',
    metric: QuestMetric.hoursWatched,
    target: 10,
    period: QuestPeriodType.monthly,
    xpReward: 1000,
  ),
  QuestTemplate(
    id: 'monthly_reviews_5',
    title: 'Prolific Critic',
    description: 'Write 5 reviews this month',
    metric: QuestMetric.reviewsWritten,
    target: 5,
    period: QuestPeriodType.monthly,
    xpReward: 1000,
  ),
];

/// Period boundaries and stable keys used to detect rollover.
///
/// Deliberately NOT true ISO-8601 week numbering — that has real edge
/// cases around New Year's (week 1 of a year can start in December).
/// Using "the Monday of the current week" as both the boundary and the
/// key sidesteps that entirely while still being unique per week.
class QuestPeriodUtils {
  QuestPeriodUtils._();

  static DateTime startOfWeek(DateTime date) {
    final d = DateTime(date.year, date.month, date.day);
    return d.subtract(Duration(days: d.weekday - 1));
  }

  static String weeklyKey(DateTime date) => _dateKey(startOfWeek(date));

  static DateTime startOfMonth(DateTime date) => DateTime(date.year, date.month, 1);

  static String monthlyKey(DateTime date) => '${date.year}-${date.month.toString().padLeft(2, '0')}';

  static String _dateKey(DateTime date) =>
      '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
}
