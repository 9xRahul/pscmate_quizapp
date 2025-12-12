class AuthUser {
  final String uid;
  final String? email;
  final String? name;
  final String? phoneNumber;
  final int? age;
  final String? qualification;
  final String? profilePic;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const AuthUser({
    required this.uid,
    this.profilePic,
    this.email,
    this.name,
    this.phoneNumber,
    this.age,
    this.qualification,
    this.createdAt,
    this.updatedAt,
  });
}
