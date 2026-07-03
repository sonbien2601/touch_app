importScripts("https://www.gstatic.com/firebasejs/10.12.5/firebase-app-compat.js");
importScripts("https://www.gstatic.com/firebasejs/10.12.5/firebase-messaging-compat.js");

firebase.initializeApp({
  apiKey: "AIzaSyBMdB7yam9cln1pGA4tu5vu1YSWQNYj0G4",
  authDomain: "touchapp-65d7b.firebaseapp.com",
  projectId: "touchapp-65d7b",
  storageBucket: "touchapp-65d7b.firebasestorage.app",
  messagingSenderId: "603507359681",
  appId: "1:603507359681:web:7895f46a455a7f6d90b940",
  measurementId: "G-V9134MRH68",
});

const messaging = firebase.messaging();

messaging.onBackgroundMessage((payload) => {
  const title = payload.notification?.title || "Touch";
  const options = {
    body: payload.notification?.body || "Someone is thinking of you.",
    icon: "/icon-192.png",
    badge: "/icon-192.png",
    data: payload.data || {},
  };

  self.registration.showNotification(title, options);
});

self.addEventListener("notificationclick", (event) => {
  event.notification.close();
  event.waitUntil(clients.openWindow("/"));
});
