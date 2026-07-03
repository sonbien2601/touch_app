import '../repositories/touch_repository.dart';

final class SendTouch {
  const SendTouch(this._repository);

  final TouchRepository _repository;

  Future<void> call(String uid) => _repository.sendTouch(uid);
}

