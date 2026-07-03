# Firebase/Flutter Roadmap

## Phase 1 - Analysis, Architecture, Firestore, Rules

Status: complete.

Delivered:

- Firebase-only architecture
- Flutter Clean Architecture folder plan
- Firestore collection design
- security rules
- function ownership boundaries

## Phase 2 - Flutter Init, Firebase Config, Auth

Status: complete for code/tooling; runtime Firebase/iOS config pending owner-provided files.

- create Flutter app
- add Firebase config
- add Riverpod and Go Router
- implement Email login/register
- implement Apple ID login placeholder
- persist auth state via Firebase Auth
- create user document after first login

Delivered:

- `mobile/touch_app/pubspec.yaml`
- real Flutter iOS project
- bundle id fixed to `com.son.touch`
- Clean Architecture folders
- Firebase bootstrap without fake options
- Cupertino app shell
- auth repository/datasource/use cases/controller
- email sign-in/register UI
- Apple sign-in code path via Firebase Auth provider
- home placeholder after auth
- basic test scaffold
- Firestore-only backend decision
- local Flutter SDK and Firebase CLI installed

Verified:

```powershell
cd mobile/touch_app
flutter pub get
flutter analyze
flutter test
```

Also verified:

Still required from owner before device/runtime auth validation:

- `GoogleService-Info.plist` for Firebase project `touchapp-65d7b`
- FlutterFire-generated `firebase_options.dart` if you want explicit Dart options
- Apple Developer setup for Sign in with Apple
- APNs key `.p8`, Team ID, Key ID for push later

## Phase 3 - Pairing

Status: complete.

- Firestore transaction create invite code
- Firestore transaction join couple
- pairing UI
- one-couple-only enforcement

Delivered:

- Pairing Clean Architecture feature
- invite code validation
- loading/error/empty UI states
- Firestore Security Rules enforcement
- Firestore Security Rules remain client-write locked for couples/invite codes
- unit tests for invite code validation
- Firebase config test for official iOS options

## Phase 4 - Touch

Status: complete.

- Firestore transaction send touch
- touch repository/use case/controller
- heart press debounce
- touch history query, latest 100

Delivered:

- Cupertino home dashboard
- paired/empty/loading/error states
- animated hero heart button with haptics
- touch repository contract and Firebase implementation
- offline queue with reconnect flush support
- touch history screen with pagination
- statistics cards
- Firestore `touches` write path through client transaction
- `users` and `couples` touch statistics updates
- unit tests for mapper, validation, controller, offline queue
- integration-style offline/reconnect test artifact
- GitHub Actions CI for Flutter and Firestore deploy

## Phase 5 - Push Notification

Planned:

- FCM setup
- APNs setup for iOS
- notification permission flow
- foreground message handling
- token refresh update

## Phase 6 - UI Polish

Planned:

- Cupertino-first home
- dark mode
- premium minimal heart screen
- 60 FPS animation
- haptic feedback
- loading/empty/error/retry states

## Phase 7 - Testing

Planned:

- unit tests for repositories/use cases
- widget tests for auth/pairing/home
- Firestore rules tests
- Firestore rules tests

## Phase 8 - iOS Build and Deployment Docs

Planned:

- Firebase project setup guide
- APNs key setup
- TestFlight checklist
- production release checklist
