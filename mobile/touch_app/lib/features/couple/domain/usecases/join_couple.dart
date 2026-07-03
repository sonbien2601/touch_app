import '../entities/couple.dart';
import '../entities/invite_code.dart';
import '../repositories/pairing_repository.dart';

final class JoinCouple {
  const JoinCouple(this._repository);

  final PairingRepository _repository;

  Future<Couple> call(String rawCode) {
    return _repository.joinCouple(InviteCode.parse(rawCode));
  }
}

