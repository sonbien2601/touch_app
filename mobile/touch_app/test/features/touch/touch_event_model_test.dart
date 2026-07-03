import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:touch_app/features/touch/data/models/touch_event_model.dart';

void main() {
  test('maps Firestore data to TouchEvent', () {
    final createdAt = DateTime.utc(2026, 7, 3, 1, 2, 3);
    final model = TouchEventModel.fromMap({
      'coupleId': 'couple-1',
      'senderId': 'sender',
      'receiverId': 'receiver',
      'createdAt': Timestamp.fromDate(createdAt),
      'device': 'ios',
      'appVersion': '1.0.0',
    }, fallbackId: 'touch-1');

    final event = model.toEntity();

    expect(event.id, 'touch-1');
    expect(event.coupleId, 'couple-1');
    expect(event.createdAt.isAtSameMomentAs(createdAt), isTrue);
  });
}
