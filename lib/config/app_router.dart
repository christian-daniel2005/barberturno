import 'package:go_router/go_router.dart';
import '../features/auth/presentation/pages/login_page.dart';
import '../features/auth/presentation/pages/register_page.dart';
import '../features/home/presentation/pages/home_page.dart';
import '../features/appointments/presentation/pages/booking_page.dart';
import '../features/appointments/presentation/pages/my_appointments_page.dart';
import '../features/barber/presentation/pages/barber_agenda_page.dart';
import '../features/admin/presentation/pages/admin_dashboard_page.dart';
import '../features/services/presentation/pages/services_page.dart';

class AppRouter {
  AppRouter._();

  static final router = GoRouter(
    initialLocation: '/login',
    routes: [
      // Auth
      GoRoute(path: '/login', builder: (_, __) => const LoginPage()),
      GoRoute(path: '/register', builder: (_, __) => const RegisterPage()),

      // Cliente
      GoRoute(path: '/home', builder: (_, __) => const HomePage()),
      GoRoute(path: '/services', builder: (_, __) => const ServicesPage()),
      GoRoute(path: '/booking', builder: (_, __) => const BookingPage()),
      GoRoute(path: '/my-appointments', builder: (_, __) => const MyAppointmentsPage()),

      // Barbero
      GoRoute(path: '/barber/agenda', builder: (_, __) => const BarberAgendaPage()),

      // Admin
      GoRoute(path: '/admin', builder: (_, __) => const AdminDashboardPage()),
    ],
  );
}
