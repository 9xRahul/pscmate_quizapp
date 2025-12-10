import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class FirebaseAuthDataSource {
  final FirebaseAuth _firebaseAuth;
  final GoogleSignIn _googleSignIn;

  FirebaseAuthDataSource({
    FirebaseAuth? firebaseAuth,
    GoogleSignIn? googleSignIn,
  }) : _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance,
       _googleSignIn = googleSignIn ?? GoogleSignIn();

  FirebaseAuth get instance => _firebaseAuth;

  Stream<User?> authStateChanges() => _firebaseAuth.authStateChanges();

  User? getCurrentUser() => _firebaseAuth.currentUser;

  Future<User> signInWithGoogle() async {
    final googleUser = await _googleSignIn.signIn();
    if (googleUser == null) {
      throw Exception('Google sign-in cancelled');
    }

    final googleAuth = await googleUser.authentication;
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    final userCred = await _firebaseAuth.signInWithCredential(credential);
    final user = userCred.user;
    if (user == null) throw Exception('Google sign-in failed');
    return user;
  }

  Future<User> signInWithEmailPassword(String email, String password) async {
    final cred = await _firebaseAuth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    if (cred.user == null) throw Exception('Email sign-in failed');
    return cred.user!;
  }

  Future<User> registerWithEmailPassword(String email, String password) async {
    final cred = await _firebaseAuth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    if (cred.user == null) throw Exception('Registration failed');
    return cred.user!;
  }

  Future<String> verifyPhoneNumber({
    required String phoneNumber,
    required void Function(String verificationId) codeSent,
    required void Function(String error) onError,
  }) async {
    String? verificationId;
    await _firebaseAuth.verifyPhoneNumber(
      phoneNumber: phoneNumber,
      timeout: const Duration(seconds: 60),
      verificationCompleted: (PhoneAuthCredential credential) async {
        // Optional: auto-sign in
        await _firebaseAuth.signInWithCredential(credential);
      },
      verificationFailed: (FirebaseAuthException e) {
        onError(e.message ?? 'Phone verification failed');
      },
      codeSent: (String verId, int? resendToken) {
        verificationId = verId;
        codeSent(verId);
      },
      codeAutoRetrievalTimeout: (String verId) {
        verificationId ??= verId;
      },
    );
    if (verificationId == null) {
      throw Exception('Failed to get verificationId');
    }
    return verificationId!;
  }

  Future<User> signInWithSmsCode({
    required String verificationId,
    required String smsCode,
  }) async {
    final credential = PhoneAuthProvider.credential(
      verificationId: verificationId,
      smsCode: smsCode,
    );
    final userCred = await _firebaseAuth.signInWithCredential(credential);
    if (userCred.user == null) throw Exception('SMS sign-in failed');
    return userCred.user!;
  }

  Future<void> signOut() => _firebaseAuth.signOut();
}
