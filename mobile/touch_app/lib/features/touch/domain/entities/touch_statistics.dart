class TouchStatistics {
  const TouchStatistics({
    required this.totalTouch,
    required this.today,
    required this.thisWeek,
    required this.thisMonth,
    required this.currentStreak,
    required this.longestStreak,
  });

  final int totalTouch;
  final int today;
  final int thisWeek;
  final int thisMonth;
  final int currentStreak;
  final int longestStreak;

  TouchStatistics copyWith({
    int? totalTouch,
    int? today,
    int? thisWeek,
    int? thisMonth,
    int? currentStreak,
    int? longestStreak,
  }) {
    return TouchStatistics(
      totalTouch: totalTouch ?? this.totalTouch,
      today: today ?? this.today,
      thisWeek: thisWeek ?? this.thisWeek,
      thisMonth: thisMonth ?? this.thisMonth,
      currentStreak: currentStreak ?? this.currentStreak,
      longestStreak: longestStreak ?? this.longestStreak,
    );
  }
}
