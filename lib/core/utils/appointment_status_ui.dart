import 'package:flutter/material.dart';
import '../constants/app_constants.dart';
import '../../config/app_theme.dart';

class AppointmentStatusUI {
  AppointmentStatusUI._();

  static String label(String status) {
    switch (status) {
      case AppConstants.appointmentPending:
        return 'Pendiente';
      case AppConstants.appointmentConfirmed:
        return 'Confirmada';
      case AppConstants.appointmentRejected:
        return 'Rechazada';
      case AppConstants.appointmentCompleted:
        return 'Atendida';
      case AppConstants.appointmentCancelled:
        return 'Cancelada';
      default:
        return status;
    }
  }

  static Color color(String status) {
    switch (status) {
      case AppConstants.appointmentPending:
        return AppTheme.warningColor;
      case AppConstants.appointmentConfirmed:
        return AppTheme.successColor;
      case AppConstants.appointmentRejected:
      case AppConstants.appointmentCancelled:
        return AppTheme.errorColor;
      case AppConstants.appointmentCompleted:
        return AppTheme.primaryColor;
      default:
        return Colors.white54;
    }
  }

  static Widget badge(String status) {
    final c = color(status);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: c.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(label(status),
          style: TextStyle(
              color: c, fontSize: 12, fontWeight: FontWeight.bold)),
    );
  }
}
