import 'package:flutter_test/flutter_test.dart';
import 'package:touch_app/core/errors/app_exception.dart';

void main() {
  test('AuthException exposes user-safe message', () {
    const error = AuthException('Authentication failed.');

    expect(error.message, 'Authentication failed.');
  });
}
