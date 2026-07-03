import 'package:cloud_functions/cloud_functions.dart';

import '../../../../core/errors/app_exception.dart';
import '../../domain/entities/couple.dart';
import '../../domain/entities/invite_code.dart';
import '../../domain/repositories/pairing_repository.dart';
import '../datasources/pairing_remote_datasource.dart';

class FirebasePairingRepository implements PairingRepository {
  const FirebasePairingRepository(this._datasource);

  final PairingRemoteDatasource _datasource;

  @override
  Future<InviteCode> createInviteCode() async {
    try {
      final data = await _datasource.createInviteCode();
      return InviteCode.parse(data['code'] as String);
    } on FirebaseFunctionsException catch (error) {
      throw AuthException(_functionMessage(error));
    }
  }

  @override
  Future<Couple> joinCouple(InviteCode code) async {
    try {
      final data = await _datasource.joinCouple(code.value);
      return Couple(
        id: data['coupleId'] as String,
        userA: data['userA'] as String,
        userB: data['userB'] as String,
      );
    } on FirebaseFunctionsException catch (error) {
      throw AuthException(_functionMessage(error));
    }
  }

  String _functionMessage(FirebaseFunctionsException error) {
    return switch (error.code) {
      'unauthenticated' => 'Please sign in again.',
      'failed-precondition' => error.message ?? 'Pairing is not available.',
      'not-found' => 'Pairing code is invalid or expired.',
      'invalid-argument' => 'Pairing code is invalid.',
      _ => 'Cannot pair right now. Please try again.',
    };
  }
}

