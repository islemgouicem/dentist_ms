import 'package:flutter/material.dart';
import '../models/appointment_model.dart';

class AppointmentUtils {
  static const Color confirmedColor = Color(0xFF10B981);
  static const Color pendingColor = Color(0xFF3B82F6);
  static const Color cancelledColor = Color(0xFFEF4444);

  static const Map<String, Color> treatmentColors = {
    'Root Canal': Color(0xFF2563EB),
    'Teeth Cleaning': Color(0xFF10B981),
    'Dental Implant': Color(0xFF7C3AED),
    'Crown Installation': Color(0xFFA855F7),
    'Cavity Filling': Color(0xFF06B6D4),
    'Whitening': Color(0xFFFB923C),
    'Orthodontics': Color(0xFFEC4899),
    'Check-up': Color(0xFF14B8A6),
    'Bridge Installation': Color(0xFFF59E0B),
    'Extraction': Color(0xFFEF4444),
    'Scaling': Color(0xFF8B5CF6),
    'Consultation': Color(0xFF6366F1),
  };

  static Color getTreatmentColor(String procedure) {
    return treatmentColors[procedure] ?? const Color(0xFF6B7280);
  }

  static Color getStatusColor(String status) {
    switch (status) {
      case 'confirmed':
        return confirmedColor;
      case 'pending':
        return pendingColor;
      case 'cancelled':
        return cancelledColor;
      default:
        return const Color(0xFF6B7280);
    }
  }

  static DateTime getAppointmentDateTime(Appointment app) {
    final timeParts = app.time.split(':');
    final hour = int.parse(timeParts[0]);
    final minute = int.parse(timeParts[1]);
    return DateTime(app.appointmentDate.year, app.appointmentDate.month,
        app.appointmentDate.day, hour, minute);
  }

  static String getDateKey(DateTime day) {
    return '${day.year}-${day.month.toString().padLeft(2, '0')}-${day.day.toString().padLeft(2, '0')}';
  }
}