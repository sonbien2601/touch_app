import '../entities/home_summary.dart';
import '../entities/touch_event.dart';
import '../entities/touch_statistics.dart';

abstract interface class TouchRepository {
  Stream<HomeSummary> watchHomeSummary(String uid);

  Future<void> sendTouch(String uid);

  Future<TouchEvent?> getLastTouch(String coupleId);

  Future<List<TouchEvent>> getTouchHistory(String coupleId, {int limit = 20});

  Future<TouchStatistics> getStatistics(String coupleId);

  Future<void> flushOfflineQueue();
}

