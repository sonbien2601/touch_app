import { initializeApp } from "https://www.gstatic.com/firebasejs/10.12.5/firebase-app.js";
import {
  createUserWithEmailAndPassword,
  getAuth,
  onAuthStateChanged,
  signInWithEmailAndPassword,
  signOut,
  updateProfile,
} from "https://www.gstatic.com/firebasejs/10.12.5/firebase-auth.js";
import {
  collection,
  doc,
  getDoc,
  getDocs,
  getFirestore,
  increment,
  limit,
  onSnapshot,
  orderBy,
  query,
  runTransaction,
  serverTimestamp,
  setDoc,
  updateDoc,
  where,
} from "https://www.gstatic.com/firebasejs/10.12.5/firebase-firestore.js";

const firebaseConfig = {
  apiKey: "AIzaSyBMdB7yam9cln1pGA4tu5vu1YSWQNYj0G4",
  authDomain: "touchapp-65d7b.firebaseapp.com",
  projectId: "touchapp-65d7b",
  storageBucket: "touchapp-65d7b.firebasestorage.app",
  messagingSenderId: "603507359681",
  appId: "1:603507359681:web:7895f46a455a7f6d90b940",
  measurementId: "G-V9134MRH68",
};

const app = initializeApp(firebaseConfig);
const auth = getAuth(app);
const db = getFirestore(app);
const alphabet = "ABCDEFGHJKLMNPQRSTUVWXYZ23456789";
let unsubscribeHome = null;

function userDto(user) {
  if (!user) return null;
  return { uid: user.uid, email: user.email, name: user.displayName || "Touch" };
}

function createCodeValue() {
  const bytes = crypto.getRandomValues(new Uint8Array(6));
  return Array.from(bytes, (value) => alphabet[value % alphabet.length]).join("");
}

function dateValue(value) {
  return value?.toDate ? value.toDate().toISOString() : null;
}

async function ensureUser(user, name) {
  const ref = doc(db, "users", user.uid);
  const snap = await getDoc(ref);
  if (snap.exists()) {
    await updateDoc(ref, { lastSeen: serverTimestamp(), updatedAt: serverTimestamp() });
    return;
  }

  await setDoc(ref, {
    uid: user.uid,
    name,
    email: user.email,
    avatar: null,
    online: true,
    lastSeen: serverTimestamp(),
    fcmToken: null,
    battery: { shared: false, level: null, updatedAt: null },
    coupleId: null,
    lastTouchAt: null,
    totalTouch: 0,
    createdAt: serverTimestamp(),
    updatedAt: serverTimestamp(),
  });
}

async function buildStats(coupleId, couple) {
  const snap = await getDocs(query(collection(db, "touches"), where("coupleId", "==", coupleId), orderBy("createdAt", "desc"), limit(200)));
  const events = snap.docs.map((d) => d.data()).filter((x) => x.createdAt?.toDate);
  const now = new Date();
  const day = new Date(now.getFullYear(), now.getMonth(), now.getDate());
  const week = new Date(day);
  week.setDate(day.getDate() - ((day.getDay() + 6) % 7));
  const month = new Date(now.getFullYear(), now.getMonth(), 1);
  return {
    total: couple.totalTouch || events.length,
    today: events.filter((x) => x.createdAt.toDate() >= day).length,
    week: events.filter((x) => x.createdAt.toDate() >= week).length,
    month: events.filter((x) => x.createdAt.toDate() >= month).length,
    streak: couple.streak || 0,
    best: couple.longestStreak || 0,
  };
}

