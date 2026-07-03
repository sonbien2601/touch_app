import 'package:flutter_test/flutter_test.dart';
import 'package:touch_app/firebase_options.dart';

void main() {
  test('Firebase iOS options match official Touch project', () {
    const options = DefaultFirebaseOptions.ios;

    expect(options.projectId, 'touchapp-65d7b');
    expect(options.iosBundleId, 'com.son.touch');
    expect(options.appId, '1:603507359681:ios:cfae871f494d751c90b940');
    expect(options.messagingSenderId, '603507359681');
  });
}

