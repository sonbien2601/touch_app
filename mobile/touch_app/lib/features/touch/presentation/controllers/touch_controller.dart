import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/errors/app_exception.dart';
import '../../data/datasources/offline_touch_queue.dart';
import '../../data/datasources/touch_remote_datasource.dart';
import '../../data/repositories/firebase_touch_repository.dart';
import '../../domain/entities/home_summary.dart';
import '../../domain/repositories/touch_repository.dart';
import '../../domain/usecases/send_touch.dart';

final touchRemoteDatasourceProvider = Provider<TouchRemoteDatasource>((ref) {
  return TouchRemoteDatasource(
    firestore: FirebaseFirestore.instance,
  );
});

final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError('SharedPreferences must be overridden at app startup.');
});

final touchRepositoryProvider = Provider<TouchRepository>((ref) {
  return FirebaseTouchRepository(
    remote: ref.watch(touchRemoteDatasourceProvider),
    offlineQueue: OfflineTouchQueue(ref.watch(sharedPreferencesProvider)),
    connectivity: Connectivity(),
    packageInfo: PackageInfo.fromPlatform(),
  );
});

final homeSummaryProvider = StreamProvider.family<HomeSummary, String>((ref, uid) {
  return ref.watch(touchRepositoryProvider).watchHomeSummary(uid);
});

final touchControllerProvider =
    StateNotifierProvider<TouchController, AsyncValue<TouchControllerState>>((ref) {
  return TouchController(ref.watch(touchRepositoryProvider));
});

class TouchControllerState {
  const TouchControllerState({
    this.isOffline = false,
    this.lastSentAt,
  });

  final bool isOffline;
  final DateTime? lastSentAt;
}

class TouchController extends StateNotifier<AsyncValue<TouchControllerState>> {
  TouchController(this._repository) : super(const AsyncData(TouchControllerState()));

  static const debounce = Duration(seconds: 2);

  final TouchRepository _repository;
  DateTime? _lastTapAt;

  Future<void> send(String uid) async {
    final now = DateTime.now();
    if (_lastTapAt != null && now.difference(_lastTapAt!) < debounce) {
      return;
    }

    _lastTapAt = now;
    state = const AsyncLoading();
    try {
      await SendTouch(_repository)(uid);
      state = AsyncData(TouchControllerState(lastSentAt: now));
    } on NetworkException catch (error, stackTrace) {
      state = AsyncError(error, stackTrace);
      state = const AsyncData(TouchControllerState(isOffline: true));
    } catch (error, stackTrace) {
      state = AsyncError(error, stackTrace);
    }
  }

  Future<void> flushQueue() => _repository.flushOfflineQueue();

  String errorText(Object error) {
    if (error is AppException) {
      return error.message;
    }
    return 'Cannot send touch right now. Please try again.';
  }
}
