import 'package:pscmate/features/auth/domain/entities/AuthUser.dart';

import '../repositories/auth_repository.dart';

class FetchUserProfile {
  final AuthRepository repository;
  FetchUserProfile(this.repository);

  Future<AuthUser?> call(String uid) => repository.fetchUserProfile(uid);
}
