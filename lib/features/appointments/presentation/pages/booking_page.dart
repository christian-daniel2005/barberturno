import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../config/app_theme.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../injection/injection.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../../../barber/data/models/barber_model.dart';
import '../../../barber/data/repositories/barber_repository.dart';
import '../../../schedule/data/repositories/schedule_repository.dart';
import '../../../schedule/domain/availability_engine.dart';
import '../../../services/data/models/service_model.dart';
import '../../../services/data/repositories/service_repository.dart';
import '../../data/models/appointment_model.dart';
import '../../data/repositories/appointment_repository.dart';

class BookingPage extends StatefulWidget {
  const BookingPage({super.key});

  @override
  State<BookingPage> createState() => _BookingPageState();
}

class _BookingPageState extends State<BookingPage> {
  final _serviceRepo = getIt<ServiceRepository>();
  final _barberRepo = getIt<BarberRepository>();
  final _scheduleRepo = getIt<ScheduleRepository>();
  final _appointmentRepo = getIt<AppointmentRepository>();

  ServiceModel? _service;
  BarberModel? _barber;
  DateTime? _date;
  DateTime? _slot;

  List<DateTime> _slots = [];
  bool _loadingSlots = false;
  bool _booking = false;

  Future<void> _computeSlots() async {
    if (_service == null || _barber == null || _date == null) return;
    setState(() {
      _loadingSlots = true;
      _slot = null;
    });
    final hours = await _scheduleRepo.getBusinessHours();
    final busy = await _appointmentRepo.getBusyStarts(
      barberId: _barber!.id,
      day: _date!,
    );
    final blocks = await _scheduleRepo.getBlocksForDay(
      barberId: _barber!.id,
      day: _date!,
    );
    final busyAll = [...busy, ...blocks.map((e) => e.value)];
    final slots = AvailabilityEngine.availableSlots(
      date: _date!,
      hours: hours,
      serviceDuration: _service!.durationMinutes,
      busyStarts: busyAll,
    );
    if (!mounted) return;
    setState(() {
      _slots = slots;
      _loadingSlots = false;
    });
  }

