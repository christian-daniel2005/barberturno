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

class AppRouter {
  AppRouter._();

  static final _authRoutes = ['/login', '/register'];

  /// Pantalla inicial según el rol del usuario autenticado.
  static String homeForRole(String role) {
    switch (role) {
      case 'admin':
        return '/admin';
      case 'barber':
        return '/barber/agenda';
      default:
        return '/home';
    }
  }

  static final router = GoRouter(
    initialLocation: '/login',
    refreshListenable: GoRouterRefreshStream(getIt<AuthBloc>().stream),
    redirect: (context, state) {
      final authState = getIt<AuthBloc>().state;
      final isAuthRoute = _authRoutes.contains(state.matchedLocation);
      final isAuthenticated = authState is AuthAuthenticated;

      // No autenticado: solo puede estar en login/registro.
      if (!isAuthenticated) {
        return isAuthRoute ? null : '/login';
      }

      // Autenticado en login/registro: enviar a su pantalla según rol.
      if (isAuthRoute) {
        return homeForRole(authState.user.role);
      }
      return null;
    },
    routes: [
      // Auth
      GoRoute(path: '/login', builder: (_, __) => const LoginPage()),
      GoRoute(path: '/register', builder: (_, __) => const RegisterPage()),

      // Cliente
      GoRoute(path: '/home', builder: (_, __) => const HomePage()),
      GoRoute(path: '/services', builder: (_, __) => const ServicesPage()),
      GoRoute(path: '/booking', builder: (_, __) => const BookingPage()),
      GoRoute(
          path: '/my-appointments',
          builder: (_, __) => const MyAppointmentsPage()),

      // Barbero
      GoRoute(
          path: '/barber/agenda',
          builder: (_, __) => const BarberAgendaPage()),

      // Admin
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
