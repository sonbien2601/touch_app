# Touch

Touch is a private web app for exactly two people. It has no chat, no feed, no calls, and no social graph.

Current stack:

- .NET Blazor WebAssembly
- Firebase Authentication
- Cloud Firestore
- Firebase Hosting

Production URL:

- https://touchapp-65d7b.web.app
- https://touchapp-65d7b.firebaseapp.com

Backend policy: Firebase Auth + Cloud Firestore only. No ASP.NET server, PostgreSQL, custom server, or Cloud Functions unless billing is explicitly approved.

Closed-browser push notifications need Firebase Cloud Messaging Web Push plus a sender backend. The web client and service worker are prepared, but a VAPID public key and sender service are still required.
