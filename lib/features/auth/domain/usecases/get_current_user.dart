import 'package:pscmate/features/auth/domain/entities/AuthUser.dart';

import '../repositories/auth_repository.dart';


class GetCurrentUser {
  final AuthRepository repository;
  GetCurrentUser(this.repository);

  Future<AuthUser?> call() => repository.getCurrentUser();
}
