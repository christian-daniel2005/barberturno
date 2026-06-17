import 'package:cloud_firestore/cloud_firestore.dart';

class AppointmentModel {
  final String id;
  final String clientId;
  final String clientName;
  final String barberId;
  final String barberName;
  final String serviceId;
  final String serviceName;
  final double servicePrice;
  final DateTime dateTime;
  final int durationMinutes;
  final String status; // pending, confirmed, rejected, completed, cancelled
  final String? notes;
  final DateTime createdAt;

  AppointmentModel({
    required this.id,
    required this.clientId,
    required this.clientName,
    required this.barberId,
    required this.barberName,
    required this.serviceId,
    required this.serviceName,
    required this.servicePrice,
    required this.dateTime,
    required this.durationMinutes,
    required this.status,
    this.notes,
    required this.createdAt,
  });

  factory AppointmentModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return AppointmentModel(
      id: doc.id,
      clientId: data['clientId'] ?? '',
      clientName: data['clientName'] ?? '',
      barberId: data['barberId'] ?? '',
      barberName: data['barberName'] ?? '',
      serviceId: data['serviceId'] ?? '',
      serviceName: data['serviceName'] ?? '',
      servicePrice: (data['servicePrice'] ?? 0).toDouble(),
      dateTime: (data['dateTime'] as Timestamp).toDate(),
      durationMinutes: data['durationMinutes'] ?? 30,
      status: data['status'] ?? 'pending',
      notes: data['notes'],
      createdAt: (data['createdAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'clientId': clientId,
      'clientName': clientName,
      'barberId': barberId,
      'barberName': barberName,
      'serviceId': serviceId,
      'serviceName': serviceName,
      'servicePrice': servicePrice,
      'dateTime': Timestamp.fromDate(dateTime),
      'durationMinutes': durationMinutes,
      'status': status,
      'notes': notes,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  AppointmentModel copyWith({String? status, String? notes}) {
    return AppointmentModel(
      id: id,
      clientId: clientId,
      clientName: clientName,
      barberId: barberId,
      barberName: barberName,
      serviceId: serviceId,
      serviceName: serviceName,
      servicePrice: servicePrice,
      dateTime: dateTime,
      durationMinutes: durationMinutes,
      status: status ?? this.status,
      notes: notes ?? this.notes,
      createdAt: createdAt,
    );
  }
}
