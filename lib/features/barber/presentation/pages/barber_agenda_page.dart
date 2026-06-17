import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../config/app_theme.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/utils/appointment_status_ui.dart';
import '../../../../injection/injection.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_event.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../../../appointments/data/models/appointment_model.dart';
import '../../../appointments/data/repositories/appointment_repository.dart';
import '../../../schedule/data/repositories/schedule_repository.dart';
import '../../../schedule/domain/availability_engine.dart';

class BarberAgendaPage extends StatefulWidget {
  const BarberAgendaPage({super.key});

  @override
  State<BarberAgendaPage> createState() => _BarberAgendaPageState();
}

class _BarberAgendaPageState extends State<BarberAgendaPage> {
  final _appointmentRepo = getIt<AppointmentRepository>();
  final _scheduleRepo = getIt<ScheduleRepository>();
  DateTime _date = DateTime.now();

  @override
  Widget build(BuildContext context) {
    final authState = context.read<AuthBloc>().state;
    if (authState is! AuthAuthenticated) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    final barberId = authState.user.uid;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mi agenda'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => context.read<AuthBloc>().add(LogoutRequested()),
          ),
        ],
      ),
      body: Column(
        children: [
          _dateBar(),
          Expanded(
            child: StreamBuilder<List<AppointmentModel>>(
              stream: _appointmentRepo.watchBarberAppointmentsForDay(
                barberId: barberId,
                day: _date,
              ),
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
                        Icon(Icons.event_available,
                            size: 64,
                            color: Colors.white.withValues(alpha: 0.2)),
                        const SizedBox(height: 16),
                        Text('Sin citas este día',
                            style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.5))),
                      ],
                    ),
                  );
                }
                return ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: appointments.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, i) =>
                      _appointmentCard(appointments[i]),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppTheme.primaryColor,
        onPressed: () => _openBlockSheet(barberId),
        icon: const Icon(Icons.block, color: Colors.white),
        label: const Text('Bloquear horario',
            style: TextStyle(color: Colors.white)),
      ),
    );
  }

  Widget _dateBar() {
    final today = DateTime.now();
    final days = List.generate(7, (i) {
      final d = today.add(Duration(days: i));
      return DateTime(d.year, d.month, d.day);
    });
    const weekdays = ['', 'Lun', 'Mar', 'Mié', 'Jue', 'Vie', 'Sáb', 'Dom'];
    return Container(
      height: 80,
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: days.length,
        separatorBuilder: (_, __) => const SizedBox(width: 10),
        itemBuilder: (context, i) {
          final d = days[i];
          final selected = _date.day == d.day && _date.month == d.month;
          return GestureDetector(
            onTap: () => setState(() => _date = d),
            child: Container(
              width: 56,
              decoration: BoxDecoration(
                color: selected ? AppTheme.primaryColor : AppTheme.surfaceColor,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(weekdays[d.weekday],
                      style: TextStyle(
                          fontSize: 11,
                          color: selected ? Colors.white70 : Colors.white54)),
                  const SizedBox(height: 4),
                  Text('${d.day}',
                      style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white)),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _appointmentCard(AppointmentModel a) {
    final time =
        '${a.dateTime.hour.toString().padLeft(2, '0')}:${a.dateTime.minute.toString().padLeft(2, '0')}';
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
              Text(time,
                  style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primaryColor)),
              const Spacer(),
              AppointmentStatusUI.badge(a.status),
            ],
          ),
          const SizedBox(height: 10),
          Text(a.clientName,
              style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white)),
          const SizedBox(height: 2),
          Text('${a.serviceName}  •  ${a.durationMinutes} min',
              style: const TextStyle(color: Colors.white54, fontSize: 13)),
          const SizedBox(height: 12),
          _actions(a),
        ],
      ),
    );
  }

  Widget _actions(AppointmentModel a) {
    if (a.status == AppConstants.appointmentPending) {
      return Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: () => _appointmentRepo.updateStatus(
                  a.id, AppConstants.appointmentRejected),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppTheme.errorColor,
                side: const BorderSide(color: AppTheme.errorColor),
              ),
              child: const Text('Rechazar'),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: ElevatedButton(
              onPressed: () => _appointmentRepo.updateStatus(
                  a.id, AppConstants.appointmentConfirmed),
              child: const Text('Confirmar'),
            ),
          ),
        ],
      );
    }
    if (a.status == AppConstants.appointmentConfirmed) {
      return SizedBox(
        width: double.infinity,
        child: ElevatedButton.icon(
          onPressed: () => _appointmentRepo.updateStatus(
              a.id, AppConstants.appointmentCompleted),
          icon: const Icon(Icons.check),
          label: const Text('Marcar como atendido'),
        ),
      );
    }
    return const SizedBox.shrink();
  }

  Future<void> _openBlockSheet(String barberId) async {
    final hours = await _scheduleRepo.getBusinessHours();
    final busy = await _appointmentRepo.getBusyStarts(
        barberId: barberId, day: _date);
    final blocks =
        await _scheduleRepo.getBlocksForDay(barberId: barberId, day: _date);
    final blockedTimes = blocks.map((e) => e.value).toList();

    final free = AvailabilityEngine.availableSlots(
      date: _date,
      hours: hours,
      serviceDuration: hours.slotMinutes,
      busyStarts: [...busy, ...blockedTimes],
    );

    if (!mounted) return;

    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.backgroundColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Bloquear un horario',
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white)),
            const SizedBox(height: 6),
            Text(
              'Los clientes no podrán reservar en los horarios que bloquees.',
              style: TextStyle(
                  fontSize: 13, color: Colors.white.withValues(alpha: 0.5)),
            ),
            const SizedBox(height: 16),
            if (blockedTimes.isNotEmpty) ...[
              const Text('Bloqueados:',
                  style: TextStyle(color: Colors.white70, fontSize: 13)),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: blocks.map((entry) {
                  final t = entry.value;
                  final label =
                      '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';
                  return InputChip(
                    label: Text(label),
                    backgroundColor: AppTheme.errorColor.withValues(alpha: 0.2),
                    labelStyle: const TextStyle(color: AppTheme.errorColor),
                    deleteIconColor: AppTheme.errorColor,
                    onDeleted: () async {
                      await _scheduleRepo.unblockSlot(entry.key);
                      if (mounted) Navigator.pop(context);
                    },
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),
            ],
            const Text('Disponibles para bloquear:',
                style: TextStyle(color: Colors.white70, fontSize: 13)),
            const SizedBox(height: 8),
            if (free.isEmpty)
              Text('No hay horarios libres este día.',
                  style: TextStyle(color: Colors.white.withValues(alpha: 0.5)))
            else
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: free.map((slot) {
                  final label =
                      '${slot.hour.toString().padLeft(2, '0')}:${slot.minute.toString().padLeft(2, '0')}';
                  return ActionChip(
                    label: Text(label),
                    backgroundColor: AppTheme.surfaceColor,
                    labelStyle: const TextStyle(color: Colors.white),
                    onPressed: () async {
                      await _scheduleRepo.blockSlot(
                          barberId: barberId, dateTime: slot);
                      if (mounted) Navigator.pop(context);
                    },
                  );
                }).toList(),
              ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }
}
