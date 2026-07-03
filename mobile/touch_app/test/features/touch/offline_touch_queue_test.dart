import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:touch_app/features/touch/data/datasources/offline_touch_queue.dart';

void main() {
  test('queues and removes offline touches', () async {
    SharedPreferences.setMockInitialValues({});
    final preferences = await SharedPreferences.getInstance();
    final queue = OfflineTouchQueue(preferences);

    await queue.enqueue(
      QueuedTouch(
        uid: 'user-1',
        createdAt: DateTime.utc(2026, 7, 3),
        device: 'ios',
        appVersion: '1.0.0',
      ),
    );

    expect(await queue.load(), hasLength(1));

    await queue.removeFirst(1);

    expect(await queue.load(), isEmpty);
  });
}
