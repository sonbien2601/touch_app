import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';

class PairingRemoteDatasource {
  PairingRemoteDatasource(this._firestore);

  static const _characters = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';
  static const _codeLength = 6;

  final FirebaseFirestore _firestore;

  Future<Map<String, dynamic>> createInviteCode(String uid) async {
    final userRef = _firestore.collection('users').doc(uid);

    return _firestore.runTransaction((transaction) async {
      final userSnapshot = await transaction.get(userRef);
      final user = userSnapshot.data();
      if (!userSnapshot.exists || user == null) {
        throw StateError('User profile is missing.');
      }
      if (user['coupleId'] != null) {
        throw StateError('User already has a couple.');
      }

      var code = _createCode();
      var codeRef = _firestore.collection('inviteCodes').doc(code);
      var codeSnapshot = await transaction.get(codeRef);
      for (var attempt = 0; codeSnapshot.exists && attempt < 5; attempt++) {
        code = _createCode();
        codeRef = _firestore.collection('inviteCodes').doc(code);
        codeSnapshot = await transaction.get(codeRef);
      }

      if (codeSnapshot.exists) {
        throw StateError('Cannot create pairing code now.');
      }

      final expiredAt = Timestamp.fromDate(
        DateTime.now().toUtc().add(const Duration(minutes: 10)),
      );

      transaction.set(codeRef, {
        'code': code,
        'ownerId': uid,
        'expiredAt': expiredAt,
        'consumedAt': null,
        'consumedBy': null,
        'consumedCoupleId': null,
        'createdAt': FieldValue.serverTimestamp(),
      });

      return {'code': code, 'expiredAt': expiredAt.millisecondsSinceEpoch};
    });
  }

  Future<Map<String, dynamic>> joinCouple(String uid, String code) async {
    final codeRef = _firestore.collection('inviteCodes').doc(code);
    final joinerRef = _firestore.collection('users').doc(uid);

    return _firestore.runTransaction((transaction) async {
      final codeSnapshot = await transaction.get(codeRef);
      final codeData = codeSnapshot.data();
      if (!codeSnapshot.exists || codeData == null) {
        throw StateError('Pairing code is invalid or expired.');
      }

      final ownerId = codeData['ownerId'] as String?;
      final expiredAt = codeData['expiredAt'];
      if (ownerId == null ||
          ownerId == uid ||
          codeData['consumedAt'] != null ||
          expiredAt is! Timestamp ||
          expiredAt.toDate().isBefore(DateTime.now())) {
        throw StateError('Pairing code is invalid or expired.');
      }

      final ownerRef = _firestore.collection('users').doc(ownerId);
      final ownerSnapshot = await transaction.get(ownerRef);
      final joinerSnapshot = await transaction.get(joinerRef);
      final owner = ownerSnapshot.data();
      final joiner = joinerSnapshot.data();
      if (owner == null || joiner == null) {
        throw StateError('User profile is missing.');
      }
      if (owner['coupleId'] != null || joiner['coupleId'] != null) {
        throw StateError('A user already has a couple.');
      }

      final coupleRef = _firestore.collection('couples').doc();
      final members = [ownerId, uid]..sort();

      transaction.set(coupleRef, {
        'userA': members[0],
        'userB': members[1],
        'members': members,
        'inviteCode': code,
        'createdAt': FieldValue.serverTimestamp(),
        'lastTouchAt': null,
        'totalTouch': 0,
        'streak': 0,
        'longestStreak': 0,
      });
      transaction.update(ownerRef, {'coupleId': coupleRef.id, 'updatedAt': FieldValue.serverTimestamp()});
      transaction.update(joinerRef, {'coupleId': coupleRef.id, 'updatedAt': FieldValue.serverTimestamp()});
      transaction.update(codeRef, {
        'consumedAt': FieldValue.serverTimestamp(),
        'consumedBy': uid,
        'consumedCoupleId': coupleRef.id,
      });

      return {'coupleId': coupleRef.id, 'userA': members[0], 'userB': members[1]};
    });
  }

  String _createCode() {
    final random = Random.secure();
    return List.generate(
      _codeLength,
      (_) => _characters[random.nextInt(_characters.length)],
    ).join();
  }
}
