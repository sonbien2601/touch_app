import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../../../../core/errors/app_exception.dart';
import '../../domain/entities/home_summary.dart';
import '../../domain/entities/touch_event.dart';
import '../../domain/entities/touch_statistics.dart';
import '../../domain/repositories/touch_repository.dart';
import '../datasources/offline_touch_queue.dart';
import '../datasources/touch_remote_datasource.dart';
import '../models/touch_event_model.dart';

class FirebaseTouchRepository implements TouchRepository {
  FirebaseTouchRepository({
    required TouchRemoteDatasource remote,
    required OfflineTouchQueue offlineQueue,
    required Connectivity connectivity,
    required Future<PackageInfo> packageInfo,
  })  : _remote = remote,
        _offlineQueue = offlineQueue,
        _connectivity = connectivity,
        _packageInfo = packageInfo;

  final TouchRemoteDatasource _remote;
  final OfflineTouchQueue _offlineQueue;
  final Connectivity _connectivity;
  final Future<PackageInfo> _packageInfo;

  @override
  Stream<HomeSummary> watchHomeSummary(String uid) async* {
    await for (final userSnapshot in _remote.watchUser(uid)) {
      final user = userSnapshot.data();
      final coupleId = user?['coupleId'] as String?;
      if (coupleId == null || coupleId.isEmpty) {
        yield HomeSummary(
          coupleId: null,
          myAvatar: user?['avatar'] as String?,
          partnerAvatar: null,
          partnerName: null,
          isPaired: false,
          partnerLastSeen: null,
          lastTouch: null,
          statistics: const TouchStatistics(
            totalTouch: 0,
            today: 0,
            thisWeek: 0,
            thisMonth: 0,
            currentStreak: 0,
            longestStreak: 0,
          ),
        );
        continue;
      }

      yield* _buildPairedSummary(uid, user, coupleId);
    }
  }

  Stream<HomeSummary> _buildPairedSummary(
    String uid,
    Map<String, dynamic>? user,
    String coupleId,
  ) async* {
    await for (final coupleSnapshot in _remote.watchCouple(coupleId)) {
      final couple = coupleSnapshot.data() ?? <String, dynamic>{};
      final members = List<String>.from(couple['members'] as List? ?? const []);
      final partnerId = members.firstWhere((member) => member != uid, orElse: () => '');
      final stats = await getStatistics(coupleId);
      final lastTouch = await getLastTouch(coupleId);
      Map<String, dynamic>? partner;

      if (partnerId.isNotEmpty) {
        final partnerSnapshot = await _remote.watchPartner(partnerId).first;
        partner = partnerSnapshot.data();
      }

      yield HomeSummary(
        coupleId: coupleId,
        myAvatar: user?['avatar'] as String?,
        partnerAvatar: partner?['avatar'] as String?,
        partnerName: partner?['name'] as String?,
        isPaired: true,
        partnerLastSeen: _dateTime(partner?['lastSeen']),
        lastTouch: lastTouch,
        statistics: stats,
      );
    }
  }

  @override
  Future<void> sendTouch(String uid) async {
    final online = await _isOnline();
    final packageInfo = await _packageInfo;
    final queued = QueuedTouch(
      uid: uid,
      createdAt: DateTime.now().toUtc(),
      device: 'ios',
      appVersion: packageInfo.version,
    );

    if (!online) {
      await _offlineQueue.enqueue(queued);
      throw const NetworkException('Offline. Touch queued and will sync later.');
    }

    await _sendQueuedTouch(queued);
    await flushOfflineQueue();
  }

  @override
  Future<void> flushOfflineQueue() async {
    if (!await _isOnline()) {
      return;
    }

    final items = await _offlineQueue.load();
    var sent = 0;
    for (final item in items) {
      await _sendQueuedTouch(item);
      sent++;
    }

    if (sent > 0) {
      await _offlineQueue.removeFirst(sent);
    }
  }

  Future<void> _sendQueuedTouch(QueuedTouch touch) async {
    try {
      await _remote.sendTouch(
        uid: touch.uid,
        device: touch.device,
        appVersion: touch.appVersion,
      );
    } on StateError catch (error) {
      throw AuthException(error.message);
    }
  }

  @override
  Future<TouchEvent?> getLastTouch(String coupleId) async {
    final snapshot = await _remote.getHistory(coupleId, 1);
    if (snapshot.docs.isEmpty) {
      return null;
    }

    return TouchEventModel.fromSnapshot(snapshot.docs.first).toEntity();
  }

  @override
  Future<List<TouchEvent>> getTouchHistory(String coupleId, {int limit = 20}) async {
    final snapshot = await _remote.getHistory(coupleId, limit);
    return snapshot.docs
        .map((doc) => TouchEventModel.fromSnapshot(doc).toEntity())
        .toList();
  }

  @override
  Future<TouchStatistics> getStatistics(String coupleId) async {
    final now = DateTime.now();
    final monthStart = DateTime(now.year, now.month);
    final weekStart = DateTime(now.year, now.month, now.day).subtract(Duration(days: now.weekday - 1));
    final todayStart = DateTime(now.year, now.month, now.day);
    final snapshot = await _remote.getTouchesSince(coupleId, monthStart);
    final couple = (await _remote.getCouple(coupleId)).data() ?? <String, dynamic>{};
    final events = snapshot.docs
        .map((doc) => TouchEventModel.fromSnapshot(doc).toEntity())
        .toList();

    return TouchStatistics(
      totalTouch: couple['totalTouch'] as int? ?? events.length,
      today: events.where((event) => event.createdAt.isAfter(todayStart)).length,
      thisWeek: events.where((event) => event.createdAt.isAfter(weekStart)).length,
      thisMonth: events.length,
      currentStreak: couple['streak'] as int? ?? _streak(events),
      longestStreak: couple['longestStreak'] as int? ?? _longestStreak(events),
    );
  }

  Future<bool> _isOnline() async {
    final result = await _connectivity.checkConnectivity();
    return !result.contains(ConnectivityResult.none);
  }

  int _streak(List<TouchEvent> events) {
    final days = events.map((event) => DateTime(event.createdAt.year, event.createdAt.month, event.createdAt.day)).toSet();
    var count = 0;
    var cursor = DateTime.now();
    while (days.contains(DateTime(cursor.year, cursor.month, cursor.day))) {
      count++;
      cursor = cursor.subtract(const Duration(days: 1));
    }
    return count;
  }

  int _longestStreak(List<TouchEvent> events) {
    final days = events
        .map((event) => DateTime(event.createdAt.year, event.createdAt.month, event.createdAt.day))
        .toSet()
        .toList()
      ..sort();

    var longest = 0;
    var current = 0;
    DateTime? previous;
    for (final day in days) {
      current = previous == null || day.difference(previous).inDays == 1 ? current + 1 : 1;
      longest = current > longest ? current : longest;
      previous = day;
    }
    return longest;
  }

  DateTime? _dateTime(Object? value) {
    if (value is Timestamp) {
      return value.toDate();
    }
    return null;
  }

}
