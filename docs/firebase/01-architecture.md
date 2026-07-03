# Touch Web Architecture

Touch is now a Blazor WebAssembly app deployed on Firebase Hosting.

## Stack

- .NET Blazor WebAssembly
- Firebase Authentication
- Cloud Firestore
- Firebase Hosting

## Runtime

The Blazor app is static WebAssembly. Firebase Web SDK is loaded from `wwwroot/touch-firebase.js` and called from Blazor through JS interop.

No ASP.NET server, PostgreSQL, or Cloud Functions are used.

## Data Flow

- User signs in with Firebase Email/Password.
- The web app creates or updates `users/{uid}`.
- Pairing uses `inviteCodes` and `couples`.
- Touch writes `touches`, updates `couples`, and updates both user counters.

## Hosting

Firebase Hosting serves the published Blazor files from:

`web/Touch.Web/bin/Release/net10.0/publish/wwwroot`
