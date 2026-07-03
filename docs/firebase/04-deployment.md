# Firebase Auto Deploy

GitHub Actions deploys Firestore automatically when code is pushed to `main`.

Workflow:

1. Flutter analyze/test
2. Deploy Firestore rules/indexes

No Cloud Functions are deployed because this project is currently Firebase Auth + Firestore only.

Required GitHub secret:

```text
FIREBASE_SERVICE_ACCOUNT_TOUCHAPP
```

Value: the full JSON content of a Firebase service account for project `touchapp-65d7b`.

Recommended permissions:

- Firebase Rules Admin
- Cloud Datastore Index Admin
- Service Usage Viewer

Manual deploy:

```powershell
firebase deploy --only firestore --project touchapp-65d7b
```

