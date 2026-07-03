# Touch Flutter App

Project name: `touch_app`

Firebase project:

- name: `touchApp`
- id: `touchapp-65d7b`

iOS bundle id:

- `com.son.touch`

Firebase is intentionally not configured yet. Do not commit generated secrets.

Implemented in Phase 2:

- iOS-only Flutter project
- Clean Architecture skeleton
- Riverpod providers
- GoRouter auth redirect
- Firebase Auth email sign-in/register
- Apple Sign In code path through Firebase Auth provider
- Firestore user document creation
- Crashlytics bootstrap
- Firestore-only pairing and touch flow

Required later from owner:

- `GoogleService-Info.plist`
- generated `lib/firebase_options.dart` if using FlutterFire CLI
- Apple Developer access for Sign in with Apple/APNs
- APNs key `.p8`, Team ID, Key ID

Verified commands:

```powershell
flutter pub get
flutter analyze
flutter test
```
