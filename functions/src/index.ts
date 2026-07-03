import {initializeApp} from "firebase-admin/app";
import {getFirestore, FieldValue, Timestamp} from "firebase-admin/firestore";
import {HttpsError, onCall} from "firebase-functions/v2/https";
import {setGlobalOptions} from "firebase-functions/v2";

initializeApp();
setGlobalOptions({region: "asia-southeast1", maxInstances: 10});

const db = getFirestore();
const inviteCharacters = "ABCDEFGHJKLMNPQRSTUVWXYZ23456789";
const inviteCodeLength = 6;
const inviteLifetimeMs = 10 * 60 * 1000;

function requireUid(uid: string | undefined): string {
  if (!uid) {
    throw new HttpsError("unauthenticated", "Authentication is required.");
  }

  return uid;
}

function createCode(): string {
  let code = "";
  for (let index = 0; index < inviteCodeLength; index++) {
    code += inviteCharacters[Math.floor(Math.random() * inviteCharacters.length)];
  }

  return code;
}

function normalizeCode(value: unknown): string {
  if (typeof value !== "string") {
    throw new HttpsError("invalid-argument", "code is required.");
  }

  const code = value.trim().toUpperCase();
  if (!/^[A-Z0-9]{6}$/.test(code)) {
    throw new HttpsError("invalid-argument", "code must contain 6 letters or numbers.");
  }

  return code;
}

function stringValue(value: unknown, fallback: string): string {
  return typeof value === "string" && value.trim().length > 0 ? value.trim() : fallback;
}

function isYesterdayOrToday(lastTouchAt: Timestamp | undefined): {sameDay: boolean; yesterday: boolean} {
  if (!lastTouchAt) {
    return {sameDay: false, yesterday: false};
  }

  const now = new Date();
  const last = lastTouchAt.toDate();
  const today = new Date(now.getFullYear(), now.getMonth(), now.getDate()).getTime();
  const lastDay = new Date(last.getFullYear(), last.getMonth(), last.getDate()).getTime();
  const dayMs = 24 * 60 * 60 * 1000;

  return {
    sameDay: today === lastDay,
    yesterday: today - lastDay === dayMs,
  };
}

export const updatePresence = onCall(async (request) => {
  const uid = requireUid(request.auth?.uid);

  const online = request.data?.online;
  if (typeof online !== "boolean") {
    throw new HttpsError("invalid-argument", "online must be a boolean.");
  }

  await db.collection("users").doc(uid).update({
    online,
    lastSeen: FieldValue.serverTimestamp(),
    updatedAt: FieldValue.serverTimestamp(),
  });

  return {ok: true};
});

export const createInviteCode = onCall(async (request) => {
  const uid = requireUid(request.auth?.uid);
  const userRef = db.collection("users").doc(uid);

  return db.runTransaction(async (transaction) => {
    const userSnapshot = await transaction.get(userRef);
    if (!userSnapshot.exists) {
      throw new HttpsError("failed-precondition", "User profile is missing.");
    }

    if (userSnapshot.data()?.coupleId) {
      throw new HttpsError("failed-precondition", "User already has a couple.");
    }

    let code = createCode();
    let codeRef = db.collection("inviteCodes").doc(code);
    let codeSnapshot = await transaction.get(codeRef);

    for (let attempt = 0; codeSnapshot.exists && attempt < 5; attempt++) {
      code = createCode();
      codeRef = db.collection("inviteCodes").doc(code);
      codeSnapshot = await transaction.get(codeRef);
    }

    if (codeSnapshot.exists) {
      throw new HttpsError("resource-exhausted", "Cannot create pairing code now.");
    }

    const now = Timestamp.now();
    const expiredAt = Timestamp.fromMillis(Date.now() + inviteLifetimeMs);

    transaction.set(codeRef, {
      code,
      ownerId: uid,
      expiredAt,
      consumedAt: null,
      createdAt: now,
    });

    return {code, expiredAt: expiredAt.toMillis()};
  });
});

