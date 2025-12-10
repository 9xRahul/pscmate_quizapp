class AuthUser {
  final String uid;
  final String? email;
  final String? displayName;
  final String? phoneNumber;

  const AuthUser({
    required this.uid,
    this.email,
    this.displayName,
    this.phoneNumber,
  });
}