  Future<void> _confirmBooking() async {
    final authState = context.read<AuthBloc>().state;
    if (authState is! AuthAuthenticated) return;
    if (_service == null || _barber == null || _slot == null) return;

    setState(() => _booking = true);
    final user = authState.user;
    final appointment = AppointmentModel(
      id: '',
      clientId: user.uid,
      clientName: user.fullName,
      barberId: _barber!.id,
      barberName: _barber!.name,
      serviceId: _service!.id,
      serviceName: _service!.name,
      servicePrice: _service!.price,
      dateTime: _slot!,
      durationMinutes: _service!.durationMinutes,
      status: AppConstants.appointmentPending,
      createdAt: DateTime.now(),
    );
    try {
      await _appointmentRepo.createAppointment(appointment);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('¡Cita reservada! Espera la confirmación del barbero.'),
          backgroundColor: AppTheme.successColor,
        ),
      );
      context.go('/my-appointments');
    } catch (_) {
      if (!mounted) return;
      setState(() => _booking = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No se pudo reservar. Inténtalo de nuevo.'),
          backgroundColor: AppTheme.errorColor,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reservar cita'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/home'),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _stepTitle('1', 'Elige un servicio'),
          const SizedBox(height: 12),
          _serviceSelector(),
          const SizedBox(height: 28),
          if (_service != null) ...[
            _stepTitle('2', 'Elige tu barbero'),
            const SizedBox(height: 12),
            _barberSelector(),
            const SizedBox(height: 28),
          ],
          if (_barber != null) ...[
            _stepTitle('3', 'Elige el día'),
            const SizedBox(height: 12),
            _dateSelector(),
            const SizedBox(height: 28),
          ],
          if (_date != null) ...[
            _stepTitle('4', 'Elige la hora'),
            const SizedBox(height: 12),
            _slotSelector(),
            const SizedBox(height: 28),
          ],
          if (_slot != null) _confirmCard(),
        ],
      ),
    );
  }

  Widget _stepTitle(String num, String text) {
    return Row(
      children: [
        Container(
          width: 26,
          height: 26,
          decoration: const BoxDecoration(
            color: AppTheme.primaryColor,
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(num,
                style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 14)),
          ),
        ),
        const SizedBox(width: 10),
        Text(text,
            style: const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.bold,
                color: Colors.white)),
      ],
    );
  }

  Widget _serviceSelector() {
    return StreamBuilder<List<ServiceModel>>(
      stream: _serviceRepo.watchServices(onlyActive: true),
      builder: (context, snap) {
        if (!snap.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        final services = snap.data!;
        if (services.isEmpty) {
          return _emptyHint('No hay servicios disponibles todavía.');
        }
        return Column(
          children: services.map((s) {
            final selected = _service?.id == s.id;
            return _selectableTile(
              selected: selected,
              title: s.name,
              subtitle:
                  'S/ ${s.price.toStringAsFixed(2)}  •  ${s.durationMinutes} min',
              icon: Icons.content_cut,
              onTap: () {
                setState(() {
                  _service = s;
                  _slot = null;
                  _slots = [];
                });
                _computeSlots();
              },
            );
          }).toList(),
        );
      },
    );
  }

  Widget _barberSelector() {
    return StreamBuilder<List<BarberModel>>(
      stream: _barberRepo.watchBarbers(onlyActive: true),
      builder: (context, snap) {
        if (!snap.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        final barbers = snap.data!;
        if (barbers.isEmpty) {
          return _emptyHint('No hay barberos disponibles todavía.');
        }
        return Column(
          children: barbers.map((b) {
            final selected = _barber?.id == b.id;
            return _selectableTile(
              selected: selected,
              title: b.name,
              subtitle: b.specialty.isEmpty ? 'Barbero' : b.specialty,
              icon: Icons.person,
              onTap: () {
                setState(() {
                  _barber = b;
                  _slot = null;
                });
                _computeSlots();
              },
            );
          }).toList(),
        );
      },
    );
  }

  Widget _dateSelector() {
    final today = DateTime.now();
    final days = List.generate(14, (i) {
      final d = today.add(Duration(days: i));
      return DateTime(d.year, d.month, d.day);
    });
    const weekdays = ['', 'Lun', 'Mar', 'Mié', 'Jue', 'Vie', 'Sáb', 'Dom'];
    return SizedBox(
      height: 86,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: days.length,
        separatorBuilder: (_, __) => const SizedBox(width: 10),
        itemBuilder: (context, i) {
          final d = days[i];
          final selected = _date != null &&
              _date!.day == d.day &&
              _date!.month == d.month;
          return GestureDetector(
            onTap: () {
              setState(() => _date = d);
              _computeSlots();
            },
            child: Container(
              width: 60,
              decoration: BoxDecoration(
                color: selected ? AppTheme.primaryColor : AppTheme.surfaceColor,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                    color: selected
                        ? AppTheme.primaryColor
                        : const Color(0xFF3D3D3D)),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(weekdays[d.weekday],
                      style: TextStyle(
                          fontSize: 12,
                          color: selected ? Colors.white70 : Colors.white54)),
                  const SizedBox(height: 4),
                  Text('${d.day}',
                      style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: selected ? Colors.white : Colors.white)),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _slotSelector() {
    if (_loadingSlots) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_slots.isEmpty) {
      return _emptyHint(
          'No hay horarios disponibles ese día. Prueba con otra fecha.');
    }
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: _slots.map((slot) {
        final selected = _slot == slot;
        final label =
            '${slot.hour.toString().padLeft(2, '0')}:${slot.minute.toString().padLeft(2, '0')}';
        return GestureDetector(
          onTap: () => setState(() => _slot = slot),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
            decoration: BoxDecoration(
              color: selected ? AppTheme.primaryColor : AppTheme.surfaceColor,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                  color: selected
                      ? AppTheme.primaryColor
                      : const Color(0xFF3D3D3D)),
            ),
            child: Text(label,
                style: TextStyle(
                    color: selected ? Colors.white : Colors.white70,
                    fontWeight: FontWeight.bold)),
          ),
        );
      }).toList(),
    );
  }

  Widget _confirmCard() {
    final d = _slot!;
    final dateLabel =
        '${d.day}/${d.month}/${d.year} a las ${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.primaryColor.withValues(alpha: 0.4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Resumen de tu cita',
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white)),
          const SizedBox(height: 14),
          _summaryRow(Icons.content_cut, _service!.name),
          _summaryRow(Icons.person, _barber!.name),
          _summaryRow(Icons.calendar_today, dateLabel),
          _summaryRow(Icons.payments,
              'S/ ${_service!.price.toStringAsFixed(2)}'),
          const SizedBox(height: 18),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _booking ? null : _confirmBooking,
              child: _booking
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.white),
                    )
                  : const Text('Confirmar reserva',
                      style: TextStyle(
                          fontSize: 16, fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _summaryRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Icon(icon, size: 18, color: AppTheme.primaryColor),
          const SizedBox(width: 10),
          Expanded(
            child: Text(text,
                style: const TextStyle(color: Colors.white, fontSize: 14)),
          ),
        ],
      ),
    );
  }

  Widget _selectableTile({
    required bool selected,
    required String title,
    required String subtitle,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppTheme.surfaceColor,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
                color: selected
                    ? AppTheme.primaryColor
                    : const Color(0xFF3D3D3D),
                width: selected ? 2 : 1),
          ),
          child: Row(
            children: [
              Icon(icon,
                  color: selected ? AppTheme.primaryColor : Colors.white54),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title,
                        style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: Colors.white)),
                    const SizedBox(height: 2),
                    Text(subtitle,
                        style: const TextStyle(
                            fontSize: 12, color: AppTheme.primaryColor)),
                  ],
                ),
              ),
              if (selected)
                const Icon(Icons.check_circle, color: AppTheme.primaryColor),
            ],
          ),
        ),
      ),
    );
  }

  Widget _emptyHint(String text) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(text,
          style: TextStyle(color: Colors.white.withValues(alpha: 0.6))),
    );
  }
}
