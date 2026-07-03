import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';

class TouchRemoteDatasource {
  TouchRemoteDatasource({
    required FirebaseFirestore firestore,
    required FirebaseFunctions functions,
  })  : _firestore = firestore,
        _functions = functions;

  final FirebaseFirestore _firestore;
  final FirebaseFunctions _functions;

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
    required String device,
    required String appVersion,
  }) async {
    await _functions.httpsCallable('sendTouch').call({
      'device': device,
      'appVersion': appVersion,
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
}
