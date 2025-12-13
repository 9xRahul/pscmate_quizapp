// lib/features/auth/data/datasources/firebase_auth_datasource.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

/// FirebaseAuthDataSource: wraps FirebaseAuth + Firestore helpers used by the repo.
class FirebaseAuthDataSource {
  final FirebaseAuth _firebaseAuth;
  final GoogleSignIn _googleSignIn;
  final FirebaseFirestore _firestore;

  FirebaseAuthDataSource({
    FirebaseAuth? firebaseAuth,
    GoogleSignIn? googleSignIn,
    FirebaseFirestore? firestore,
  }) : _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance,
       _googleSignIn = googleSignIn ?? GoogleSignIn(),
       _firestore = firestore ?? FirebaseFirestore.instance;

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

  // -------------------------
  // Additional helpers: Firestore users collection
  // -------------------------
  CollectionReference get _usersRef => _firestore.collection('users');

  /// Save or merge user profile at users/{uid}
  Future<void> saveUserProfile({
    required String uid,
    required String name,
    required String email,
    String? phone,
    int? age,
    String? qualification,
    String? profilePic,
  }) async {
    final docRef = _usersRef.doc(uid);
    final now = FieldValue.serverTimestamp();
    await docRef.set({
      'uid': uid,
      'name': name,
      'email': email,
      'prfoilePic': profilePic,
      if (phone != null) 'phoneNumber': phone,
      if (age != null) 'age': age,
      if (qualification != null) 'qualification': qualification,
      'createdAt': now,
      'updatedAt': now,
    }, SetOptions(merge: true));
  }

  /// Fetch user document as Map<String, dynamic> or null if missing
  Future<Map<String, dynamic>?> fetchUserDoc(String uid) async {
    final doc = await _usersRef.doc(uid).get();
    if (!doc.exists) return null;
    return doc.data() as Map<String, dynamic>?;
  }

  /// Update (merge) user document fields
  Future<void> updateUserDoc(String uid, Map<String, dynamic> data) async {
    final docRef = _usersRef.doc(uid);
    final merged = Map<String, dynamic>.from(data);
    merged['updatedAt'] = FieldValue.serverTimestamp();
    await docRef.set(merged, SetOptions(merge: true));
  }

  /// Update Firebase Auth user's displayName (optional)
  Future<void> updateFirebaseDisplayName(String displayName) async {
    final user = _firebaseAuth.currentUser;
    if (user != null) {
      await user.updateDisplayName(displayName);
      await user.reload();
    }
  }
}
