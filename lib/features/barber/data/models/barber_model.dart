import 'package:cloud_firestore/cloud_firestore.dart';

class BarberModel {
  final String id; // = uid del usuario con rol 'barber'
  final String name;
  final String specialty;
  final String? photoUrl;
  final bool isActive;

  BarberModel({
    required this.id,
    required this.name,
    required this.specialty,
    this.photoUrl,
    this.isActive = true,
  });

  factory BarberModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return BarberModel(
      id: doc.id,
      name: data['name'] ?? '',
      specialty: data['specialty'] ?? '',
      photoUrl: data['photoUrl'],
      isActive: data['isActive'] ?? true,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'specialty': specialty,
      'photoUrl': photoUrl,
      'isActive': isActive,
    };
  }

  BarberModel copyWith({String? name, String? specialty, bool? isActive}) {
    return BarberModel(
      id: id,
      name: name ?? this.name,
      specialty: specialty ?? this.specialty,
      photoUrl: photoUrl,
      isActive: isActive ?? this.isActive,
    );
  }
}
