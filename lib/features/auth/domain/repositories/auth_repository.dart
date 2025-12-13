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

  // New profile methods
  Future<void> registerWithEmailAndProfile({
    required String email,
    required String password,
    required String name,
    String? phone,
    int? age,
    String? qualification,
  });

  Future<void> saveUserProfile({
    required String uid,
    required String name,
    String? phone,
    int? age,
    String? qualification,
  });

  Future<AuthUser?> fetchUserProfile(String uid);

  Future<void> updateUserProfile({
    required String uid,
    String? name,
    String? phone,
    int? age,
    String? qualification,
  });
}
