import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/service_model.dart';
import '../../../../core/constants/app_constants.dart';

class ServiceRepository {
  final FirebaseFirestore _firestore;

  ServiceRepository(this._firestore);

  CollectionReference get _collection =>
      _firestore.collection(AppConstants.servicesCollection);

  Stream<List<ServiceModel>> watchServices({bool onlyActive = false}) {
    // Filtro de igualdad únicamente; el orden se hace en el cliente
    // para no requerir un índice compuesto en Firestore.
    Query query = _collection;
    if (onlyActive) {
      query = query.where('isActive', isEqualTo: true);
    }
    return query.snapshots().map((snap) {
      final list = snap.docs.map((d) => ServiceModel.fromFirestore(d)).toList();
      list.sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
      return list;
    });
  }

  Future<void> createService(ServiceModel service) {
    return _collection.add(service.toFirestore());
  }

  Future<void> updateService(ServiceModel service) {
    return _collection.doc(service.id).update(service.toFirestore());
  }

  Future<void> deleteService(String id) {
    return _collection.doc(id).delete();
  }

  Future<void> toggleActive(String id, bool isActive) {
    return _collection.doc(id).update({'isActive': isActive});
  }
}
