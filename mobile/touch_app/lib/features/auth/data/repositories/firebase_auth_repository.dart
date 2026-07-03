import 'package:firebase_auth/firebase_auth.dart';

import '../../../../core/errors/app_exception.dart';
import '../../domain/entities/app_user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_datasource.dart';

class FirebaseAuthRepository implements AuthRepository {
  FirebaseAuthRepository(this._datasource);

  final AuthRemoteDatasource _datasource;

  @override
  Stream<AppUser?> authStateChanges() {
    return _datasource.authStateChanges().map((user) => user?.toAppUser());
  }

  @override
  Future<AppUser> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _datasource.signInWithEmail(email, password);
      final user = credential.user;
      if (user == null) {
        throw const AuthException('Cannot sign in. Please try again.');
      }

      await _datasource.ensureUserDocument(
        user: user,
        name: user.displayName ?? 'Touch',
      );

      return user.toAppUser();
    } on FirebaseAuthException catch (error) {
      throw AuthException(_authMessage(error));
    } on FirebaseException catch (_) {
      throw const NetworkException('Connection problem. Please try again.');
    }
  }

  @override
  Future<AppUser> registerWithEmail({
    required String email,
    required String password,
    required String name,
  }) async {
    try {
      final credential = await _datasource.registerWithEmail(email, password);
      final user = credential.user;
      if (user == null) {
        throw const AuthException('Cannot create account. Please try again.');
      }

      await user.updateDisplayName(name);
      await _datasource.ensureUserDocument(user: user, name: name);

      return user.toAppUser(nameOverride: name);
    } on FirebaseAuthException catch (error) {
      throw AuthException(_authMessage(error));
    } on FirebaseException catch (_) {
      throw const NetworkException('Connection problem. Please try again.');
    }
  }

  @override
  Future<void> signOut() => _datasource.signOut();

  String _authMessage(FirebaseAuthException error) {
    return switch (error.code) {
      'email-already-in-use' => 'This email is already registered.',
      'invalid-email' => 'Email is invalid.',
      'user-not-found' || 'wrong-password' || 'invalid-credential' =>
        'Email or password is incorrect.',
      'weak-password' => 'Password is too weak.',
      _ => 'Authentication failed. Please try again.',
    };
  }
}

extension on User {
  AppUser toAppUser({String? nameOverride}) {
    return AppUser(
      uid: uid,
      email: email,
      name: nameOverride ?? displayName ?? 'Touch',
      avatar: photoURL,
    );
  }
}
