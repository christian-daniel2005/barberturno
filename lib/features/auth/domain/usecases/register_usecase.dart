import '../entities/user_entity.dart';
import '../repositories/auth_repository.dart';

class RegisterUseCase {
  final AuthRepository _repository;

  RegisterUseCase(this._repository);

  Future<UserEntity> call({
    required String email,
    required String password,
    required String fullName,
    required String phone,
  }) {
    return _repository.register(
      email: email,
      password: password,
      fullName: fullName,
      phone: phone,
    );
  }
}
