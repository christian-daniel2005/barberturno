import '../data/models/business_hours_model.dart';

/// =========================================================================
/// MOTOR DE DISPONIBILIDAD DE HORARIOS (AvailabilityEngine)
/// =========================================================================
/// Este es el núcleo lógico/matemático del módulo de citas. Como ingeniero,
/// su objetivo es calcular qué franjas de tiempo están libres para que un
/// cliente reserve.
///
/// Para evitar problemas de zonas horarias complejas al realizar comparaciones,
/// el motor normaliza todas las horas a "minutos transcurridos desde la medianoche"
/// (por ejemplo, 09:00 AM = 9 * 60 = 540 minutos).
class AvailabilityEngine {
  AvailabilityEngine._();

  /// Genera la lista de horarios disponibles para [date].
  ///
  /// - [hours]: configuración general de la barbería (días laborales, hora de apertura/cierre, etc.).
  /// - [serviceDuration]: minutos que dura el servicio elegido (ej. corte simple = 30 min).
  /// - [busyStarts]: horas de inicio ya ocupadas (citas activas + bloqueos del barbero).
  /// - [now]: hora actual (para descartar slots pasados si la fecha es hoy).
  static List<DateTime> availableSlots({
    required DateTime date,
    required BusinessHoursModel hours,
    required int serviceDuration,
    required List<DateTime> busyStarts,
    DateTime? now,
  }) {
    
    // PASO 1: Validación del día de la semana.
    // date.weekday devuelve de 1 (Lunes) a 7 (Domingo).
    // Si la barbería no trabaja ese día de la semana, retornamos lista vacía.
    if (!hours.workingDays.contains(date.weekday)) {
      return [];
    }

    // Identificamos si el día de reserva es el día de hoy para no ofrecer
    // horarios que ya transcurrieron en el reloj del cliente.
    final current = now ?? DateTime.now();
    final isToday = date.year == current.year &&
        date.month == current.month &&
        date.day == current.day;

    // PASO 2: Normalización de horarios ocupados.
    // Convertimos cada DateTime de cita/bloqueo a minutos absolutos del día.
    // Ejemplo: una cita a las 10:30 AM se convierte en (10 * 60) + 30 = 630 minutos.
    final busyMinutes = busyStarts
        .map((d) => d.hour * 60 + d.minute)
        .toSet(); // Usar un Set permite búsquedas O(1) rápidas.

    // PASO 3: Convertir horas límites de la barbería a minutos absolutos.
    final openMin = hours.openHour * 60;   // Ejemplo: 9:00 AM -> 540 min
    final closeMin = hours.closeHour * 60; // Ejemplo: 8:00 PM -> 1200 min
    final step = hours.slotMinutes;        // Frecuencia del reloj (ej: cada 30 min)

    final slots = <DateTime>[];
    
    // PASO 4: Generación y filtrado de franjas horarias (Slots).
    // Iteramos desde la hora de apertura hasta el cierre.
    // Nos aseguramos de que el servicio quepa antes de la hora de cierre (m + serviceDuration <= closeMin).
    for (int m = openMin; m + serviceDuration <= closeMin; m += step) {
      
      // Si la hora de inicio de este slot ya está ocupada por una cita o bloqueo, lo descartamos.
      if (busyMinutes.contains(m)) continue;

      // Reconstruimos el minuto a un objeto DateTime real para ese día.
      final slot = DateTime(date.year, date.month, date.day, m ~/ 60, m % 60);

      // Si la cita es hoy, descartamos los horarios que ya pasaron.
      if (isToday && slot.isBefore(current)) continue;

      // El slot está libre, lo añadimos a las opciones disponibles para el cliente.
      slots.add(slot);
    }
    
    return slots;
  }
}