export const joinCouple = onCall(async (request) => {
  const uid = requireUid(request.auth?.uid);
  const code = normalizeCode(request.data?.code);
  const codeRef = db.collection("inviteCodes").doc(code);
  const joinerRef = db.collection("users").doc(uid);

  return db.runTransaction(async (transaction) => {
    const codeSnapshot = await transaction.get(codeRef);
    if (!codeSnapshot.exists) {
      throw new HttpsError("not-found", "Pairing code is invalid or expired.");
    }

    const codeData = codeSnapshot.data();
    const ownerId = codeData?.ownerId as string | undefined;
    const expiredAt = codeData?.expiredAt as Timestamp | undefined;

    if (!ownerId || !expiredAt || codeData?.consumedAt || expiredAt.toMillis() <= Date.now()) {
      throw new HttpsError("not-found", "Pairing code is invalid or expired.");
    }

    if (ownerId === uid) {
      throw new HttpsError("failed-precondition", "Cannot pair with yourself.");
    }

    const ownerRef = db.collection("users").doc(ownerId);
    const [ownerSnapshot, joinerSnapshot] = await Promise.all([
      transaction.get(ownerRef),
      transaction.get(joinerRef),
    ]);

    if (!ownerSnapshot.exists || !joinerSnapshot.exists) {
      throw new HttpsError("failed-precondition", "User profile is missing.");
    }

    if (ownerSnapshot.data()?.coupleId || joinerSnapshot.data()?.coupleId) {
      throw new HttpsError("failed-precondition", "A user already has a couple.");
    }

    const coupleRef = db.collection("couples").doc();
    const now = FieldValue.serverTimestamp();
    const members = [ownerId, uid].sort();

    transaction.set(coupleRef, {
      userA: members[0],
      userB: members[1],
      members,
      createdAt: now,
      lastTouchAt: null,
      totalTouch: 0,
      streak: 0,
      longestStreak: 0,
    });

    transaction.update(ownerRef, {
      coupleId: coupleRef.id,
      updatedAt: now,
    });

    transaction.update(joinerRef, {
      coupleId: coupleRef.id,
      updatedAt: now,
    });

    transaction.update(codeRef, {
      consumedAt: now,
    });

    return {
      coupleId: coupleRef.id,
      userA: members[0],
      userB: members[1],
    };
  });
});

export const sendTouch = onCall(async (request) => {
  const uid = requireUid(request.auth?.uid);
  const senderRef = db.collection("users").doc(uid);
  const device = stringValue(request.data?.device, "ios");
  const appVersion = stringValue(request.data?.appVersion, "unknown");

  return db.runTransaction(async (transaction) => {
    const senderSnapshot = await transaction.get(senderRef);
    if (!senderSnapshot.exists) {
      throw new HttpsError("failed-precondition", "User profile is missing.");
    }

    const sender = senderSnapshot.data();
    const coupleId = sender?.coupleId as string | undefined;
    if (!coupleId) {
      throw new HttpsError("failed-precondition", "User is not paired.");
    }

    const coupleRef = db.collection("couples").doc(coupleId);
    const coupleSnapshot = await transaction.get(coupleRef);
    if (!coupleSnapshot.exists) {
      throw new HttpsError("failed-precondition", "Couple is missing.");
    }

    const couple = coupleSnapshot.data() ?? {};
    const members = couple.members as string[] | undefined;
    if (!members?.includes(uid) || members.length !== 2) {
      throw new HttpsError("permission-denied", "User is not part of this couple.");
    }

    const receiverId = members.find((member) => member !== uid);
    if (!receiverId) {
      throw new HttpsError("failed-precondition", "Receiver is missing.");
    }

    const receiverRef = db.collection("users").doc(receiverId);
    const receiverSnapshot = await transaction.get(receiverRef);
    if (!receiverSnapshot.exists) {
      throw new HttpsError("failed-precondition", "Receiver profile is missing.");
    }

    const now = FieldValue.serverTimestamp();
    const touchRef = db.collection("touches").doc();
    const streakState = isYesterdayOrToday(couple.lastTouchAt as Timestamp | undefined);
    const previousStreak = typeof couple.streak === "number" ? couple.streak : 0;
    const nextStreak = streakState.sameDay ? previousStreak : streakState.yesterday ? previousStreak + 1 : 1;
    const previousLongest = typeof couple.longestStreak === "number" ? couple.longestStreak : 0;

    transaction.set(touchRef, {
      id: touchRef.id,
      coupleId,
      senderId: uid,
      receiverId,
      createdAt: now,
      device,
      appVersion,
    });

    transaction.update(coupleRef, {
      lastTouchAt: now,
      totalTouch: FieldValue.increment(1),
      streak: nextStreak,
      longestStreak: Math.max(previousLongest, nextStreak),
    });

    transaction.update(senderRef, {
      lastTouchAt: now,
      totalTouch: FieldValue.increment(1),
      updatedAt: now,
    });

    transaction.update(receiverRef, {
      lastTouchAt: now,
      totalTouch: FieldValue.increment(1),
      updatedAt: now,
    });

    return {
      touchId: touchRef.id,
      coupleId,
      receiverId,
    };
  });
});
