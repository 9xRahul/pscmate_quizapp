// lib/features/data/repositories/auth_repository_impl.dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:pscmate/features/auth/domain/entities/AuthUser.dart';
import 'package:pscmate/features/auth/domain/repositories/auth_repository.dart';
import 'package:pscmate/features/data/datasources/firebase_auth_datasource.dart';

class AuthRepositoryImpl implements AuthRepository {
  final FirebaseAuthDataSource _ds;

  AuthRepositoryImpl(this._ds);

  // Map from Firebase User + optional firestore doc -> AuthUser entity
  AuthUser _mapUserWithDoc(User user, Map<String, dynamic>? doc) {
    final displayNameFromDoc = doc != null ? (doc['name'] as String?) : null;
    final phoneFromDoc = doc != null ? (doc['phoneNumber'] as String?) : null;
    final profilePicFromDoc = doc != null ? (doc['photoURL'] as String?) : null;

    return AuthUser(
      uid: user.uid,
      email: user.email,
      name: displayNameFromDoc ?? user.displayName,
      phoneNumber: phoneFromDoc ?? user.phoneNumber,
      profilePic: profilePicFromDoc ?? user.photoURL,
    );
  }

  // Fallback mapping when no Firebase User object available but firestore doc exists
  AuthUser _mapFromDoc(Map<String, dynamic> doc) {
    return AuthUser(
      uid: doc['uid'] as String,
      email: doc['email'] as String?,
      name: doc['name'] as String?,
      phoneNumber: doc['phoneNumber'] as String?,
      profilePic: doc['photoURL'] as String?,
    );
  }

  // ---------- Auth basic ----------
  @override
  Stream<AuthUser?> authStateChanges() =>
      _ds.authStateChanges().asyncMap((user) async {
        if (user == null) return null;
        final doc = await _ds.fetchUserDoc(user.uid);
        return _mapUserWithDoc(user, doc);
      });

  @override
  Future<AuthUser?> getCurrentUser() async {
    final user = _ds.getCurrentUser();
    if (user == null) return null;
    final doc = await _ds.fetchUserDoc(user.uid);
    return _mapUserWithDoc(user, doc);
  }

  @override
  Future<AuthUser> signInWithGoogle() async {
    final user = await _ds.signInWithGoogle();
    final doc = await _ds.fetchUserDoc(user.uid);
    return _mapUserWithDoc(user, doc);
  }

  @override
  Future<AuthUser> signInWithEmailPassword({
    required String email,
    required String password,
  }) async {
    final user = await _ds.signInWithEmailPassword(email, password);
    final doc = await _ds.fetchUserDoc(user.uid);
    return _mapUserWithDoc(user, doc);
  }

  @override
  Future<AuthUser> registerWithEmailPassword({
    required String email,
    required String password,
  }) async {
    final user = await _ds.registerWithEmailPassword(email, password);
    final doc = await _ds.fetchUserDoc(user.uid);
    return _mapUserWithDoc(user, doc);
  }

  // ---------- Extended: register with profile (creates auth user + writes profile) ----------
  @override
  Future<AuthUser> registerWithEmailAndProfile({
    required String email,
    required String password,
    required String name,
    String? phone,
    int? age,
    String? qualification,
  }) async {
    // 1) create auth user
    final user = await _ds.registerWithEmailPassword(email, password);
    final uid = user.uid;

    try {
      // 2) save profile to firestore
      await _ds.saveUserProfile(
        uid: uid,
        name: name,
        email: email,
        phone: phone,
        age: age,
        qualification: qualification,
      );

      // 3) update displayName in FirebaseAuth
      await _ds.updateFirebaseDisplayName(name);

      // 4) fetch the saved doc and return entity
      final doc = await _ds.fetchUserDoc(uid);
      if (doc != null) {
        return _mapFromDoc(doc);
      }
      // fallback to user mapping
      return _mapUserWithDoc(user, null);
    } catch (e) {
      // rollback the auth user to avoid orphaned accounts
      try {
        await user.delete();
      } catch (_) {}
      rethrow;
    }
  }

  // ---------- Phone ----------
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
    final doc = await _ds.fetchUserDoc(user.uid);
    return _mapUserWithDoc(user, doc);
  }

  // ---------- Profile methods ----------
  @override
  Future<void> saveUserProfile({
    required String uid,
    required String name,
    String? phone,
    int? age,
    String? qualification,
  }) {
    // use current auth email if available
    final email = _ds.getCurrentUser()?.email ?? '';
    return _ds.saveUserProfile(
      uid: uid,
      name: name,
      email: email,
      phone: phone,
      age: age,
      qualification: qualification,
    );
  }

  @override
  Future<AuthUser?> fetchUserProfile(String uid) async {
    final map = await _ds.fetchUserDoc(uid);
    if (map == null) return null;
    return _mapFromDoc(map);
  }

  @override
  Future<void> updateUserProfile({
    required String uid,
    String? name,
    String? phone,
    int? age,
    String? qualification,
  }) async {
    final data = <String, dynamic>{};
    if (name != null) data['name'] = name;
    if (phone != null) data['phoneNumber'] = phone;
    if (age != null) data['age'] = age;
    if (qualification != null) data['qualification'] = qualification;

    await _ds.updateUserDoc(uid, data);

    if (name != null) {
      await _ds.updateFirebaseDisplayName(name);
    }
  }

  // ---------- Sign out ----------
  @override
  Future<void> signOut() => _ds.signOut();
}
