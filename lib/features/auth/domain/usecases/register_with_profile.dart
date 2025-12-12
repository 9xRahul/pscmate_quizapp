import '../repositories/auth_repository.dart';

class RegisterWithProfile {
  final AuthRepository repository;
  RegisterWithProfile(this.repository);

  Future<void> call({
    required String email,
    required String password,
    required String name,
    String? phone,
    int? age,
    String? qualification,
  }) {
    return repository.registerWithEmailAndProfile(
      email: email,
      password: password,
      name: name,
      phone: phone,
      age: age,
      qualification: qualification,
    );
  }
}
