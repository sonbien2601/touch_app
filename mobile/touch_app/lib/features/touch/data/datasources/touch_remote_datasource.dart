import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';

class TouchRemoteDatasource {
  TouchRemoteDatasource({
    required FirebaseFirestore firestore,
  }) : _firestore = firestore;

  final FirebaseFirestore _firestore;

  Stream<DocumentSnapshot<Map<String, dynamic>>> watchUser(String uid) {
    return _firestore.collection('users').doc(uid).snapshots();
  }

  Stream<DocumentSnapshot<Map<String, dynamic>>> watchCouple(String coupleId) {
    return _firestore.collection('couples').doc(coupleId).snapshots();
  }

  Future<DocumentSnapshot<Map<String, dynamic>>> getCouple(String coupleId) {
    return _firestore.collection('couples').doc(coupleId).get();
  }

  Stream<DocumentSnapshot<Map<String, dynamic>>> watchPartner(String partnerId) {
    return _firestore.collection('users').doc(partnerId).snapshots();
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> watchLastTouch(String coupleId) {
    return _firestore
        .collection('touches')
        .where('coupleId', isEqualTo: coupleId)
        .orderBy('createdAt', descending: true)
        .limit(1)
        .snapshots();
  }

  Future<void> sendTouch({
    required String uid,
    required String device,
    required String appVersion,
  }) async {
    final senderRef = _firestore.collection('users').doc(uid);

    await _firestore.runTransaction((transaction) async {
      final senderSnapshot = await transaction.get(senderRef);
      final sender = senderSnapshot.data();
      final coupleId = sender?['coupleId'] as String?;
      if (sender == null || coupleId == null || coupleId.isEmpty) {
        throw StateError('User is not paired.');
      }

      final coupleRef = _firestore.collection('couples').doc(coupleId);
      final coupleSnapshot = await transaction.get(coupleRef);
      final couple = coupleSnapshot.data();
      final members = List<String>.from(couple?['members'] as List? ?? const []);
      if (couple == null || members.length != 2 || !members.contains(uid)) {
        throw StateError('User is not part of this couple.');
      }

      final receiverId = members.firstWhere((member) => member != uid);
      final receiverRef = _firestore.collection('users').doc(receiverId);
      final receiverSnapshot = await transaction.get(receiverRef);
      if (!receiverSnapshot.exists) {
        throw StateError('Receiver profile is missing.');
      }

      final touchRef = _firestore.collection('touches').doc();
      final nextStreak = _nextStreak(couple['lastTouchAt'], couple['streak']);
      final longestStreak = max(
        couple['longestStreak'] as int? ?? 0,
        nextStreak,
      );

      transaction.set(touchRef, {
        'id': touchRef.id,
        'coupleId': coupleId,
        'senderId': uid,
        'receiverId': receiverId,
        'createdAt': FieldValue.serverTimestamp(),
        'device': device,
        'appVersion': appVersion,
      });
      transaction.update(coupleRef, {
        'lastTouchAt': FieldValue.serverTimestamp(),
        'totalTouch': FieldValue.increment(1),
        'streak': nextStreak,
        'longestStreak': longestStreak,
      });
      transaction.update(senderRef, {
        'lastTouchAt': FieldValue.serverTimestamp(),
        'totalTouch': FieldValue.increment(1),
        'updatedAt': FieldValue.serverTimestamp(),
      });
      transaction.update(receiverRef, {
        'lastTouchAt': FieldValue.serverTimestamp(),
        'totalTouch': FieldValue.increment(1),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    });
  }

  Future<QuerySnapshot<Map<String, dynamic>>> getHistory(String coupleId, int limit) {
    return _firestore
        .collection('touches')
        .where('coupleId', isEqualTo: coupleId)
        .orderBy('createdAt', descending: true)
        .limit(limit)
        .get();
  }

  Future<QuerySnapshot<Map<String, dynamic>>> getTouchesSince(String coupleId, DateTime since) {
    return _firestore
        .collection('touches')
        .where('coupleId', isEqualTo: coupleId)
        .where('createdAt', isGreaterThanOrEqualTo: Timestamp.fromDate(since))
        .orderBy('createdAt', descending: true)
        .get();
  }

  int _nextStreak(Object? lastTouchAt, Object? streak) {
    if (lastTouchAt is! Timestamp) {
      return 1;
    }

    final now = DateTime.now();
    final last = lastTouchAt.toDate();
    final today = DateTime(now.year, now.month, now.day);
    final lastDay = DateTime(last.year, last.month, last.day);
    final previous = streak as int? ?? 0;
    final diff = today.difference(lastDay).inDays;

    if (diff == 0) return previous;
    if (diff == 1) return previous + 1;
    return 1;
  }
}
