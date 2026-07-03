import '../entities/app_user.dart';
import '../repositories/auth_repository.dart';

final class RegisterWithEmail {
  const RegisterWithEmail(this._repository);

  final AuthRepository _repository;

  Future<AppUser> call({
    required String email,
    required String password,
    required String name,
  }) {
    return _repository.registerWithEmail(
      email: email,
      password: password,
      name: name,
    );
  }
}

