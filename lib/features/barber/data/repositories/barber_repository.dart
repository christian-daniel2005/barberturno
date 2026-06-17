import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/barber_model.dart';
import '../../../../core/constants/app_constants.dart';

class BarberException implements Exception {
  final String message;
  BarberException(this.message);
}

class BarberRepository {
  final FirebaseFirestore _firestore;

  BarberRepository(this._firestore);

  CollectionReference get _barbers =>
      _firestore.collection(AppConstants.barbersCollection);
  CollectionReference get _users =>
      _firestore.collection(AppConstants.usersCollection);

  Stream<List<BarberModel>> watchBarbers({bool onlyActive = false}) {
    Query query = _barbers.orderBy('name');
    if (onlyActive) {
      query = query.where('isActive', isEqualTo: true);
    }
    return query.snapshots().map(
          (snap) => snap.docs.map((d) => BarberModel.fromFirestore(d)).toList(),
        );
  }

  /// Promueve un usuario registrado (por email) a barbero.
  /// Cambia su rol a 'barber' y crea su perfil en la colección barbers.
  Future<void> promoteUserToBarber({
    required String email,
    required String specialty,
  }) async {
    final result = await _users
        .where('email', isEqualTo: email.trim().toLowerCase())
        .limit(1)
        .get();
    if (result.docs.isEmpty) {
      throw BarberException(
          'No existe un usuario registrado con ese correo. Pídele que se registre primero.');
    }
    final userDoc = result.docs.first;
    final data = userDoc.data() as Map<String, dynamic>;
    final existing = await _barbers.doc(userDoc.id).get();
    if (existing.exists) {
      throw BarberException('Ese usuario ya es barbero.');
    }
    await _users.doc(userDoc.id).update({'role': AppConstants.roleBarber});
    await _barbers.doc(userDoc.id).set(
          BarberModel(
            id: userDoc.id,
            name: data['fullName'] ?? '',
            specialty: specialty.trim(),
          ).toFirestore(),
        );
  }

  Future<void> updateBarber(BarberModel barber) {
    return _barbers.doc(barber.id).update(barber.toFirestore());
  }

  Future<void> toggleActive(String id, bool isActive) {
    return _barbers.doc(id).update({'isActive': isActive});
  }

  /// Quita el rol de barbero: elimina su perfil y lo devuelve a cliente.
  Future<void> removeBarber(String id) async {
    await _barbers.doc(id).delete();
    await _users.doc(id).update({'role': AppConstants.roleClient});
  }
}
