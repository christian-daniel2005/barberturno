import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/appointment_model.dart';
import '../../../../core/constants/app_constants.dart';

class AppointmentRepository {
  final FirebaseFirestore _firestore;

  AppointmentRepository(this._firestore);

  CollectionReference get _collection =>
      _firestore.collection(AppConstants.appointmentsCollection);

  Future<void> createAppointment(AppointmentModel appointment) {
    return _collection.add(appointment.toFirestore());
  }

  Future<void> updateStatus(String id, String status) {
    return _collection.doc(id).update({'status': status});
  }

  /// Citas de un cliente (más recientes primero).
  /// Filtro de igualdad únicamente; el orden se hace en el cliente
  /// para evitar índices compuestos en Firestore.
  Stream<List<AppointmentModel>> watchClientAppointments(String clientId) {
    return _collection
        .where('clientId', isEqualTo: clientId)
        .snapshots()
        .map((snap) {
      final list =
          snap.docs.map((d) => AppointmentModel.fromFirestore(d)).toList();
      list.sort((a, b) => b.dateTime.compareTo(a.dateTime));
      return list;
    });
  }

  /// Agenda de un barbero para un día específico.
  /// Consulta solo por barberId; el rango del día y el orden se aplican
  /// en el cliente para no requerir índice compuesto.
  Stream<List<AppointmentModel>> watchBarberAppointmentsForDay({
    required String barberId,
    required DateTime day,
  }) {
    final start = DateTime(day.year, day.month, day.day);
    final end = start.add(const Duration(days: 1));
    return _collection
        .where('barberId', isEqualTo: barberId)
        .snapshots()
        .map((snap) {
      final list = snap.docs
          .map((d) => AppointmentModel.fromFirestore(d))
          .where((a) =>
              !a.dateTime.isBefore(start) && a.dateTime.isBefore(end))
          .toList();
      list.sort((a, b) => a.dateTime.compareTo(b.dateTime));
      return list;
    });
  }

  /// Todas las citas (panel admin), más recientes primero.
  Stream<List<AppointmentModel>> watchAllAppointments() {
    return _collection.snapshots().map((snap) {
      final list =
          snap.docs.map((d) => AppointmentModel.fromFirestore(d)).toList();
      list.sort((a, b) => b.dateTime.compareTo(a.dateTime));
      return list;
    });
  }

  /// Horas de inicio ya ocupadas por un barbero en un día
  /// (citas pendientes o confirmadas) para el motor de disponibilidad.
  Future<List<DateTime>> getBusyStarts({
    required String barberId,
    required DateTime day,
  }) async {
    final start = DateTime(day.year, day.month, day.day);
    final end = start.add(const Duration(days: 1));
    final snap =
        await _collection.where('barberId', isEqualTo: barberId).get();
    return snap.docs
        .map((d) => AppointmentModel.fromFirestore(d))
        .where((a) =>
            !a.dateTime.isBefore(start) &&
            a.dateTime.isBefore(end) &&
            (a.status == AppConstants.appointmentPending ||
                a.status == AppConstants.appointmentConfirmed))
        .map((a) => a.dateTime)
        .toList();
  }
}
