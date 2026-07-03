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

function showTouchNotification(payload) {
  payload = payload || {};
  var notification = payload.notification || {};
  var title = notification.title || "Touch";
  var options = {
    body: notification.body || "Someone is thinking of you.",
    icon: "/icon-192.png",
    badge: "/icon-192.png",
    data: payload.data || {},
  };

  return self.registration.showNotification(title, options);
}

try {
  var messaging = firebase.messaging();
  messaging.onBackgroundMessage(showTouchNotification);
} catch (error) {
  console.warn("Firebase Messaging is not available in this browser.", error);
}

self.addEventListener("push", function (event) {
  var payload = {};
  if (event.data) {
    try {
      payload = event.data.json();
    } catch (error) {
      payload = { notification: { body: event.data.text() } };
    }
  }

  event.waitUntil(showTouchNotification(payload));
});

self.addEventListener("notificationclick", function (event) {
  event.notification.close();
  event.waitUntil(clients.matchAll({ type: "window", includeUncontrolled: true }).then(function (clientList) {
    for (var i = 0; i < clientList.length; i += 1) {
      var client = clientList[i];
      if ("focus" in client) return client.focus();
    }

    if (clients.openWindow) return clients.openWindow("/");
    return undefined;
  }));
});
