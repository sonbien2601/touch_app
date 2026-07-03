import '../entities/invite_code.dart';
import '../repositories/pairing_repository.dart';

final class CreateInviteCode {
  const CreateInviteCode(this._repository);

  final PairingRepository _repository;

  Future<InviteCode> call() => _repository.createInviteCode();
}

