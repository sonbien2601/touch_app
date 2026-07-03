import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/errors/app_exception.dart';
import '../../data/datasources/pairing_remote_datasource.dart';
import '../../data/repositories/firebase_pairing_repository.dart';
import '../../domain/repositories/pairing_repository.dart';
import '../../domain/usecases/create_invite_code.dart';
import '../../domain/usecases/join_couple.dart';

final pairingRemoteDatasourceProvider = Provider<PairingRemoteDatasource>((ref) {
  return PairingRemoteDatasource(FirebaseFunctions.instanceFor(region: 'asia-southeast1'));
});

final pairingRepositoryProvider = Provider<PairingRepository>((ref) {
  return FirebasePairingRepository(ref.watch(pairingRemoteDatasourceProvider));
});

final pairingControllerProvider =
    StateNotifierProvider<PairingController, AsyncValue<PairingState>>((ref) {
  return PairingController(ref.watch(pairingRepositoryProvider));
});

class PairingState {
  const PairingState({
    this.inviteCode,
    this.coupleId,
  });

  final String? inviteCode;
  final String? coupleId;

  PairingState copyWith({
    String? inviteCode,
    String? coupleId,
  }) {
    return PairingState(
      inviteCode: inviteCode ?? this.inviteCode,
      coupleId: coupleId ?? this.coupleId,
    );
  }
}

class PairingController extends StateNotifier<AsyncValue<PairingState>> {
  PairingController(this._repository)
      : super(const AsyncData(PairingState()));

  final PairingRepository _repository;

  Future<void> createInviteCode() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final code = await CreateInviteCode(_repository)();
      return PairingState(inviteCode: code.value);
    });
  }

  Future<void> joinCouple(String code) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final couple = await JoinCouple(_repository)(code);
      return PairingState(coupleId: couple.id);
    });
  }

  String errorText(Object error) {
    if (error is AppException) {
      return error.message;
    }
    if (error is FormatException) {
      return error.message;
    }
    return 'Cannot pair right now. Please try again.';
  }
}