window.touchFirebase = {
  listenAuth(dotNet) {
    onAuthStateChanged(auth, (user) => dotNet.invokeMethodAsync("OnAuthChanged", userDto(user)));
  },

  async register(email, password, name) {
    const result = await createUserWithEmailAndPassword(auth, email, password);
    await updateProfile(result.user, { displayName: name });
    await ensureUser(result.user, name);
    return userDto(result.user);
  },

  async signIn(email, password) {
    const result = await signInWithEmailAndPassword(auth, email, password);
    await ensureUser(result.user, result.user.displayName || "Touch");
    return userDto(result.user);
  },

  async signOut() {
    await signOut(auth);
  },

  async createCode(uid) {
    const userRef = doc(db, "users", uid);
    return await runTransaction(db, async (tx) => {
      const userSnap = await tx.get(userRef);
      if (userSnap.data()?.coupleId) throw new Error("User already paired.");
      let invite = createCodeValue();
      let inviteRef = doc(db, "inviteCodes", invite);
      let inviteSnap = await tx.get(inviteRef);
      for (let i = 0; inviteSnap.exists() && i < 5; i++) {
        invite = createCodeValue();
        inviteRef = doc(db, "inviteCodes", invite);
        inviteSnap = await tx.get(inviteRef);
      }
      tx.set(inviteRef, {
        code: invite,
        ownerId: uid,
        expiredAt: new Date(Date.now() + 10 * 60 * 1000),
        consumedAt: null,
        consumedBy: null,
        consumedCoupleId: null,
        createdAt: serverTimestamp(),
      });
      return invite;
    });
  },

  async join(uid, invite) {
    invite = invite.trim().toUpperCase();
    await runTransaction(db, async (tx) => {
      const codeRef = doc(db, "inviteCodes", invite);
      const joinerRef = doc(db, "users", uid);
      const codeSnap = await tx.get(codeRef);
      const codeData = codeSnap.data();
      if (!codeData || codeData.ownerId === uid || codeData.consumedAt) throw new Error("Invalid code.");
      const ownerId = codeData.ownerId;
      const ownerRef = doc(db, "users", ownerId);
      const joinerSnap = await tx.get(joinerRef);
      if (joinerSnap.data()?.coupleId) throw new Error("Already paired.");
      const coupleRef = doc(collection(db, "couples"));
      const members = [ownerId, uid].sort();
      tx.set(coupleRef, {
        userA: members[0],
        userB: members[1],
        members,
        inviteCode: invite,
        createdAt: serverTimestamp(),
        lastTouchAt: null,
        totalTouch: 0,
        streak: 0,
        longestStreak: 0,
      });
      tx.update(ownerRef, { coupleId: coupleRef.id, updatedAt: serverTimestamp() });
      tx.update(joinerRef, { coupleId: coupleRef.id, updatedAt: serverTimestamp() });
      tx.update(codeRef, { consumedAt: serverTimestamp(), consumedBy: uid, consumedCoupleId: coupleRef.id });
    });
  },

  listenHome(uid, dotNet) {
    if (unsubscribeHome) unsubscribeHome();
    unsubscribeHome = onSnapshot(doc(db, "users", uid), async (userSnap) => {
      const user = userSnap.data();
      if (!user?.coupleId) {
        await dotNet.invokeMethodAsync("OnHomeChanged", { paired: false, myName: user?.name || "Touch", statistics: emptyStats() });
        return;
      }

      const coupleSnap = await getDoc(doc(db, "couples", user.coupleId));
      const couple = coupleSnap.data() || {};
      const partnerId = (couple.members || []).find((x) => x !== uid);
      const partnerSnap = partnerId ? await getDoc(doc(db, "users", partnerId)) : null;
      const partner = partnerSnap?.data() || {};
      await dotNet.invokeMethodAsync("OnHomeChanged", {
        paired: true,
        coupleId: user.coupleId,
        myName: user.name || "Touch",
        partnerName: partner.name || "Partner",
        lastOnline: dateValue(partner.lastSeen),
        lastTouch: dateValue(couple.lastTouchAt),
        statistics: await buildStats(user.coupleId, couple),
      });
    });
  },

  async sendTouch(uid) {
    await runTransaction(db, async (tx) => {
      const senderRef = doc(db, "users", uid);
      const senderSnap = await tx.get(senderRef);
      const sender = senderSnap.data();
      const coupleRef = doc(db, "couples", sender.coupleId);
      const coupleSnap = await tx.get(coupleRef);
      const couple = coupleSnap.data();
      const receiverId = (couple.members || []).find((x) => x !== uid);
      const receiverRef = doc(db, "users", receiverId);
      const touchRef = doc(collection(db, "touches"));
      tx.set(touchRef, {
        id: touchRef.id,
        coupleId: sender.coupleId,
        senderId: uid,
        receiverId,
        createdAt: serverTimestamp(),
        device: "web",
        appVersion: "web",
      });
      tx.update(coupleRef, {
        lastTouchAt: serverTimestamp(),
        totalTouch: increment(1),
        streak: Math.max(couple.streak || 0, 1),
        longestStreak: Math.max(couple.longestStreak || 0, 1),
      });
      tx.update(senderRef, { lastTouchAt: serverTimestamp(), totalTouch: increment(1), updatedAt: serverTimestamp() });
      tx.update(receiverRef, { lastTouchAt: serverTimestamp(), totalTouch: increment(1), updatedAt: serverTimestamp() });
    });
  },
};

function emptyStats() {
  return { total: 0, today: 0, week: 0, month: 0, streak: 0, best: 0 };
}
