import 'package:get_it/get_it.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../features/auth/data/datasources/auth_remote_datasource.dart';
import '../features/auth/data/repositories/auth_repository_impl.dart';
import '../features/auth/domain/repositories/auth_repository.dart';
import '../features/auth/domain/usecases/login_usecase.dart';
import '../features/auth/domain/usecases/register_usecase.dart';
import '../features/auth/domain/usecases/logout_usecase.dart';
import '../features/auth/presentation/bloc/auth_bloc.dart';
import '../features/services/data/repositories/service_repository.dart';
import '../features/services/presentation/bloc/service_bloc.dart';
import '../features/barber/data/repositories/barber_repository.dart';
import '../features/barber/presentation/bloc/barber_bloc.dart';
import '../features/schedule/data/repositories/schedule_repository.dart';
import '../features/appointments/data/repositories/appointment_repository.dart';

final getIt = GetIt.instance;

void configureDependencies() {
  // ===== Firebase =====
  getIt.registerLazySingleton<FirebaseAuth>(() => FirebaseAuth.instance);
  getIt.registerLazySingleton<FirebaseFirestore>(
      () => FirebaseFirestore.instance);

  // ===== Auth =====
  getIt.registerLazySingleton<AuthRemoteDatasource>(
    () => AuthRemoteDatasourceImpl(getIt(), getIt()),
  );
  getIt.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(getIt()),
  );
  getIt.registerLazySingleton(() => LoginUseCase(getIt()));
  getIt.registerLazySingleton(() => RegisterUseCase(getIt()));
  getIt.registerLazySingleton(() => LogoutUseCase(getIt()));
  // Singleton: el router y la UI comparten la misma instancia para
  // que el ruteo por rol sea consistente.
  getIt.registerLazySingleton(
    () => AuthBloc(
      loginUseCase: getIt(),
      registerUseCase: getIt(),
      logoutUseCase: getIt(),
      authRepository: getIt(),
    ),
  );

  // ===== Servicios =====
  getIt.registerLazySingleton(() => ServiceRepository(getIt()));
  getIt.registerFactory(() => ServiceBloc(getIt()));

  // ===== Barberos =====
  getIt.registerLazySingleton(() => BarberRepository(getIt()));
  getIt.registerFactory(() => BarberBloc(getIt()));

  // ===== Horarios =====
  getIt.registerLazySingleton(() => ScheduleRepository(getIt()));

  // ===== Citas / Reservas =====
  getIt.registerLazySingleton(() => AppointmentRepository(getIt()));
}
