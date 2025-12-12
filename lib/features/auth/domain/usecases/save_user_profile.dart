import '../repositories/auth_repository.dart';

class SaveUserProfile {
  final AuthRepository repository;
  SaveUserProfile(this.repository);

  Future<void> call({
    required String uid,
    required String name,
    String? phone,
    int? age,
    String? qualification,
  }) {
    return repository.saveUserProfile(
      uid: uid,
      name: name,
      phone: phone,
      age: age,
      qualification: qualification,
    );
  }
}
