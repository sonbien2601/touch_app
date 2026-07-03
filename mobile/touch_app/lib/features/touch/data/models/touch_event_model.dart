import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/touch_event.dart';

class TouchEventModel {
  const TouchEventModel({
    required this.id,
    required this.coupleId,
    required this.senderId,
    required this.receiverId,
    required this.createdAt,
    required this.device,
    required this.appVersion,
  });

  final String id;
  final String coupleId;
  final String senderId;
  final String receiverId;
  final DateTime createdAt;
  final String device;
  final String appVersion;

  factory TouchEventModel.fromSnapshot(DocumentSnapshot<Map<String, dynamic>> snapshot) {
    final data = snapshot.data() ?? <String, dynamic>{};
    return TouchEventModel.fromMap(data, fallbackId: snapshot.id);
  }

  factory TouchEventModel.fromMap(Map<String, dynamic> data, {String fallbackId = ''}) {
    final createdAt = data['createdAt'];

    return TouchEventModel(
      id: data['id'] as String? ?? fallbackId,
      coupleId: data['coupleId'] as String? ?? '',
      senderId: data['senderId'] as String? ?? '',
      receiverId: data['receiverId'] as String? ?? '',
      createdAt: createdAt is Timestamp ? createdAt.toDate() : DateTime.fromMillisecondsSinceEpoch(0),
      device: data['device'] as String? ?? 'ios',
      appVersion: data['appVersion'] as String? ?? 'unknown',
    );
  }

  TouchEvent toEntity() {
    return TouchEvent(
      id: id,
      coupleId: coupleId,
      senderId: senderId,
      receiverId: receiverId,
      createdAt: createdAt,
      device: device,
      appVersion: appVersion,
    );
  }
}
