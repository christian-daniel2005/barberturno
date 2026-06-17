import '../entities/user_entity.dart';

abstract class AuthRepository {
  Future<UserEntity> login(String email, String password);

  Future<UserEntity> register({
    required String email,
    required String password,
    required String fullName,
    required String phone,
  });

  Future<void> logout();

  Future<UserEntity?> getCurrentUser();

  Stream<UserEntity?> get authStateChanges;
}
