import 'package:cloud_firestore/cloud_firestore.dart';

/// Configuración general de horarios de la barbería (definida por el admin).
class BusinessHoursModel {
  final int openHour; // 0-23
  final int closeHour; // 0-23
  final int slotMinutes; // duración de cada bloque
  final List<int> workingDays; // 1=Lunes ... 7=Domingo

  BusinessHoursModel({
    required this.openHour,
    required this.closeHour,
    required this.slotMinutes,
    required this.workingDays,
  });

  factory BusinessHoursModel.defaults() => BusinessHoursModel(
        openHour: 9,
        closeHour: 20,
        slotMinutes: 30,
        workingDays: const [1, 2, 3, 4, 5, 6], // Lun a Sáb
      );

  factory BusinessHoursModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return BusinessHoursModel(
      openHour: data['openHour'] ?? 9,
      closeHour: data['closeHour'] ?? 20,
      slotMinutes: data['slotMinutes'] ?? 30,
      workingDays: (data['workingDays'] as List?)?.cast<int>() ??
          const [1, 2, 3, 4, 5, 6],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'openHour': openHour,
      'closeHour': closeHour,
      'slotMinutes': slotMinutes,
      'workingDays': workingDays,
    };
  }

  BusinessHoursModel copyWith({
    int? openHour,
    int? closeHour,
    int? slotMinutes,
    List<int>? workingDays,
  }) {
    return BusinessHoursModel(
      openHour: openHour ?? this.openHour,
      closeHour: closeHour ?? this.closeHour,
      slotMinutes: slotMinutes ?? this.slotMinutes,
      workingDays: workingDays ?? this.workingDays,
    );
  }
}
