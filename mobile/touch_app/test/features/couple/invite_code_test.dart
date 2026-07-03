import 'package:flutter_test/flutter_test.dart';
import 'package:touch_app/features/couple/domain/entities/invite_code.dart';

void main() {
  test('parse normalizes valid pairing code', () {
    final code = InviteCode.parse(' a8kd9p ');

    expect(code.value, 'A8KD9P');
  });

  test('parse rejects invalid pairing code', () {
    expect(
      () => InviteCode.parse('abc'),
      throwsA(isA<FormatException>()),
    );
  });
}

