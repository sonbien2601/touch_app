import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class OfflineTouchQueue {
  OfflineTouchQueue(this._preferences);

  static const _key = 'offline_touch_queue';

  final SharedPreferences _preferences;

  Future<void> enqueue(QueuedTouch touch) async {
    final items = await load();
    items.add(touch);
    await _save(items);
  }

  Future<List<QueuedTouch>> load() async {
    final raw = _preferences.getString(_key);
    if (raw == null || raw.isEmpty) {
      return [];
    }

    final decoded = jsonDecode(raw) as List<dynamic>;
    return decoded
        .map((item) => QueuedTouch.fromJson(Map<String, dynamic>.from(item as Map)))
        .toList();
  }

  Future<void> removeFirst(int count) async {
    final items = await load();
    final remaining = items.skip(count).toList();
    await _save(remaining);
  }

  Future<void> clear() => _preferences.remove(_key);

  Future<void> _save(List<QueuedTouch> items) {
    return _preferences.setString(
      _key,
      jsonEncode(items.map((item) => item.toJson()).toList()),
    );
  }
}

class QueuedTouch {
  const QueuedTouch({
    required this.uid,
    required this.createdAt,
    required this.device,
    required this.appVersion,
  });

  final String uid;
  final DateTime createdAt;
  final String device;
  final String appVersion;

  Map<String, dynamic> toJson() {
    return {
      'createdAt': createdAt.toIso8601String(),
      'uid': uid,
      'device': device,
      'appVersion': appVersion,
    };
  }

  factory QueuedTouch.fromJson(Map<String, dynamic> json) {
    return QueuedTouch(
      createdAt: DateTime.parse(json['createdAt'] as String),
      uid: json['uid'] as String? ?? '',
      device: json['device'] as String,
      appVersion: json['appVersion'] as String,
    );
  }
}
