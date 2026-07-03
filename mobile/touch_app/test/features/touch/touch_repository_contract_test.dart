import 'package:flutter_test/flutter_test.dart';
import 'package:touch_app/features/touch/domain/entities/touch_statistics.dart';

void main() {
  test('statistics copyWith preserves untouched fields', () {
    const stats = TouchStatistics(
      totalTouch: 10,
      today: 1,
      thisWeek: 3,
      thisMonth: 8,
      currentStreak: 2,
      longestStreak: 5,
    );

    final updated = stats.copyWith(today: 2);

    expect(updated.totalTouch, 10);
    expect(updated.today, 2);
    expect(updated.longestStreak, 5);
  });
}

