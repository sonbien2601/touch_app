import 'package:flutter_test/flutter_test.dart';
import 'package:touch_app/features/touch/domain/entities/home_summary.dart';
import 'package:touch_app/features/touch/domain/entities/touch_event.dart';
import 'package:touch_app/features/touch/domain/entities/touch_statistics.dart';
import 'package:touch_app/features/touch/domain/repositories/touch_repository.dart';
import 'package:touch_app/features/touch/presentation/controllers/touch_controller.dart';

void main() {
  test('send debounces rapid taps', () async {
    final repository = _FakeTouchRepository();
    final controller = TouchController(repository);

    await controller.send('user-1');
    await controller.send('user-1');

    expect(repository.sent, 1);
  });
}

class _FakeTouchRepository implements TouchRepository {
  int sent = 0;

  @override
  Future<void> sendTouch(String uid) async {
    sent++;
  }

  @override
  Future<void> flushOfflineQueue() async {}

  @override
  Future<TouchEvent?> getLastTouch(String coupleId) async => null;

  @override
  Future<TouchStatistics> getStatistics(String coupleId) async {
    return const TouchStatistics(
      totalTouch: 0,
      today: 0,
      thisWeek: 0,
      thisMonth: 0,
      currentStreak: 0,
      longestStreak: 0,
    );
  }

  @override
  Future<List<TouchEvent>> getTouchHistory(String coupleId, {int limit = 20}) async => [];

  @override
  Stream<HomeSummary> watchHomeSummary(String uid) => const Stream.empty();
}

