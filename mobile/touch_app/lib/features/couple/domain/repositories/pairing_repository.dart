import '../entities/couple.dart';
import '../entities/invite_code.dart';

abstract interface class PairingRepository {
  Future<InviteCode> createInviteCode();

  Future<Couple> joinCouple(InviteCode code);
}

