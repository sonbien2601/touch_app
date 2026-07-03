# Phase 1 - Flutter + Firebase Architecture

## Product Boundary

Touch is for exactly two people:

- no chat
- no calls
- no feed
- no public profile
- no social graph

The app has one emotional core: press a large heart, save the event, notify the paired partner.

## Required Stack

Frontend:

- Flutter
- Dart
- Material 3 base theme
- Cupertino-first iOS experience
- Riverpod
- Go Router
- Freezed
- json_serializable

Backend:

- Firebase Authentication
- Cloud Firestore
- Firebase Cloud Messaging
- Firebase Storage for avatar if needed
- Firebase Crashlytics
- Firebase Analytics optional

No ASP.NET Core. No custom server.

## Architecture

```text
lib/
  core/
    config/
    errors/
    logging/
    routing/
    theme/
    utils/

  shared/
    widgets/
    models/
    providers/

  features/
    auth/
      data/
      domain/
      presentation/
    couple/
      data/
      domain/
      presentation/
    home/
      data/
      domain/
      presentation/
    touch/
      data/
      domain/
      presentation/
    notification/
      data/
      domain/
      presentation/
    profile/
      data/
      domain/
      presentation/
```

Each feature keeps:

- datasource: Firebase API boundary
- model: Firestore/DTO shape
- repository: interface implementation
- entity: domain object
- use case: business action
- presentation: screen, controller, state

Widgets must not contain Firebase calls or business rules.

## Firebase Function Boundary

Flutter may:

- authenticate
- read allowed Firestore data
- update its own safe user fields
- write allowed Firestore documents through transactions guarded by Security Rules

Flutter must not:

- send FCM directly
- create couples directly
- create touches directly
- consume invite codes directly

Firestore transactions own app writes. Security Rules validate membership and document shape.
- `updatePresence`
- `cleanupExpiredInviteCodes`

## Key Technical Decisions

### Auth

Chosen: Firebase Auth with Email and Apple ID.

Reason:

- native Firebase session persistence
- iOS Apple sign-in support
- no custom password/token backend
- integrates directly with Firestore rules via `request.auth.uid`

### Pairing

Chosen: invite code is created and consumed by Flutter through Firestore transactions.

Reason:

- prevents two people racing to consume the same code
- enforces one couple per account
- keeps validation out of the client

### Touch

Chosen: Flutter writes touch data through Firestore transactions.

Reason:

- client cannot spoof sender/receiver
- notification logic stays server-side
- Firestore history and push stay consistent

### Presence

Chosen: app lifecycle updates safe own-user fields directly in Firestore.

Tradeoff:

- Firestore is not a realtime connection detector.
- For iOS, lifecycle-based presence is acceptable for a minimal private app.
- Later upgrade path: Realtime Database presence mirror if stronger online accuracy is required.
