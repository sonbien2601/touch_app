import '../../../../core/errors/app_exception.dart';
import '../../domain/entities/couple.dart';
import '../../domain/entities/invite_code.dart';
import '../../domain/repositories/pairing_repository.dart';
import '../datasources/pairing_remote_datasource.dart';

class FirebasePairingRepository implements PairingRepository {
  const FirebasePairingRepository({
    required PairingRemoteDatasource datasource,
    required String uid,
  })  : _datasource = datasource,
        _uid = uid;

  final PairingRemoteDatasource _datasource;
  final String _uid;

  @override
  Future<InviteCode> createInviteCode() async {
    try {
      final data = await _datasource.createInviteCode(_uid);
      return InviteCode.parse(data['code'] as String);
    } catch (error) {
      throw AuthException(_message(error));
    }
  }

  @override
  Future<Couple> joinCouple(InviteCode code) async {
    try {
      final data = await _datasource.joinCouple(_uid, code.value);
      return Couple(
        id: data['coupleId'] as String,
        userA: data['userA'] as String,
        userB: data['userB'] as String,
      );
    } catch (error) {
      throw AuthException(_message(error));
    }
  }

  String _message(Object error) {
    if (error is StateError) {
      return error.message;
    }
    return 'Cannot pair right now. Please try again.';
  }
}
