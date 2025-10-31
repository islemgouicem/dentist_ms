import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/appointment_model.dart';
import '../utils/appointment_utils.dart';
import '../services/appointment_service.dart';
import 'appointment_detail_page.dart';
import 'total_appointments_dialog.dart';

class AppointmentPage extends StatefulWidget {
  const AppointmentPage({super.key});

  @override
  State<AppointmentPage> createState() => _AppointmentPageState();
}

class _AppointmentPageState extends State<AppointmentPage> {
  DateTime selectedDay = DateTime(2025, 10, 31);
  DateTime calendarMonth = DateTime(2025, 10, 1);
  String viewMode = 'Day';
  String? hoveredAppointmentId;

  final AppointmentService _service = AppointmentService();

  // SERVICE WRAPPERS
  Color _getTreatmentColor(String procedure) => AppointmentUtils.getTreatmentColor(procedure);
  Color _getStatusColor(String status) => AppointmentUtils.getStatusColor(status);
  DateTime _getAppointmentDateTime(Appointment app) => AppointmentUtils.getAppointmentDateTime(app);

  Map<String, List<Appointment>> getMockAppointments() => _service.getMockAppointments();
  List<String> getPatientsList() => _service.getPatientsList();
  List<String> getTreatmentTypes() => _service.getTreatmentTypes();
  List<Appointment> getAppointmentsForDay(DateTime day) => _service.getAppointmentsForDay(day);
  bool hasAppointmentsOnDay(DateTime day) => _service.hasAppointmentsOnDay(day);
  List<Appointment> getFilteredAppointments() => _service.getFilteredAppointments(selectedDay, viewMode);
  List<Appointment> _getAllAppointments() => _service.getAllAppointments();

