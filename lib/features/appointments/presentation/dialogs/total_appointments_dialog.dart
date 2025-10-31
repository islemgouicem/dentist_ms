import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/appointment_model.dart';
import '../services/appointment_service.dart';
import '../utils/appointment_utils.dart';

class TotalAppointmentsDialog extends StatelessWidget {
  final AppointmentService service;

  const TotalAppointmentsDialog({
    super.key,
    required this.service,
  });

  @override
  Widget build(BuildContext context) {
    final allAppointments = service.getAllAppointments();

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      backgroundColor: Colors.white,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 1000, maxHeight: 700),
        child: Column(
          children: [
            _buildHeader(allAppointments, context),
            Expanded(
              child: SingleChildScrollView(
                child: _buildTable(allAppointments),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(List<Appointment> allAppointments, BuildContext context) {
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
          Row(
            children: [
              const Text(
                'Total Appointments',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF111827),
                ),
              ),
              const SizedBox(width: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFF3B82F6),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${allAppointments.length}',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
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

  Widget _buildTable(List<Appointment> allAppointments) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        columns: const [
          DataColumn(label: Text('Patient ID')),
          DataColumn(label: Text('Patient Name')),
          DataColumn(label: Text('Appointment Date')),
          DataColumn(label: Text('Status')),
        ],
        rows: allAppointments.asMap().entries.map((entry) {
          final index = entry.key;
          final app = entry.value;
          final appointmentDateTime = AppointmentUtils.getAppointmentDateTime(app);
          
          return DataRow(
            color: MaterialStateProperty.resolveWith<Color?>((Set<MaterialState> states) {
              if (index.isEven) {
                return Colors.grey[50];
              }
              return null;
            }),
            cells: [
              DataCell(Text('#PT${app.id.padLeft(4, '0')}')),
              DataCell(Text(app.patientName)),
              DataCell(Text(DateFormat('MMM dd, yyyy, HH:mm').format(appointmentDateTime))),
              DataCell(
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppointmentUtils.getStatusColor(app.status).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    app.status.substring(0, 1).toUpperCase() + app.status.substring(1),
                    style: TextStyle(
                      color: AppointmentUtils.getStatusColor(app.status),
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                  ),
                ),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }
}