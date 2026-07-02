import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'firebase_options.dart';
import 'config/app_router.dart';
import 'config/app_theme.dart';
import 'injection/injection.dart';
import 'features/auth/presentation/bloc/auth_bloc.dart';
import 'features/auth/presentation/bloc/auth_event.dart';

/// =========================================================================
/// ARQUITECTURA DE BARBERTURNO - PUNTO DE ENTRADA CENTRAL
/// =========================================================================
/// Como ingeniero, este es el punto de partida del ciclo de vida de la app:
/// 1. Inicialización de bindings de Flutter y de los servicios de Firebase Core.
/// 2. Configuración del Localizador de Servicios (Service Locator) con GetIt
///    para inyección de dependencias (repositorios, usecases, blocs).
/// 3. Inyección y provisión global de AuthBloc para mantener la sesión del usuario.
void main() async {
  // Asegura que los bindings del framework de Flutter estén listos antes de ejecutar código asíncrono.
  WidgetsFlutterBinding.ensureInitialized();
  
  // Inicialización de Firebase con las configuraciones auto-generadas específicas de cada plataforma (Android/iOS/Web).
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  // Inicializa GetIt para registrar todas las dependencias e implementaciones (Clean Architecture).
  configureDependencies();
  
  runApp(const BarberTurnoApp());
}

class BarberTurnoApp extends StatelessWidget {
  const BarberTurnoApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Proveemos el AuthBloc de forma global sobre toda la app.
    // Esto es crucial porque la sesión (Logueado, No Logueado, Rol del usuario)
    // define el flujo de navegación completo mediante go_router.
    return BlocProvider(
      create: (_) => getIt<AuthBloc>()..add(AuthCheckRequested()), // Al iniciar, verifica inmediatamente si el usuario ya está autenticado.
      child: MaterialApp.router(
        title: 'BarberTurno',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.light, // Configurado en modo claro por defecto para el MVP v1.
        routerConfig: AppRouter.router, // Vinculación con GoRouter para el manejo de rutas reactivo.
      ),
    );
  }
}