  void navigateToAppointmentDetail(Appointment appointment) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AppointmentDetailPage(
          appointment: appointment,
          onBack: () {
            setState(() {});
          },
        ),
      ),
    );
  }

  void showPatientListDialog(String filterType, List<Appointment> filteredAppointments) {
    final List<Appointment> appointmentsToShow;
    
    if (filterType == 'all') {
      appointmentsToShow = filteredAppointments;
    } else {
      appointmentsToShow = filteredAppointments.where((a) {
        if (filterType == 'confirmed') return a.status == 'confirmed';
        if (filterType == 'pending') return a.status == 'pending';
        if (filterType == 'cancelled') return a.status == 'cancelled';
        return false;
      }).toList();
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          backgroundColor: Colors.white,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600, maxHeight: 700),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
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
                            _getFilterTitle(filterType),
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
                ),
                Expanded(
                  child: appointmentsToShow.isEmpty
                      ? Center(
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
                        )
                      : ListView.separated(
                          padding: const EdgeInsets.all(16),
                          itemCount: appointmentsToShow.length,
                          separatorBuilder: (_, __) =>
                              Divider(color: Colors.grey[200], height: 1),
                          itemBuilder: (context, index) {
                            final appointment = appointmentsToShow[index];
                            final displayText = _getDisplayDateForPopup(appointment);
                            final treatmentColor = _getTreatmentColor(appointment.procedure);
                            final statusColor = _getStatusColor(appointment.status);
                            
                            final indicatorColor = (filterType == 'all') ? statusColor : treatmentColor;
                            
                            return GestureDetector(
                              onTap: () {
                                Navigator.pop(context);
                                navigateToAppointmentDetail(appointment);
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
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
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
                                                  padding: const EdgeInsets
                                                      .symmetric(
                                                    horizontal: 8,
                                                    vertical: 4,
                                                  ),
                                                  decoration: BoxDecoration(
                                                    color: statusColor
                                                        .withOpacity(0.1),
                                                    borderRadius:
                                                        BorderRadius.circular(4),
                                                  ),
                                                  child: Text(
                                                    appointment.status
                                                        .substring(0, 1)
                                                        .toUpperCase() +
                                                        appointment.status
                                                            .substring(1),
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
                                                  displayText,
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
                          },
                        ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  String _getDisplayDateForPopup(Appointment appointment) {
    if (viewMode == 'Day') {
      return appointment.time;
    } else if (viewMode == 'Week') {
      return '${DateFormat('EEE, MMM d').format(appointment.appointmentDate)} at ${appointment.time}';
    } else {
      return '${DateFormat('MMM d, yyyy').format(appointment.appointmentDate)} at ${appointment.time}';
    }
  }

  String _getFilterTitle(String filterType) {
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

  void showScheduleAppointmentDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          backgroundColor: Colors.white,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Schedule New Appointment',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF111827),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Schedule a new appointment for a patient with date, time, and treatment details.',
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                        IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () => Navigator.pop(context),
                          style: IconButton.styleFrom(
                            backgroundColor: Colors.grey[100],
                            iconSize: 20,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Patient',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF111827),
                                ),
                              ),
                              const SizedBox(height: 8),
                              DropdownButtonFormField<String>(
                                decoration: InputDecoration(
                                  hintText: 'Select patient',
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
                                  ),
                                  filled: true,
                                  fillColor: Colors.grey[50],
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 12,
                                  ),
                                  isDense: true,
                                ),
                                items: getPatientsList()
                                    .map((patient) => DropdownMenuItem(
                                      value: patient,
                                      child: Text(patient),
                                    ))
                                    .toList(),
                                onChanged: (value) {},
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Treatment Type',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF111827),
                                ),
                              ),
                              const SizedBox(height: 8),
                              DropdownButtonFormField<String>(
                                decoration: InputDecoration(
                                  hintText: 'Select type',
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
                                  ),
                                  filled: true,
                                  fillColor: Colors.grey[50],
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 12,
                                  ),
                                  isDense: true,
                                ),
                                items: getTreatmentTypes()
                                    .map((treatment) => DropdownMenuItem(
                                      value: treatment,
                                      child: Row(
                                        children: [
                                          Container(
                                            width: 12,
                                            height: 12,
                                            decoration: BoxDecoration(
                                              color: _getTreatmentColor(treatment),
                                              shape: BoxShape.circle,
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          Text(treatment),
                                        ],
                                      ),
                                    ))
                                    .toList(),
                                onChanged: (value) {},
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Date',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF111827),
                                ),
                              ),
                              const SizedBox(height: 8),
                              TextField(
                                decoration: InputDecoration(
                                  hintText: 'mm/dd/yyyy',
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
                                  ),
                                  filled: true,
                                  fillColor: Colors.grey[50],
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 12,
                                  ),
                                  isDense: true,
                                  prefixIcon: const Icon(Icons.calendar_today, size: 18),
                                ),
                                readOnly: true,
                                onTap: () async {
                                  final picked = await showDatePicker(
                                    context: context,
                                    initialDate: selectedDay,
                                    firstDate: DateTime(2025),
                                    lastDate: DateTime(2026),
                                  );
                                  if (picked != null) {}
                                },
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Time',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF111827),
                                ),
                              ),
                              const SizedBox(height: 8),
                              DropdownButtonFormField<String>(
                                decoration: InputDecoration(
                                  hintText: 'Select time',
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
                                  ),
                                  filled: true,
                                  fillColor: Colors.grey[50],
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 12,
                                  ),
                                  isDense: true,
                                ),
                                items: List.generate(10, (index) {
                                  final hour = 8 + index;
                                  return DropdownMenuItem(
                                    value: '${hour.toString().padLeft(2, '0')}:00',
                                    child: Text('${hour.toString().padLeft(2, '0')}:00'),
                                  );
                                }).toList(),
                                onChanged: (value) {},
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Notes',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF111827),
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextField(
                          maxLines: 4,
                          decoration: InputDecoration(
                            hintText: 'Add any special notes or instructions',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
                            ),
                            filled: true,
                            fillColor: Colors.grey[50],
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 12,
                            ),
                          ),
                          child: const Text(
                            'Cancel',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF6B7280),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        ElevatedButton(
                          onPressed: () {
                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Appointment scheduled successfully!'),
                                backgroundColor: Color(0xFF10B981),
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF3B82F6),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 12,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: const Text(
                            'Schedule Appointment',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  void showTotalAppointmentsDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return TotalAppointmentsDialog(service: _service);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final appointments = getAppointmentsForDay(selectedDay);
    final filteredAppointments = getFilteredAppointments();
    final confirmed = filteredAppointments.where((a) => a.status == 'confirmed').length;
    final pending = filteredAppointments.where((a) => a.status == 'pending').length;
    final cancelled = filteredAppointments.where((a) => a.status == 'cancelled').length;

    final screenWidth = MediaQuery.of(context).size.width;
    
    final showNewAppointmentButton = screenWidth > 1200;
    final showTotalAppointmentsButton = screenWidth > 1050;
    final showDayWeekMonthButtons = screenWidth > 900;
    final useSingleColumnLayout = screenWidth < 800;

    return Scaffold(
      backgroundColor: const Color(0xFFF3F4F6),
      body: useSingleColumnLayout 
          ? _buildSingleColumnLayout(
              appointments, 
              filteredAppointments, 
              confirmed, 
              pending, 
              cancelled,
              screenWidth,
              showNewAppointmentButton,
              showTotalAppointmentsButton,
              showDayWeekMonthButtons,
            )
          : _buildDualColumnLayout(
              appointments, 
              filteredAppointments, 
              confirmed, 
              pending, 
              cancelled,
              screenWidth,
              showNewAppointmentButton,
              showTotalAppointmentsButton,
              showDayWeekMonthButtons,
            ),
    );
  }

  // Single Column Layout for Small Screens
  Widget _buildSingleColumnLayout(
    List<Appointment> appointments,
    List<Appointment> filteredAppointments,
    int confirmed,
    int pending,
    int cancelled,
    double screenWidth,
    bool showNewAppointmentButton,
    bool showTotalAppointmentsButton,
    bool showDayWeekMonthButtons,
  ) {
    return SingleChildScrollView(
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(20),
            color: Colors.white,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Appointment Calendar',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF111827),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Manage and schedule appointments',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        if (showDayWeekMonthButtons) ...[
                          buildModeButton('Day', viewMode == 'Day', 12),
                          const SizedBox(width: 8),
                          buildModeButton('Week', viewMode == 'Week', 12),
                          const SizedBox(width: 8),
                          buildModeButton('Month', viewMode == 'Month', 12),
                          const SizedBox(width: 8),
                        ],
                        if (showTotalAppointmentsButton)
                          ElevatedButton.icon(
                            onPressed: showTotalAppointmentsDialog,
                            icon: const Icon(Icons.list, size: 16),
                            label: const Text('Total'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF3B82F6),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            ),
                          )
                        else
                          SizedBox(
                            width: 44,
                            height: 44,
                            child: IconButton(
                              icon: const Icon(Icons.list, size: 18),
                              onPressed: showTotalAppointmentsDialog,
                              style: IconButton.styleFrom(
                                backgroundColor: const Color(0xFF3B82F6),
                                foregroundColor: Colors.white,
                                padding: EdgeInsets.zero,
                              ),
                            ),
                          ),
                        const SizedBox(width: 8),
                        if (showNewAppointmentButton)
                          ElevatedButton.icon(
                            onPressed: showScheduleAppointmentDialog,
                            icon: const Icon(Icons.add, size: 16),
                            label: const Text('New'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF3B82F6),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            ),
                          )
                        else
                          SizedBox(
                            width: 44,
                            height: 44,
                            child: IconButton(
                              icon: const Icon(Icons.add, size: 18),
                              onPressed: showScheduleAppointmentDialog,
                              style: IconButton.styleFrom(
                                backgroundColor: const Color(0xFF3B82F6),
                                foregroundColor: Colors.white,
                                padding: EdgeInsets.zero,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                // Stat Cards - Responsive Grid
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    buildResponsiveStatCard(
                      'Today\'s Appointments',
                      '${filteredAppointments.length}',
                      const Color(0xFF3B82F6),
                      'all',
                      filteredAppointments,
                      screenWidth,
                    ),
                    buildResponsiveStatCard(
                      'Confirmed',
                      '$confirmed',
                      AppointmentUtils.confirmedColor,
                      'confirmed',
                      filteredAppointments,
                      screenWidth,
                    ),
                    buildResponsiveStatCard(
                      'Pending',
                      '$pending',
                      AppointmentUtils.pendingColor,
                      'pending',
                      filteredAppointments,
                      screenWidth,
                    ),
                    buildResponsiveStatCard(
                      'Cancelled',
                      '$cancelled',
                      AppointmentUtils.cancelledColor,
                      'cancelled',
                      filteredAppointments,
                      screenWidth,
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Calendar
          Container(
            color: Colors.white,
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                buildCalendarHeader(),
                const SizedBox(height: 16),
                buildCalendarGrid(),
                const SizedBox(height: 24),
                buildQuickActions(),
              ],
            ),
          ),
          // Appointments Section
          Container(
            color: const Color(0xFFF9FAFB),
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  DateFormat('EEEE, MMMM d, yyyy').format(selectedDay),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF111827),
                  ),
                ),
                Text(
                  '${appointments.length} appointments scheduled',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 16),
                appointments.isEmpty
                    ? Center(
                        child: Padding(
                          padding: const EdgeInsets.all(40),
                          child: Column(
                            children: [
                              Icon(Icons.calendar_today, size: 48, color: Colors.grey[400]),
                              const SizedBox(height: 16),
                              Text(
                                'No appointments scheduled',
                                style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                              ),
                            ],
                          ),
                        ),
                      )
                    : buildTimelineView(appointments),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Dual Column Layout for Large Screens
  Widget _buildDualColumnLayout(
    List<Appointment> appointments,
    List<Appointment> filteredAppointments,
    int confirmed,
    int pending,
    int cancelled,
    double screenWidth,
    bool showNewAppointmentButton,
    bool showTotalAppointmentsButton,
    bool showDayWeekMonthButtons,
  ) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(24),
          color: Colors.white,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Appointment Calendar',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF111827),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Manage and schedule appointments',
                        style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      if (showDayWeekMonthButtons) ...[
                        buildModeButton('Day', viewMode == 'Day', 14),
                        const SizedBox(width: 8),
                        buildModeButton('Week', viewMode == 'Week', 14),
                        const SizedBox(width: 8),
                        buildModeButton('Month', viewMode == 'Month', 14),
                        const SizedBox(width: 16),
                      ],
                      if (showTotalAppointmentsButton)
                        ElevatedButton.icon(
                          onPressed: showTotalAppointmentsDialog,
                          icon: const Icon(Icons.list),
                          label: const Text('Total Appointments'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF3B82F6),
                            foregroundColor: Colors.white,
                          ),
                        )
                      else
                        SizedBox(
                          width: 44,
                          height: 44,
                          child: IconButton(
                            icon: const Icon(Icons.list),
                            onPressed: showTotalAppointmentsDialog,
                            style: IconButton.styleFrom(
                              backgroundColor: const Color(0xFF3B82F6),
                              foregroundColor: Colors.white,
                              padding: EdgeInsets.zero,
                            ),
                          ),
                        ),
                      if (showTotalAppointmentsButton) const SizedBox(width: 8),
                      if (showNewAppointmentButton)
                        ElevatedButton.icon(
                          onPressed: showScheduleAppointmentDialog,
                          icon: const Icon(Icons.add),
                          label: const Text('New Appointment'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF3B82F6),
                            foregroundColor: Colors.white,
                          ),
                        )
                      else
                        SizedBox(
                          width: 44,
                          height: 44,
                          child: IconButton(
                            icon: const Icon(Icons.add),
                            onPressed: showScheduleAppointmentDialog,
                            style: IconButton.styleFrom(
                              backgroundColor: const Color(0xFF3B82F6),
                              foregroundColor: Colors.white,
                              padding: EdgeInsets.zero,
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  buildStatCard(
                    'Today\'s Appointments',
                    '${filteredAppointments.length}',
                    const Color(0xFF3B82F6),
                    'all',
                    filteredAppointments,
                  ),
                  const SizedBox(width: 16),
                  buildStatCard(
                    'Confirmed',
                    '$confirmed',
                    AppointmentUtils.confirmedColor,
                    'confirmed',
                    filteredAppointments,
                  ),
                  const SizedBox(width: 16),
                  buildStatCard(
                    'Pending',
                    '$pending',
                    AppointmentUtils.pendingColor,
                    'pending',
                    filteredAppointments,
                  ),
                  const SizedBox(width: 16),
                  buildStatCard(
                    'Cancelled',
                    '$cancelled',
                    AppointmentUtils.cancelledColor,
                    'cancelled',
                    filteredAppointments,
                  ),
                ],
              ),
            ],
          ),
        ),
        Expanded(
          child: Row(
            children: [
              Container(
                width: 300,
                color: Colors.white,
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    buildCalendarHeader(),
                    const SizedBox(height: 16),
                    Expanded(child: buildCalendarGrid()),
                    const SizedBox(height: 24),
                    buildQuickActions(),
                  ],
                ),
              ),
              Expanded(
                child: Container(
                  color: const Color(0xFFF9FAFB),
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        DateFormat('EEEE, MMMM d, yyyy').format(selectedDay),
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF111827),
                        ),
                      ),
                      Text(
                        '${appointments.length} appointments scheduled',
                        style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                      ),
                      const SizedBox(height: 20),
                      Expanded(
                        child: appointments.isEmpty
                            ? Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.calendar_today, size: 48, color: Colors.grey[400]),
                                    const SizedBox(height: 16),
                                    Text(
                                      'No appointments scheduled',
                                      style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                                    ),
                                  ],
                                ),
                              )
                            : buildTimelineView(appointments),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget buildModeButton(String label, bool isActive, double fontSize) {
    return ElevatedButton(
      onPressed: () => setState(() => viewMode = label),
      style: ElevatedButton.styleFrom(
        backgroundColor: isActive ? const Color(0xFF3B82F6) : Colors.white,
        foregroundColor: isActive ? Colors.white : const Color(0xFF6B7280),
        elevation: 0,
        side: BorderSide(
          color: isActive ? Colors.transparent : const Color(0xFFE5E7EB),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
      child: Text(label, style: TextStyle(fontSize: fontSize)),
    );
  }

  Widget buildResponsiveStatCard(
    String title,
    String value,
    Color color,
    String filterType,
    List<Appointment> filteredAppointments,
    double screenWidth,
  ) {
    double cardWidth = (screenWidth - 80) / 2;
    if (screenWidth > 900) cardWidth = (screenWidth - 60) / 4;

    return SizedBox(
      width: cardWidth,
      child: MouseRegion(
        onEnter: (_) => setState(() => hoveredAppointmentId = 'stat_$filterType'),
        onExit: (_) => setState(() => hoveredAppointmentId = null),
        cursor: SystemMouseCursors.click,
        child: GestureDetector(
          onTap: () => showPatientListDialog(filterType, filteredAppointments),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: hoveredAppointmentId == 'stat_$filterType'
                    ? color.withOpacity(0.5)
                    : const Color(0xFFE5E7EB),
                width: hoveredAppointmentId == 'stat_$filterType' ? 2 : 1,
              ),
              boxShadow: [
                if (hoveredAppointmentId == 'stat_$filterType')
                  BoxShadow(color: color.withOpacity(0.2), blurRadius: 12, offset: const Offset(0, 4)),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        title,
                        style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget buildStatCard(String title, String value, Color color, String filterType, List<Appointment> filteredAppointments) {
    return Expanded(
      child: MouseRegion(
        onEnter: (_) => setState(() => hoveredAppointmentId = 'stat_$filterType'),
        onExit: (_) => setState(() => hoveredAppointmentId = null),
        cursor: SystemMouseCursors.click,
        child: GestureDetector(
          onTap: () => showPatientListDialog(filterType, filteredAppointments),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: hoveredAppointmentId == 'stat_$filterType'
                    ? color.withOpacity(0.5)
                    : const Color(0xFFE5E7EB),
                width: hoveredAppointmentId == 'stat_$filterType' ? 2 : 1,
              ),
              boxShadow: [
                if (hoveredAppointmentId == 'stat_$filterType')
                  BoxShadow(color: color.withOpacity(0.2), blurRadius: 12, offset: const Offset(0, 4)),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(title, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(value, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget buildCalendarHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          'Calendar',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF111827)),
        ),
        Row(
          children: [
            IconButton(
              icon: const Icon(Icons.chevron_left, size: 20),
              onPressed: () => setState(() {
                calendarMonth = DateTime(calendarMonth.year, calendarMonth.month - 1, 1);
              }),
            ),
            IconButton(
              icon: const Icon(Icons.chevron_right, size: 20),
              onPressed: () => setState(() {
                calendarMonth = DateTime(calendarMonth.year, calendarMonth.month + 1, 1);
              }),
            ),
          ],
        ),
      ],
    );
  }

  Widget buildCalendarGrid() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            DateFormat('MMMM yyyy').format(calendarMonth),
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.grey[700]),
          ),
          const SizedBox(height: 12),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              mainAxisSpacing: 8,
              crossAxisSpacing: 8,
            ),
            itemCount: 35,
            itemBuilder: (context, index) {
              final firstDayOfMonth = DateTime(calendarMonth.year, calendarMonth.month, 1);
              final firstWeekday = firstDayOfMonth.weekday;
              final day = index - firstWeekday + 2;

              if (day < 1 || day > 31) return const SizedBox();

              final currentDate = DateTime(calendarMonth.year, calendarMonth.month, day);
              final isSelected = selectedDay.year == currentDate.year &&
                  selectedDay.month == currentDate.month &&
                  selectedDay.day == currentDate.day;
              final hasAppointments = hasAppointmentsOnDay(currentDate);

              return GestureDetector(
                onTap: () => setState(() => selectedDay = currentDate),
                child: Container(
                  decoration: BoxDecoration(
                    color: isSelected ? const Color(0xFF3B82F6) : Colors.transparent,
                    borderRadius: BorderRadius.circular(6),
                    border: hasAppointments && !isSelected
                        ? Border.all(color: const Color(0xFF3B82F6), width: 2)
                        : null,
                  ),
                  child: Center(
                    child: Text(
                      '$day',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        color: isSelected ? Colors.white : const Color(0xFF111827),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget buildQuickActions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Quick Actions',
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF111827)),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.search, size: 18),
            label: const Text('Find Slot'),
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.grey[700],
              side: BorderSide(color: Colors.grey[300]!),
            ),
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.filter_list, size: 18),
            label: const Text('Filter'),
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.grey[700],
              side: BorderSide(color: Colors.grey[300]!),
            ),
          ),
        ),
      ],
    );
  }

  Widget buildTimelineView(List<Appointment> appointments) {
    final sortedAppointments = List<Appointment>.from(appointments)..sort((a, b) => a.time.compareTo(b.time));

    return SingleChildScrollView(
      child: Column(
        children: [
          for (int hour = 8; hour < 18; hour++)
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: 50,
                  child: Text(
                    '${hour.toString().padLeft(2, '0')}:00',
                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: Colors.grey[500]),
                  ),
                ),
                Expanded(
                  child: Container(
                    height: 60,
                    decoration: BoxDecoration(
                      border: Border(bottom: BorderSide(color: Colors.grey[200]!, width: 1)),
                    ),
                    child: Stack(
                      children: [
                        ...sortedAppointments
                            .where((app) {
                          final timeParts = app.time.split(':');
                          final appHour = int.parse(timeParts[0]);
                          return appHour == hour;
                        })
                            .map((app) {
                          return Positioned(
                            top: 4,
                            left: 0,
                            right: 8,
                            child: MouseRegion(
                              onEnter: (_) => setState(() => hoveredAppointmentId = app.id),
                              onExit: (_) => setState(() => hoveredAppointmentId = null),
                              cursor: SystemMouseCursors.click,
                              child: GestureDetector(
                                onTap: () => navigateToAppointmentDetail(app),
                                child: buildAppointmentCard(app, hoveredAppointmentId == app.id),
                              ),
                            ),
                          );
                        }).toList(),
                      ],
                    ),
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }

  Widget buildAppointmentCard(Appointment app, [bool isHovered = false]) {
    final heightDouble = (app.duration / 60.0) * 60.0;
    final height = heightDouble < 50.0 ? 50.0 : heightDouble;
    bool showDuration = height > 50;
    bool showProcedure = height > 60;

    return Transform.scale(
      scale: isHovered ? 1.02 : 1.0,
      alignment: Alignment.topLeft,
      child: Container(
        height: height,
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: app.cardColor,
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: app.cardColor.withOpacity(isHovered ? 0.5 : 0.3),
              blurRadius: isHovered ? 12 : 8,
              offset: isHovered ? const Offset(0, 4) : const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    app.patientName,
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 4),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.25),
                    borderRadius: BorderRadius.circular(3),
                  ),
                  child: Text(
                    app.status.substring(0, 3).toUpperCase(),
                    style: const TextStyle(fontSize: 7, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                ),
              ],
            ),
            if (showProcedure) ...[
              const SizedBox(height: 3),
              Text(
                app.procedure,
                style: TextStyle(fontSize: 9, color: Colors.white.withOpacity(0.9)),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
            if (showDuration) const Spacer(),
            if (showDuration)
              Row(
                children: [
                  const Icon(Icons.schedule, size: 10, color: Colors.white),
                  const SizedBox(width: 3),
                  Text(
                    '${app.duration}m',
                    style: const TextStyle(fontSize: 8, color: Colors.white),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}