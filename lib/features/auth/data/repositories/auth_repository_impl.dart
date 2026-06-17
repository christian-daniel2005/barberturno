import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_datasource.dart';
import '../models/user_model.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDatasource _datasource;

  AuthRepositoryImpl(this._datasource);

  @override
  Future<UserEntity> login(String email, String password) async {
    final model = await _datasource.login(email, password);
    return _toEntity(model);
  }

  @override
  Future<UserEntity> register({
    required String email,
    required String password,
    required String fullName,
    required String phone,
  }) async {
    final model = await _datasource.register(
      email: email,
      password: password,
      fullName: fullName,
      phone: phone,
    );
    return _toEntity(model);
  }

  @override
  Future<void> logout() => _datasource.logout();

  @override
  Future<UserEntity?> getCurrentUser() async {
    final model = await _datasource.getCurrentUser();
    return model != null ? _toEntity(model) : null;
  }

  @override
  Stream<UserEntity?> get authStateChanges {
    return _datasource.authStateChanges().map(
      (model) => model != null ? _toEntity(model) : null,
    );
  }

  UserEntity _toEntity(UserModel model) {
    return UserEntity(
      uid: model.uid,
      email: model.email,
      fullName: model.fullName,
      phone: model.phone,
      role: model.role,
      photoUrl: model.photoUrl,
      createdAt: model.createdAt,
      isActive: model.isActive,
    );
  }
}
