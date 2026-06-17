import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../config/app_theme.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/utils/appointment_status_ui.dart';
import '../../../../injection/injection.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../../data/models/appointment_model.dart';
import '../../data/repositories/appointment_repository.dart';

class MyAppointmentsPage extends StatelessWidget {
  const MyAppointmentsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final repo = getIt<AppointmentRepository>();
    final authState = context.read<AuthBloc>().state;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mis citas'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/home'),
        ),
      ),
      body: authState is! AuthAuthenticated
          ? const Center(child: CircularProgressIndicator())
          : StreamBuilder<List<AppointmentModel>>(
              stream: repo.watchClientAppointments(authState.user.uid),
              builder: (context, snap) {
                if (!snap.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }
                final appointments = snap.data!;
                if (appointments.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.event_busy,
                            size: 64,
                            color: Colors.white.withValues(alpha: 0.2)),
                        const SizedBox(height: 16),
                        Text('Aún no tienes citas',
                            style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.5))),
                        const SizedBox(height: 20),
                        ElevatedButton(
                          onPressed: () => context.go('/booking'),
                          child: const Text('Reservar ahora'),
                        ),
                      ],
                    ),
                  );
                }
                return ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: appointments.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, i) {
                    final a = appointments[i];
                    return _AppointmentCard(appointment: a, repo: repo);
                  },
                );
              },
            ),
    );
  }
}

class _AppointmentCard extends StatelessWidget {
  final AppointmentModel appointment;
  final AppointmentRepository repo;

  const _AppointmentCard({required this.appointment, required this.repo});

  bool get _canCancel =>
      appointment.status == AppConstants.appointmentPending ||
      appointment.status == AppConstants.appointmentConfirmed;

  @override
  Widget build(BuildContext context) {
    final d = appointment.dateTime;
    final dateLabel =
        '${d.day}/${d.month}/${d.year}  •  ${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';
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
          Row(
            children: [
              Expanded(
                child: Text(appointment.serviceName,
                    style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white)),
              ),
              AppointmentStatusUI.badge(appointment.status),
            ],
          ),
          const SizedBox(height: 10),
          _row(Icons.person, appointment.barberName),
          _row(Icons.calendar_today, dateLabel),
          _row(Icons.payments, 'S/ ${appointment.servicePrice.toStringAsFixed(2)}'),
          if (_canCancel) ...[
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton.icon(
                onPressed: () => _confirmCancel(context),
                icon: const Icon(Icons.close, size: 18, color: AppTheme.errorColor),
                label: const Text('Cancelar cita',
                    style: TextStyle(color: AppTheme.errorColor)),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _row(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          Icon(icon, size: 16, color: Colors.white38),
          const SizedBox(width: 8),
          Text(text, style: const TextStyle(color: Colors.white70, fontSize: 13)),
        ],
      ),
    );
  }

  void _confirmCancel(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: AppTheme.surfaceColor,
        title: const Text('Cancelar cita', style: TextStyle(color: Colors.white)),
        content: const Text('¿Seguro que deseas cancelar esta cita?',
            style: TextStyle(color: Colors.white70)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('No'),
          ),
          TextButton(
            onPressed: () {
              repo.updateStatus(
                  appointment.id, AppConstants.appointmentCancelled);
              Navigator.pop(dialogContext);
            },
            child: const Text('Sí, cancelar',
                style: TextStyle(color: AppTheme.errorColor)),
          ),
        ],
      ),
    );
  }
}
