import 'package:go_router/go_router.dart';
import '../core/utils/go_router_refresh_stream.dart';
import '../injection/injection.dart';
import '../features/auth/presentation/bloc/auth_bloc.dart';
import '../features/auth/presentation/bloc/auth_state.dart';
import '../features/auth/presentation/pages/login_page.dart';
import '../features/auth/presentation/pages/register_page.dart';
import '../features/home/presentation/pages/home_page.dart';
import '../features/appointments/presentation/pages/booking_page.dart';
import '../features/appointments/presentation/pages/my_appointments_page.dart';
import '../features/barber/presentation/pages/barber_agenda_page.dart';
import '../features/admin/presentation/pages/admin_dashboard_page.dart';
import '../features/admin/presentation/pages/manage_services_page.dart';
import '../features/admin/presentation/pages/manage_barbers_page.dart';
import '../features/admin/presentation/pages/manage_schedule_page.dart';
import '../features/admin/presentation/pages/admin_appointments_page.dart';
import '../features/services/presentation/pages/services_page.dart';

/// =========================================================================
/// ENRUTADOR CENTRAL DE LA APLICACIÓN (AppRouter)
/// =========================================================================
/// Este archivo actúa como el guardián y controlador de la navegación.
/// Implementa GoRouter combinándolo con el patrón BLoC para lograr:
/// 1. Autenticación reactiva: Si el estado del usuario cambia (Login/Logout), 
///    la app se redirige de forma automática.
/// 2. Seguridad basada en roles: Evita que los clientes entren a paneles de admin
///    y viceversa.
class AppRouter {
  AppRouter._();

  // Rutas públicas accesibles solo por usuarios NO autenticados.
  static final _authRoutes = ['/login', '/register'];

  /// Retorna la ruta inicial de inicio según el rol guardado en Firestore.
  static String homeForRole(String role) {
    switch (role) {
      case 'admin':
        return '/admin';
      case 'barber':
        return '/barber/agenda';
      default:
        return '/home'; // Rol 'client' o clientes comunes.
    }
  }

  static final router = GoRouter(
    initialLocation: '/login',
    
    // El "refreshListenable" re-evalúa el flujo de redirección 'redirect'
    // CADA VEZ que el AuthBloc emite un nuevo estado (ej. cuando se loguea o desloguea).
    refreshListenable: GoRouterRefreshStream(getIt<AuthBloc>().stream),
    
    redirect: (context, state) {
      final authState = getIt<AuthBloc>().state;
      final isAuthRoute = _authRoutes.contains(state.matchedLocation);
      final isAuthenticated = authState is AuthAuthenticated;

      // REGLA DE SEGURIDAD 1: Si el usuario NO está autenticado
      // y trata de ir a una pantalla protegida (ej: /admin, /booking),
      // lo obligamos a ir a /login.
      if (!isAuthenticated) {
        return isAuthRoute ? null : '/login';
      }

      // REGLA DE SEGURIDAD 2: Si el usuario YA está autenticado
      // e intenta ir a /login o /register, lo redirigimos a la pantalla
      // de inicio correspondiente a su rol para que no tenga que volver a loguearse.
      if (isAuthRoute) {
        return homeForRole(authState.user.role);
      }
      
      // Permitir la navegación normal a la ruta solicitada.
      return null;
    },
    routes: [
      // ----------------------------------------------------
      // RUTAS DE AUTENTICACIÓN (Públicas)
      // ----------------------------------------------------
      GoRoute(path: '/login', builder: (_, __) => const LoginPage()),
      GoRoute(path: '/register', builder: (_, __) => const RegisterPage()),

      // ----------------------------------------------------
      // RUTAS DE CLIENTES (Protegidas)
      // ----------------------------------------------------
      GoRoute(path: '/home', builder: (_, __) => const HomePage()),
      GoRoute(path: '/services', builder: (_, __) => const ServicesPage()),
      GoRoute(path: '/booking', builder: (_, __) => const BookingPage()),
      GoRoute(
          path: '/my-appointments',
          builder: (_, __) => const MyAppointmentsPage()),

      // ----------------------------------------------------
      // RUTAS DE BARBEROS (Protegidas)
      // ----------------------------------------------------
      GoRoute(
          path: '/barber/agenda',
          builder: (_, __) => const BarberAgendaPage()),

      // ----------------------------------------------------
      // RUTAS DE ADMINISTRACIÓN (Protegidas)
      // ----------------------------------------------------
      GoRoute(path: '/admin', builder: (_, __) => const AdminDashboardPage()),
      GoRoute(
          path: '/admin/services',
          builder: (_, __) => const ManageServicesPage()),
      GoRoute(
          path: '/admin/barbers',
          builder: (_, __) => const ManageBarbersPage()),
      GoRoute(
          path: '/admin/schedule',
          builder: (_, __) => const ManageSchedulePage()),
      GoRoute(
          path: '/admin/appointments',
          builder: (_, __) => const AdminAppointmentsPage()),
    ],
  );
}

