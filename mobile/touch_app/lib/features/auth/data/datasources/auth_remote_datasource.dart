import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthRemoteDatasource {
  AuthRemoteDatasource({
    required FirebaseAuth auth,
    required FirebaseFirestore firestore,
  })  : _auth = auth,
        _firestore = firestore;

  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;

  Stream<User?> authStateChanges() => _auth.authStateChanges();

  Future<UserCredential> signInWithEmail(String email, String password) {
    return _auth.signInWithEmailAndPassword(email: email, password: password);
  }

  Future<UserCredential> registerWithEmail(String email, String password) {
    return _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  Future<void> ensureUserDocument({
    required User user,
    required String name,
  }) async {
    final ref = _firestore.collection('users').doc(user.uid);
    final snapshot = await ref.get();

    if (snapshot.exists) {
      await ref.update({
        'lastSeen': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
      return;
    }

    await ref.set({
      'uid': user.uid,
      'name': name,
      'email': user.email,
      'avatar': null,
      'online': true,
      'lastSeen': FieldValue.serverTimestamp(),
      'fcmToken': null,
      'battery': {
        'shared': false,
        'level': null,
        'updatedAt': null,
      },
      'coupleId': null,
      'lastTouchAt': null,
      'totalTouch': 0,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> signOut() => _auth.signOut();
}
