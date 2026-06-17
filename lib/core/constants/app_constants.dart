class AppConstants {
  AppConstants._();

  // Nombre de la app
  static const String appName = 'BarberTurno';
  static const String appVersion = '1.0.0';

  // Colecciones de Firestore
  static const String usersCollection = 'users';
  static const String barbersCollection = 'barbers';
  static const String servicesCollection = 'services';
  static const String appointmentsCollection = 'appointments';
  static const String schedulesCollection = 'schedules';

  // Roles de usuario
  static const String roleClient = 'client';
  static const String roleBarber = 'barber';
  static const String roleAdmin = 'admin';

  // Estados de cita
  static const String appointmentPending = 'pending';
  static const String appointmentConfirmed = 'confirmed';
  static const String appointmentRejected = 'rejected';
  static const String appointmentCompleted = 'completed';
  static const String appointmentCancelled = 'cancelled';

  // Configuración de horarios
  static const int defaultOpenHour = 9;   // 9:00 AM
  static const int defaultCloseHour = 20; // 8:00 PM
  static const int slotDurationMinutes = 30;
}
