# Phase 1 - Firestore Design

## Collections

### users/{uid}

```json
{
  "uid": "firebase-auth-uid",
  "name": "Person",
  "email": "person@example.com",
  "avatar": "storage-or-url",
  "online": true,
  "lastSeen": "timestamp",
  "fcmToken": "token",
  "battery": {
    "shared": false,
    "level": null,
    "updatedAt": null
  },
  "coupleId": "couple-doc-id-or-null",
  "createdAt": "timestamp",
  "updatedAt": "timestamp"
}
```

Rules:

- user can read self
- paired partner can read limited profile/presence data
- user can update only safe self fields
- user cannot update another user

### couples/{coupleId}

```json
{
  "userA": "uid-a",
  "userB": "uid-b",
  "members": ["uid-a", "uid-b"],
  "createdAt": "timestamp"
}
```

Rules:

- readable only by members
- writable only by members through validated Firestore transactions
- each user can belong to only one couple, enforced by Function transaction and `users/{uid}.coupleId`

### touches/{touchId}

```json
{
  "senderId": "uid-a",
  "receiverId": "uid-b",
  "coupleId": "couple-id",
  "createdAt": "timestamp"
}
```

Rules:

- readable only by sender/receiver
- client can create only valid touch documents for its own couple
- latest 100 query ordered by `createdAt desc`

### inviteCodes/{code}

Document id should be the six-character code.

```json
{
  "code": "A8KD9P",
  "ownerId": "uid-a",
  "expiredAt": "timestamp",
  "consumedAt": null,
  "createdAt": "timestamp"
}
```

Rules:

- owner can read own active code
- client can create own invite code
- another user can mark it consumed while creating a couple transaction
- cleaned by scheduled `cleanupExpiredInviteCodes`

## Required Indexes

`touches`:

- `coupleId asc`, `createdAt desc`
- `senderId asc`, `createdAt desc`
- `receiverId asc`, `createdAt desc`

`inviteCodes`:

- `ownerId asc`, `expiredAt desc`
- `expiredAt asc`

## Consistency Rules

Flutter must use Firestore transactions for:

- creating invite code after checking owner has no `coupleId`
- joining couple after checking both users have no `coupleId`
- writing couple and updating both `users/{uid}.coupleId`
- sending touch after verifying sender and receiver are in the same couple
