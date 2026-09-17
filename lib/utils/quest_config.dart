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

/// Weekly pool — 3 are randomly selected each week.
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

/// Monthly pool — 3 are randomly selected each month. XP reward is 4x
/// a weekly quest's, since monthly quests take meaningfully longer.
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
/// Deliberately NOT true ISO-8601 week numbering — that has edge cases
/// around New Year's. Using "the Monday of the current week" as both
/// the boundary and the key sidesteps that while staying unique per week.
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
