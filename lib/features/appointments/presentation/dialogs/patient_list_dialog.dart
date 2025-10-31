import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/appointment_model.dart';
import '../services/appointment_service.dart';
import '../utils/appointment_utils.dart';

class PatientListDialog extends StatelessWidget {
  final String filterType;
  final List<Appointment> appointments;
  final AppointmentService service;
  final Function(Appointment) onAppointmentTap;

  const PatientListDialog({
    super.key,
    required this.filterType,
    required this.appointments,
    required this.service,
    required this.onAppointmentTap,
  });

  @override
  Widget build(BuildContext context) {
    final appointmentsToShow = _getFilteredAppointments();

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      backgroundColor: Colors.white,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 600, maxHeight: 700),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildHeader(context, appointmentsToShow),
            Expanded(
              child: _buildListContent(context, appointmentsToShow),
            ),
          ],
        ),
      ),
    );
  }

  List<Appointment> _getFilteredAppointments() {
    if (filterType == 'all') {
      return appointments;
    }
    return appointments.where((a) => a.status == filterType).toList();
  }

  Widget _buildHeader(BuildContext context, List<Appointment> appointmentsToShow) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Colors.grey[200]!),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _getFilterTitle(),
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF111827),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '${appointmentsToShow.length} appointments',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  Widget _buildListContent(BuildContext context, List<Appointment> appointmentsToShow) {
    if (appointmentsToShow.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.inbox,
              size: 48,
              color: Colors.grey[300],
            ),
            const SizedBox(height: 12),
            Text(
              'No appointments found',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: appointmentsToShow.length,
      separatorBuilder: (_, __) => Divider(color: Colors.grey[200], height: 1),
      itemBuilder: (context, index) {
        final appointment = appointmentsToShow[index];
        return _buildAppointmentRow(context, appointment);
      },
    );
  }

  Widget _buildAppointmentRow(BuildContext context, Appointment appointment) {
    final treatmentColor = AppointmentUtils.getTreatmentColor(appointment.procedure);
    final statusColor = AppointmentUtils.getStatusColor(appointment.status);
    final indicatorColor = (filterType == 'all') ? statusColor : treatmentColor;

    return GestureDetector(
      onTap: () {
        Navigator.pop(context);
        onAppointmentTap(appointment);
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          children: [
            Container(
              width: 4,
              height: 50,
              decoration: BoxDecoration(
                color: indicatorColor,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        appointment.patientName,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF111827),
                        ),
                      ),
                      if (filterType == 'all')
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: statusColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            appointment.status.substring(0, 1).toUpperCase() +
                                appointment.status.substring(1),
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: statusColor,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Icon(
                        Icons.medical_services,
                        size: 12,
                        color: Colors.grey[600],
                      ),
                      const SizedBox(width: 4),
                      Text(
                        appointment.procedure,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(width: 16),
                      Icon(
                        Icons.access_time,
                        size: 12,
                        color: Colors.grey[600],
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          appointment.time,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios,
                size: 14, color: Colors.grey[400]),
          ],
        ),
      ),
    );
  }

  String _getFilterTitle() {
    switch (filterType) {
      case 'all':
        return 'All Appointments';
      case 'confirmed':
        return 'Confirmed Appointments';
      case 'pending':
        return 'Pending Appointments';
      case 'cancelled':
        return 'Cancelled Appointments';
      default:
        return 'Appointments';
    }
  }
}