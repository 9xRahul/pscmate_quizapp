import 'package:firebase_auth/firebase_auth.dart';
import 'package:pscmate/features/auth/domain/entities/AuthUser.dart';
import 'package:pscmate/features/auth/domain/repositories/auth_repository.dart';
import 'package:pscmate/features/data/datasources/firebase_auth_datasource.dart';


class AuthRepositoryImpl implements AuthRepository {
  final FirebaseAuthDataSource _ds;

  AuthRepositoryImpl(this._ds);

  AuthUser _mapUser(User user) => AuthUser(
    uid: user.uid,
    email: user.email,
    displayName: user.displayName,
    phoneNumber: user.phoneNumber,
  );

  @override
  Future<AuthUser?> getCurrentUser() async {
    final user = _ds.getCurrentUser();
    return user == null ? null : _mapUser(user);
  }

  @override
  Stream<AuthUser?> authStateChanges() => _ds.authStateChanges().map(
    (user) => user == null ? null : _mapUser(user),
  );

  @override
  Future<AuthUser> signInWithGoogle() async {
    final user = await _ds.signInWithGoogle();
    return _mapUser(user);
  }

  @override
  Future<AuthUser> signInWithEmailPassword({
    required String email,
    required String password,
  }) async {
    final user = await _ds.signInWithEmailPassword(email, password);
    return _mapUser(user);
  }

  @override
  Future<AuthUser> registerWithEmailPassword({
    required String email,
    required String password,
  }) async {
    final user = await _ds.registerWithEmailPassword(email, password);
    return _mapUser(user);
  }

  @override
  Future<String> verifyPhoneNumber({
    required String phoneNumber,
    required void Function(String verificationId) codeSent,
    required void Function(String error) onError,
  }) {
    return _ds.verifyPhoneNumber(
      phoneNumber: phoneNumber,
      codeSent: codeSent,
      onError: onError,
    );
  }

  @override
  Future<AuthUser> signInWithSmsCode({
    required String verificationId,
    required String smsCode,
  }) async {
    final user = await _ds.signInWithSmsCode(
      verificationId: verificationId,
      smsCode: smsCode,
    );
    return _mapUser(user);
  }

  @override
  Future<void> signOut() => _ds.signOut();
}
