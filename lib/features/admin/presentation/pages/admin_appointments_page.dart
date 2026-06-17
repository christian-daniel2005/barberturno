import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../config/app_theme.dart';
import '../../../../core/utils/appointment_status_ui.dart';
import '../../../../injection/injection.dart';
import '../../../appointments/data/models/appointment_model.dart';
import '../../../appointments/data/repositories/appointment_repository.dart';

class AdminAppointmentsPage extends StatelessWidget {
  const AdminAppointmentsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final repo = getIt<AppointmentRepository>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Citas programadas'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/admin'),
        ),
      ),
      body: StreamBuilder<List<AppointmentModel>>(
        stream: repo.watchAllAppointments(),
        builder: (context, snap) {
          if (!snap.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final appointments = snap.data!;
          if (appointments.isEmpty) {
            return Center(
              child: Text('No hay citas registradas',
                  style: TextStyle(color: Colors.white.withValues(alpha: 0.5))),
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: appointments.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, i) {
              final a = appointments[i];
              final d = a.dateTime;
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
                          child: Text(a.serviceName,
                              style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white)),
                        ),
                        AppointmentStatusUI.badge(a.status),
                      ],
                    ),
                    const SizedBox(height: 10),
                    _row(Icons.person, 'Cliente: ${a.clientName}'),
                    _row(Icons.content_cut, 'Barbero: ${a.barberName}'),
                    _row(Icons.calendar_today, dateLabel),
                    _row(Icons.payments,
                        'S/ ${a.servicePrice.toStringAsFixed(2)}'),
                  ],
                ),
              );
            },
          );
        },
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
          Expanded(
            child: Text(text,
                style: const TextStyle(color: Colors.white70, fontSize: 13)),
          ),
        ],
      ),
    );
  }
}
