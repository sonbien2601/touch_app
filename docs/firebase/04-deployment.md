# Firebase Auto Deploy

GitHub Actions deploys Firebase automatically when code is pushed to `main`.

Workflow:

1. Flutter analyze/test
2. Firebase Functions TypeScript build
3. Deploy Firestore rules/indexes and Cloud Functions

Required GitHub secret:

```text
FIREBASE_SERVICE_ACCOUNT_TOUCHAPP
```

Value: the full JSON content of a Firebase service account for project `touchapp-65d7b`.

Recommended permissions:

- Cloud Functions Admin
- Firebase Rules Admin
- Cloud Datastore Index Admin
- Service Account User
- Artifact Registry Writer
- Cloud Build Editor

Manual deploy remains available:

```powershell
firebase deploy --only firestore,functions --project touchapp-65d7b
```

