# Touch

Touch is a private iOS app for exactly two people. It has no chat, no feed, no calls, and no social graph.

Current direction: Flutter + Firebase only.

The production goal is simple:

- one large heart button
- authenticated touch action
- persisted touch history in Firestore
- FCM push notification routed to APNs on iOS
- in-app heart animation and haptics when foregrounded

Current status: Firebase/Flutter Phase 1 complete.

See:

- [Firebase Flutter Architecture](docs/firebase/01-architecture.md)
- [Firestore Design](docs/firebase/02-firestore-design.md)
- [Security Rules](firebase/firestore.rules)
- [Roadmap](docs/firebase/03-roadmap.md)

Backend policy: Firebase only. Do not add ASP.NET Core, PostgreSQL, or a custom server backend.
