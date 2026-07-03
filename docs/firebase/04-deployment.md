# Deployment

## Local Build

```powershell
dotnet build web\Touch.Web\Touch.Web.csproj
dotnet publish web\Touch.Web\Touch.Web.csproj -c Release
```

## Manual Deploy

```powershell
firebase deploy --only firestore,hosting --project touchapp-65d7b
```

## Production URL

- https://touchapp-65d7b.web.app
- https://touchapp-65d7b.firebaseapp.com

## GitHub Actions

Push to `main` runs:

- .NET build
- .NET publish
- Firebase deploy for Firestore and Hosting
