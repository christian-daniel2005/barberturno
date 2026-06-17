import '../data/models/business_hours_model.dart';

/// Motor de disponibilidad de horarios.
/// Calcula los bloques de tiempo libres para reservar, según el horario
/// general de la barbería y los tiempos ya ocupados (citas + bloqueos).
class AvailabilityEngine {
  AvailabilityEngine._();

  /// Genera la lista de horarios disponibles para [date].
  ///
  /// - [hours]: configuración general de la barbería.
  /// - [serviceDuration]: minutos que dura el servicio elegido.
  /// - [busyStarts]: horas de inicio ya ocupadas (citas activas + bloqueos).
  /// - [now]: hora actual (para descartar slots pasados si la fecha es hoy).
  static List<DateTime> availableSlots({
    required DateTime date,
    required BusinessHoursModel hours,
    required int serviceDuration,
    required List<DateTime> busyStarts,
    DateTime? now,
  }) {
    // ¿La barbería trabaja ese día?
    if (!hours.workingDays.contains(date.weekday)) {
      return [];
    }

    final current = now ?? DateTime.now();
    final isToday = date.year == current.year &&
        date.month == current.month &&
        date.day == current.day;

    // Normalizamos las horas ocupadas a "minutos del día" para comparar.
    final busyMinutes = busyStarts
        .map((d) => d.hour * 60 + d.minute)
        .toSet();

    final openMin = hours.openHour * 60;
    final closeMin = hours.closeHour * 60;
    final step = hours.slotMinutes;

    final slots = <DateTime>[];
    for (int m = openMin; m + serviceDuration <= closeMin; m += step) {
      // El slot debe estar libre.
      if (busyMinutes.contains(m)) continue;

      final slot = DateTime(date.year, date.month, date.day, m ~/ 60, m % 60);

      // Si es hoy, descartar horas que ya pasaron.
      if (isToday && slot.isBefore(current)) continue;

      slots.add(slot);
    }
    return slots;
  }
}
