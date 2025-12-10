import 'package:pscmate/features/auth/domain/entities/AuthUser.dart';


abstract class AuthRepository {
  Future<AuthUser?> getCurrentUser();
  Stream<AuthUser?> authStateChanges();

  Future<AuthUser> signInWithGoogle();
  Future<AuthUser> signInWithEmailPassword({
    required String email,
    required String password,
  });
  Future<AuthUser> registerWithEmailPassword({
    required String email,
    required String password,
  });

  // Phone auth
  Future<String> verifyPhoneNumber({
    required String phoneNumber,
    required void Function(String verificationId) codeSent,
    required void Function(String error) onError,
  });

  Future<AuthUser> signInWithSmsCode({
    required String verificationId,
    required String smsCode,
  });

  Future<void> signOut();
}
