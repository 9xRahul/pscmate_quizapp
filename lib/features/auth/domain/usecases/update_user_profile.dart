import '../repositories/auth_repository.dart';

class UpdateUserProfile {
  final AuthRepository repository;
  UpdateUserProfile(this.repository);

  Future<void> call({
    required String uid,
    String? name,
    String? phone,
    int? age,
    String? qualification,
  }) {
    return repository.updateUserProfile(
      uid: uid,
      name: name,
      phone: phone,
      age: age,
      qualification: qualification,
    );
  }
}
