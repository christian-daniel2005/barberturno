import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../config/app_theme.dart';
import '../../../../injection/injection.dart';
import '../../../schedule/data/models/business_hours_model.dart';
import '../../../schedule/data/repositories/schedule_repository.dart';

class ManageSchedulePage extends StatefulWidget {
  const ManageSchedulePage({super.key});

  @override
  State<ManageSchedulePage> createState() => _ManageSchedulePageState();
}

class _ManageSchedulePageState extends State<ManageSchedulePage> {
  final _repo = getIt<ScheduleRepository>();
  BusinessHoursModel? _hours;
  bool _saving = false;

  static const _dayNames = {
    1: 'Lun',
    2: 'Mar',
    3: 'Mié',
    4: 'Jue',
    5: 'Vie',
    6: 'Sáb',
    7: 'Dom',
  };

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final hours = await _repo.getBusinessHours();
    setState(() => _hours = hours);
  }

  Future<void> _save() async {
    if (_hours == null) return;
    if (_hours!.openHour >= _hours!.closeHour) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('La hora de apertura debe ser menor a la de cierre'),
          backgroundColor: AppTheme.errorColor,
        ),
      );
      return;
    }
    if (_hours!.workingDays.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Selecciona al menos un día de atención'),
          backgroundColor: AppTheme.errorColor,
        ),
      );
      return;
    }
    setState(() => _saving = true);
    await _repo.saveBusinessHours(_hours!);
    if (!mounted) return;
    setState(() => _saving = false);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Horario guardado correctamente'),
        backgroundColor: AppTheme.successColor,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Horarios generales'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/admin'),
        ),
      ),
      body: _hours == null
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(20),
              children: [
                _label('Hora de apertura'),
                _hourPicker(
                  value: _hours!.openHour,
                  onChanged: (v) =>
                      setState(() => _hours = _hours!.copyWith(openHour: v)),
                ),
                const SizedBox(height: 24),
                _label('Hora de cierre'),
                _hourPicker(
                  value: _hours!.closeHour,
                  onChanged: (v) =>
                      setState(() => _hours = _hours!.copyWith(closeHour: v)),
                ),
                const SizedBox(height: 24),
                _label('Duración de cada cita'),
                Wrap(
                  spacing: 10,
                  children: [15, 30, 45, 60].map((min) {
                    final selected = _hours!.slotMinutes == min;
                    return ChoiceChip(
                      label: Text('$min min'),
                      selected: selected,
                      selectedColor: AppTheme.primaryColor,
                      backgroundColor: AppTheme.surfaceColor,
                      labelStyle: TextStyle(
                          color: selected ? Colors.white : Colors.white70),
                      onSelected: (_) => setState(
                          () => _hours = _hours!.copyWith(slotMinutes: min)),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 24),
                _label('Días de atención'),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _dayNames.entries.map((e) {
                    final selected = _hours!.workingDays.contains(e.key);
                    return FilterChip(
                      label: Text(e.value),
                      selected: selected,
                      selectedColor: AppTheme.primaryColor,
                      backgroundColor: AppTheme.surfaceColor,
                      checkmarkColor: Colors.white,
                      labelStyle: TextStyle(
                          color: selected ? Colors.white : Colors.white70),
                      onSelected: (on) {
                        final days = List<int>.from(_hours!.workingDays);
                        if (on) {
                          days.add(e.key);
                        } else {
                          days.remove(e.key);
                        }
                        days.sort();
                        setState(
                            () => _hours = _hours!.copyWith(workingDays: days));
                      },
                    );
                  }).toList(),
                ),
                const SizedBox(height: 40),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _saving ? null : _save,
                    child: _saving
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                                strokeWidth: 2, color: Colors.white),
                          )
                        : const Text('Guardar horario',
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
    );
  }

  Widget _label(String text) => Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Text(text,
            style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: Colors.white)),
      );

  Widget _hourPicker({
    required int value,
    required ValueChanged<int> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: DropdownButton<int>(
        value: value,
        isExpanded: true,
        underline: const SizedBox.shrink(),
        dropdownColor: AppTheme.surfaceColor,
        style: const TextStyle(color: Colors.white, fontSize: 16),
        items: List.generate(24, (h) => h)
            .map((h) => DropdownMenuItem(
                  value: h,
                  child: Text('${h.toString().padLeft(2, '0')}:00'),
                ))
            .toList(),
        onChanged: (v) {
          if (v != null) onChanged(v);
        },
      ),
    );
  }
}
