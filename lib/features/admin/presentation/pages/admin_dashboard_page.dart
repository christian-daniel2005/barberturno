import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../config/app_theme.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../injection/injection.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_event.dart';
import '../../../appointments/data/models/appointment_model.dart';
import '../../../appointments/data/repositories/appointment_repository.dart';

class AdminDashboardPage extends StatelessWidget {
  const AdminDashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    final repo = getIt<AppointmentRepository>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Panel de administración'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => context.read<AuthBloc>().add(LogoutRequested()),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _IncomeStats(repo: repo),
          const SizedBox(height: 28),
          const Text('Gestión',
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white)),
          const SizedBox(height: 14),
          _navCard(context,
              icon: Icons.content_cut,
              title: 'Servicios',
              subtitle: 'Crear, editar y eliminar servicios',
              route: '/admin/services'),
          const SizedBox(height: 12),
          _navCard(context,
              icon: Icons.people,
              title: 'Barberos',
              subtitle: 'Agregar y administrar barberos',
              route: '/admin/barbers'),
          const SizedBox(height: 12),
          _navCard(context,
              icon: Icons.schedule,
              title: 'Horarios generales',
              subtitle: 'Días y horas de atención',
              route: '/admin/schedule'),
          const SizedBox(height: 12),
          _navCard(context,
              icon: Icons.event_note,
              title: 'Citas programadas',
              subtitle: 'Ver todas las reservas',
              route: '/admin/appointments'),
        ],
      ),
    );
  }

  Widget _navCard(BuildContext context,
      {required IconData icon,
      required String title,
      required String subtitle,
      required String route}) {
    return InkWell(
      onTap: () => context.go(route),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: AppTheme.surfaceColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFF3D3D3D)),
        ),
        child: Row(
          children: [
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: AppTheme.primaryColor.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: AppTheme.primaryColor),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white)),
                  const SizedBox(height: 2),
                  Text(subtitle,
                      style: TextStyle(
                          fontSize: 12,
                          color: Colors.white.withValues(alpha: 0.5))),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: Colors.white38),
          ],
        ),
      ),
    );
  }
}

class _IncomeStats extends StatelessWidget {
  final AppointmentRepository repo;

  const _IncomeStats({required this.repo});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<AppointmentModel>>(
      stream: repo.watchAllAppointments(),
      builder: (context, snap) {
        final all = snap.data ?? [];
        final now = DateTime.now();
        final todays = all.where((a) =>
            a.dateTime.year == now.year &&
            a.dateTime.month == now.month &&
            a.dateTime.day == now.day);
        final income = todays
            .where((a) => a.status == AppConstants.appointmentCompleted)
            .fold<double>(0, (sum, a) => sum + a.servicePrice);
        final todayCount = todays.length;
        final pending = all
            .where((a) => a.status == AppConstants.appointmentPending)
            .length;

        return Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppTheme.primaryColor,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Ingresos de hoy',
                      style: TextStyle(color: Colors.white70, fontSize: 14)),
                  const SizedBox(height: 6),
                  Text('S/ ${income.toStringAsFixed(2)}',
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 32,
                          fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  const Text('Citas atendidas y cobradas',
                      style: TextStyle(color: Colors.white60, fontSize: 12)),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _miniStat('Citas hoy', '$todayCount', Icons.today),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _miniStat(
                      'Pendientes', '$pending', Icons.hourglass_empty),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  Widget _miniStat(String label, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF3D3D3D)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: AppTheme.primaryColor, size: 22),
          const SizedBox(height: 10),
          Text(value,
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold)),
          Text(label,
              style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.5), fontSize: 12)),
        ],
      ),
    );
  }
}
