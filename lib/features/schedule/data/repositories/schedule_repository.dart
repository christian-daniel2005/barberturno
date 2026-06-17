import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/business_hours_model.dart';
import '../../../../core/constants/app_constants.dart';

class ScheduleRepository {
  final FirebaseFirestore _firestore;

  ScheduleRepository(this._firestore);

  CollectionReference get _schedules =>
      _firestore.collection(AppConstants.schedulesCollection);

  DocumentReference get _configDoc => _schedules.doc('config');

  // ===== Horario general (admin) =====
  Stream<BusinessHoursModel> watchBusinessHours() {
    return _configDoc.snapshots().map((doc) {
      if (!doc.exists) return BusinessHoursModel.defaults();
      return BusinessHoursModel.fromFirestore(doc);
    });
  }

  Future<BusinessHoursModel> getBusinessHours() async {
    final doc = await _configDoc.get();
    if (!doc.exists) return BusinessHoursModel.defaults();
    return BusinessHoursModel.fromFirestore(doc);
  }

  Future<void> saveBusinessHours(BusinessHoursModel hours) {
    return _configDoc.set(hours.toFirestore());
  }

  // ===== Bloqueo de horarios (barbero) =====
  Future<void> blockSlot({
    required String barberId,
    required DateTime dateTime,
  }) {
    return _schedules.add({
      'type': 'block',
      'barberId': barberId,
      'dateTime': Timestamp.fromDate(dateTime),
    });
  }

  Future<void> unblockSlot(String docId) {
    return _schedules.doc(docId).delete();
  }

  /// Devuelve los bloqueos de un barbero en un día específico.
  Future<List<MapEntry<String, DateTime>>> getBlocksForDay({
    required String barberId,
    required DateTime day,
  }) async {
    final start = DateTime(day.year, day.month, day.day);
    final end = start.add(const Duration(days: 1));
    // Consulta solo por barberId; el tipo y el rango del día se filtran
    // en el cliente para no requerir índice compuesto.
    final snap =
        await _schedules.where('barberId', isEqualTo: barberId).get();
    return snap.docs
        .map((d) {
          final data = d.data() as Map<String, dynamic>;
          return MapEntry(d.id, data);
        })
        .where((e) {
          if (e.value['type'] != 'block') return false;
          final ts = e.value['dateTime'];
          if (ts is! Timestamp) return false;
          final dt = ts.toDate();
          return !dt.isBefore(start) && dt.isBefore(end);
        })
        .map((e) => MapEntry(e.key, (e.value['dateTime'] as Timestamp).toDate()))
        .toList();
  }
}
