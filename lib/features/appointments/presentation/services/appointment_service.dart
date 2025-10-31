import '../models/appointment_model.dart';
import '../utils/appointment_utils.dart';

class AppointmentService {
  Map<String, List<Appointment>> getMockAppointments() {
    return {
      '2025-10-31': [
        Appointment(
          id: '1',
          patientName: 'John Smith',
          procedure: 'Root Canal',
          time: '08:30',
          duration: 60,
          status: 'confirmed',
          cardColor: AppointmentUtils.getTreatmentColor('Root Canal'),
          appointmentDate: DateTime(2025, 10, 31),
          totalCost: 500.0,
        ),
        Appointment(
          id: '2',
          patientName: 'Emma Wilson',
          procedure: 'Teeth Cleaning',
          time: '10:00',
          duration: 45,
          status: 'pending',
          cardColor: AppointmentUtils.getTreatmentColor('Teeth Cleaning'),
          appointmentDate: DateTime(2025, 10, 31),
          totalCost: 150.0,
        ),
        Appointment(
          id: '3',
          patientName: 'Michael Brown',
          procedure: 'Dental Implant',
          time: '12:00',
          duration: 90,
          status: 'confirmed',
          cardColor: AppointmentUtils.getTreatmentColor('Dental Implant'),
          appointmentDate: DateTime(2025, 10, 31),
          totalCost: 2000.0,
        ),
        Appointment(
          id: '4',
          patientName: 'Sarah Davis',
          procedure: 'Crown Installation',
          time: '14:00',
          duration: 60,
          status: 'confirmed',
          cardColor: AppointmentUtils.getTreatmentColor('Crown Installation'),
          appointmentDate: DateTime(2025, 10, 31),
          totalCost: 800.0,
        ),
      ],
      '2025-11-01': [
        Appointment(
          id: '5',
          patientName: 'Robert Johnson',
          procedure: 'Cavity Filling',
          time: '09:00',
          duration: 30,
          status: 'confirmed',
          cardColor: AppointmentUtils.getTreatmentColor('Cavity Filling'),
          appointmentDate: DateTime(2025, 11, 1),
          totalCost: 200.0,
        ),
        Appointment(
          id: '6',
          patientName: 'Lisa Anderson',
          procedure: 'Whitening',
          time: '11:00',
          duration: 45,
          status: 'confirmed',
          cardColor: AppointmentUtils.getTreatmentColor('Whitening'),
          appointmentDate: DateTime(2025, 11, 1),
          totalCost: 300.0,
        ),
      ],
      '2025-11-02': [
        Appointment(
          id: '7',
          patientName: 'David Taylor',
          procedure: 'Orthodontics',
          time: '13:00',
          duration: 120,
          status: 'confirmed',
          cardColor: AppointmentUtils.getTreatmentColor('Orthodontics'),
          appointmentDate: DateTime(2025, 11, 2),
          totalCost: 1500.0,
        ),
      ],
      '2025-11-03': [
        Appointment(
          id: '8',
          patientName: 'Jennifer Lee',
          procedure: 'Check-up',
          time: '09:30',
          duration: 30,
          status: 'pending',
          cardColor: AppointmentUtils.getTreatmentColor('Check-up'),
          appointmentDate: DateTime(2025, 11, 3),
          totalCost: 100.0,
        ),
        Appointment(
          id: '9',
          patientName: 'Mark Wilson',
          procedure: 'Bridge Installation',
          time: '15:00',
          duration: 75,
          status: 'confirmed',
          cardColor: AppointmentUtils.getTreatmentColor('Bridge Installation'),
          appointmentDate: DateTime(2025, 11, 3),
          totalCost: 1200.0,
        ),
      ],
      '2025-11-04': [
        Appointment(
          id: '10',
          patientName: 'Patricia Martinez',
          procedure: 'Extraction',
          time: '08:00',
          duration: 45,
          status: 'cancelled',
          cardColor: AppointmentUtils.getTreatmentColor('Extraction'),
          appointmentDate: DateTime(2025, 11, 4),
          totalCost: 350.0,
        ),
        Appointment(
          id: '11',
          patientName: 'James Garcia',
          procedure: 'Scaling',
          time: '10:30',
          duration: 90,
          status: 'confirmed',
          cardColor: AppointmentUtils.getTreatmentColor('Scaling'),
          appointmentDate: DateTime(2025, 11, 4),
          totalCost: 250.0,
        ),
      ],
      '2025-11-05': [
        Appointment(
          id: '12',
          patientName: 'Amanda White',
          procedure: 'Consultation',
          time: '14:00',
          duration: 60,
          status: 'confirmed',
          cardColor: AppointmentUtils.getTreatmentColor('Consultation'),
          appointmentDate: DateTime(2025, 11, 5),
          totalCost: 75.0,
        ),
      ],
    };
  }

  List<Appointment> getAppointmentsForDay(DateTime day) {
    final dateKey = AppointmentUtils.getDateKey(day);
    return getMockAppointments()[dateKey] ?? [];
  }

  bool hasAppointmentsOnDay(DateTime day) {
    final dateKey = AppointmentUtils.getDateKey(day);
    return getMockAppointments()[dateKey] != null && getMockAppointments()[dateKey]!.isNotEmpty;
  }

  List<Appointment> getFilteredAppointments(DateTime selectedDay, String viewMode) {
    if (viewMode == 'Day') {
      return getAppointmentsForDay(selectedDay);
    } else if (viewMode == 'Week') {
      final monday = selectedDay.subtract(Duration(days: selectedDay.weekday - 1));
      List<Appointment> weekApps = [];
      for (int i = 0; i < 7; i++) {
        weekApps.addAll(getAppointmentsForDay(monday.add(Duration(days: i))));
      }
      return weekApps;
    } else {
      final firstDay = DateTime(selectedDay.year, selectedDay.month, 1);
      final lastDay = DateTime(selectedDay.year, selectedDay.month + 1, 0);
      List<Appointment> monthApps = [];
      for (DateTime day = firstDay;
          day.isBefore(lastDay.add(const Duration(days: 1)));
          day = day.add(const Duration(days: 1))) {
        monthApps.addAll(getAppointmentsForDay(day));
      }
      return monthApps;
    }
  }

  List<Appointment> getAllAppointments() {
    return getMockAppointments().values.expand((list) => list).toList();
  }

  List<String> getPatientsList() {
    return ['John Smith', 'Emma Wilson', 'Michael Brown', 'Sarah Davis', 'Robert Johnson', 'Lisa Anderson'];
  }

  List<String> getTreatmentTypes() {
    return ['Cleaning', 'Filling', 'Root Canal', 'Crown', 'Extraction', 'Consultation', 'Whitening', 'Orthodontics'];
  }
}