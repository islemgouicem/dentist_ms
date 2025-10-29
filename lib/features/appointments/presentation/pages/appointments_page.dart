import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';

class Appointment {
  final String id;
  final String patientName;
  final String procedure;
  final String time;
  final int duration;
  final String status;
  final Color color;
  final String doctor;

  Appointment({
    required this.id,
    required this.patientName,
    required this.procedure,
    required this.time,
    required this.duration,
    required this.status,
    required this.color,
    required this.doctor,
  });
}

class AppointmentPage extends StatefulWidget {
  const AppointmentPage({super.key});

  @override
  State<AppointmentPage> createState() => _AppointmentPageState();
}

class _AppointmentPageState extends State<AppointmentPage> {
  late DateTime _selectedDay;
  late DateTime _focusedDay;
  String _viewPeriod = 'day';

  @override
  void initState() {
    super.initState();
    _selectedDay = DateTime.now();
    _focusedDay = DateTime.now();
  }

  Map<DateTime, List<Appointment>> _getMockAppointments() {
    final today = DateTime.now();
    return {
      DateTime(today.year, today.month, today.day): [
        Appointment(
          id: '1',
          patientName: 'John Smith',
          procedure: 'Root Canal',
          time: '08:00',
          duration: 60,
          status: 'confirmed',
          color: Colors.blue,
          doctor: 'Dr. Miller',
        ),
        Appointment(
          id: '2',
          patientName: 'Emma Wilson',
          procedure: 'Teeth Cleaning',
          time: '10:30',
          duration: 45,
          status: 'pending',
          color: Colors.green,
          doctor: 'Dr. Johnson',
        ),
        Appointment(
          id: '3',
          patientName: 'Michael Brown',
          procedure: 'Dental Implant',
          time: '12:00',
          duration: 90,
          status: 'confirmed',
          color: Colors.blue,
          doctor: 'Dr. Miller',
        ),
        Appointment(
          id: '4',
          patientName: 'Sarah Davis',
          procedure: 'Crown Installation',
          time: '14:00',
          duration: 45,
          status: 'confirmed',
          color: Colors.deepPurple,
          doctor: 'Dr. Anderson',
        ),
      ],
      DateTime(today.year, today.month, today.day + 1): [
        Appointment(
          id: '5',
          patientName: 'Robert Johnson',
          procedure: 'Cavity Filling',
          time: '09:00',
          duration: 30,
          status: 'confirmed',
          color: Colors.blue,
          doctor: 'Dr. Miller',
        ),
      ],
    };
  }

  List<Appointment> _getAppointmentsForDay(DateTime day) {
    final key = DateTime(day.year, day.month, day.day);
    return _getMockAppointments()[key] ?? [];
  }

  List<Appointment> _getAppointmentsForPeriod() {
    if (_viewPeriod == 'day') {
      return _getAppointmentsForDay(_selectedDay);
    } else if (_viewPeriod == 'week') {
      final monday = _selectedDay.subtract(Duration(days: _selectedDay.weekday - 1));
      List<Appointment> weekApps = [];
      for (int i = 0; i < 7; i++) {
        weekApps.addAll(_getAppointmentsForDay(monday.add(Duration(days: i))));
      }
      return weekApps;
    } else {
      final firstDay = DateTime(_selectedDay.year, _selectedDay.month, 1);
      final lastDay = DateTime(_selectedDay.year, _selectedDay.month + 1, 0);
      List<Appointment> monthApps = [];
      for (DateTime day = firstDay;
          day.isBefore(lastDay.add(const Duration(days: 1)));
          day = day.add(const Duration(days: 1))) {
        monthApps.addAll(_getAppointmentsForDay(day));
      }
      return monthApps;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 900;
    final appointments = _getAppointmentsForDay(_selectedDay);
    final statsApps = _getAppointmentsForPeriod();
    final confirmed = statsApps.where((a) => a.status == 'confirmed').length;
    final pending = statsApps.where((a) => a.status == 'pending').length;
    final cancelled = statsApps.where((a) => a.status == 'cancelled').length;

    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.all(isMobile ? 16 : 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                if (isMobile)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Appointment Calendar',
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Manage and schedule appointments',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 12),
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            _buildViewButton('Day', 'day'),
                            const SizedBox(width: 8),
                            _buildViewButton('Week', 'week'),
                            const SizedBox(width: 8),
                            _buildViewButton('Month', 'month'),
                            const SizedBox(width: 8),
                            ElevatedButton.icon(
                              onPressed: _showAddAppointmentDialog,
                              icon: const Icon(Icons.add, size: 16),
                              label: const Text('New', style: TextStyle(fontSize: 12)),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blue,
                                foregroundColor: Colors.white,
                                elevation: 0,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 10,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  )
                else
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Appointment Calendar',
                            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Manage and schedule appointments',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          _buildViewButton('Day', 'day'),
                          const SizedBox(width: 8),
                          _buildViewButton('Week', 'week'),
                          const SizedBox(width: 8),
                          _buildViewButton('Month', 'month'),
                          const SizedBox(width: 16),
                          ElevatedButton.icon(
                            onPressed: _showAddAppointmentDialog,
                            icon: const Icon(Icons.add, size: 18),
                            label: const Text('New Appointment'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue,
                              foregroundColor: Colors.white,
                              elevation: 0,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 12,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                const SizedBox(height: 16),

                // Stats Cards
                if (isMobile)
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _buildStatCardMobile(
                          'Today',
                          appointments.length.toString(),
                          Icons.calendar_today,
                          Colors.blue,
                        ),
                        const SizedBox(width: 12),
                        _buildStatCardMobile(
                          'Confirmed',
                          confirmed.toString(),
                          Icons.check_circle,
                          Colors.green,
                        ),
                        const SizedBox(width: 12),
                        _buildStatCardMobile(
                          'Pending',
                          pending.toString(),
                          Icons.schedule,
                          Colors.amber,
                        ),
                        const SizedBox(width: 12),
                        _buildStatCardMobile(
                          'Cancelled',
                          cancelled.toString(),
                          Icons.cancel,
                          Colors.red,
                        ),
                      ],
                    ),
                  )
                else
                  Row(
                    children: [
                      Expanded(
                        child: _buildStatCard(
                          'Today\'s Appointments',
                          appointments.length.toString(),
                          Icons.calendar_today,
                          Colors.blue,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildStatCard(
                          'Confirmed',
                          confirmed.toString(),
                          Icons.check_circle,
                          Colors.green,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildStatCard(
                          'Pending',
                          pending.toString(),
                          Icons.schedule,
                          Colors.amber,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildStatCard(
                          'Cancelled',
                          cancelled.toString(),
                          Icons.cancel,
                          Colors.red,
                        ),
                      ),
                    ],
                  ),
                const SizedBox(height: 16),

                // Main Content
                if (isMobile)
                  Column(
                    children: [
                      _buildCalendarCard(),
                      const SizedBox(height: 16),
                      _buildScheduleCard(appointments),
                    ],
                  )
                else
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        width: 350,
                        child: _buildCalendarCard(),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildScheduleCard(appointments),
                      ),
                    ],
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatCardMobile(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      width: 110,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            title,
            style: TextStyle(
              fontSize: 10,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                title,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCalendarCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Calendar',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 16),
          TableCalendar(
            firstDay: DateTime.utc(2025, 1, 1),
            lastDay: DateTime.utc(2026, 12, 31),
            focusedDay: _focusedDay,
            selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
            onDaySelected: (selectedDay, focusedDay) {
              setState(() {
                _selectedDay = selectedDay;
                _focusedDay = focusedDay;
              });
            },
            calendarFormat: CalendarFormat.month,
            headerStyle: HeaderStyle(
              formatButtonVisible: false,
              titleCentered: true,
              titleTextStyle: Theme.of(context).textTheme.titleMedium!,
              leftChevronIcon: const Icon(Icons.chevron_left, size: 20),
              rightChevronIcon: const Icon(Icons.chevron_right, size: 20),
            ),
            daysOfWeekHeight: 36,
            rowHeight: 40,
            calendarStyle: CalendarStyle(
              selectedDecoration: const BoxDecoration(
                color: Colors.blue,
                shape: BoxShape.circle,
              ),
              todayDecoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.3),
                shape: BoxShape.circle,
              ),
              weekendTextStyle: const TextStyle(fontSize: 13),
              defaultTextStyle: const TextStyle(fontSize: 13),
              outsideTextStyle: TextStyle(fontSize: 13, color: Colors.grey[400]),
            ),
            daysOfWeekStyle: const DaysOfWeekStyle(
              weekdayStyle: TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
              weekendStyle: TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Quick Actions',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.search),
              label: const Text('Find Slot'),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.grey[700],
                side: BorderSide(color: Colors.grey[300]!),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.filter_list),
              label: const Text('Filter'),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.grey[700],
                side: BorderSide(color: Colors.grey[300]!),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScheduleCard(List<Appointment> appointments) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      DateFormat('EEEE, MMMM d, yyyy').format(_selectedDay),
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${appointments.length} appointments scheduled',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    IconButton(
                      onPressed: () {
                        setState(() {
                          _selectedDay =
                              _selectedDay.subtract(const Duration(days: 1));
                          _focusedDay = _selectedDay;
                        });
                      },
                      icon: const Icon(Icons.chevron_left),
                      style: IconButton.styleFrom(
                        backgroundColor: Colors.grey[100],
                      ),
                    ),
                    const SizedBox(width: 8),
                    TextButton.icon(
                      onPressed: () {
                        setState(() {
                          _selectedDay = DateTime.now();
                          _focusedDay = DateTime.now();
                        });
                      },
                      icon: const Icon(Icons.today, size: 18),
                      label: const Text('Today'),
                      style: TextButton.styleFrom(
                        backgroundColor: Colors.grey[100],
                        foregroundColor: Colors.black,
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      onPressed: () {
                        setState(() {
                          _selectedDay = _selectedDay.add(const Duration(days: 1));
                          _focusedDay = _selectedDay;
                        });
                      },
                      icon: const Icon(Icons.chevron_right),
                      style: IconButton.styleFrom(
                        backgroundColor: Colors.grey[100],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Divider(height: 1, color: Colors.grey[200]),
          if (appointments.isEmpty)
            Padding(
              padding: const EdgeInsets.all(60),
              child: Center(
                child: Column(
                  children: [
                    Icon(
                      Icons.calendar_today,
                      size: 48,
                      color: Colors.grey[300],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No appointments scheduled',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
            )
          else
            Padding(
              padding: const EdgeInsets.all(20),
              child: SizedBox(
                height: 600,
                child: _buildGoogleStyleTimeline(appointments),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildGoogleStyleTimeline(List<Appointment> appointments) {
    final sortedApps = List<Appointment>.from(appointments)
      ..sort((a, b) => a.time.compareTo(b.time));

    const double pixelsPerMinute = 1.0;
    final startHour = 8;
    final endHour = 18;
    final totalMinutes = (endHour - startHour) * 60;

    return SingleChildScrollView(
      child: SizedBox(
        height: totalMinutes * pixelsPerMinute,
        child: Stack(
          children: [
            // Hour grid lines and labels
            Column(
              children: List.generate(endHour - startHour + 1, (index) {
                final hour = startHour + index;
                final hourStr = '${hour.toString().padLeft(2, '0')}:00';
                return SizedBox(
                  height: 60,
                  child: Row(
                    children: [
                      SizedBox(
                        width: 55,
                        child: Text(
                          hourStr,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: Colors.grey[500],
                          ),
                          textAlign: TextAlign.right,
                        ),
                      ),
                      Expanded(
                        child: Container(
                          height: 1,
                          color: Colors.grey[200],
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ),
            // Appointments
            ...sortedApps.map((app) {
              final timeParts = app.time.split(':');
              final appHour = int.parse(timeParts[0]);
              final appMinute = int.parse(timeParts[1]);
              
              final minutesFromStart = ((appHour - startHour) * 60) + appMinute;
              final topOffset = minutesFromStart * pixelsPerMinute;
              final height = app.duration * pixelsPerMinute;

              return Positioned(
                top: topOffset,
                left: 63,
                right: 12,
                child: GestureDetector(
                  onTap: () => _showAppointmentDetail(app),
                  child: Container(
                    height: height.clamp(50, double.infinity),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: app.color,
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: [
                        BoxShadow(
                          color: app.color.withOpacity(0.25),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
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
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.25),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                app.status.substring(0, 3).toUpperCase(),
                                style: const TextStyle(
                                  fontSize: 8,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ],
                        ),
                        if (height > 45 && height < 55)
                          Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: Text(
                              app.procedure,
                              style: TextStyle(
                                fontSize: 10,
                                color: Colors.white.withOpacity(0.9),
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        if (height > 60 && height <= 100)
                          Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: Text(
                              '${app.duration}m',
                              style: TextStyle(
                                fontSize: 10,
                                color: Colors.white.withOpacity(0.8),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }

  List<Widget> _getAppointmentsInHour(
    List<Appointment> apps,
    int hour,
    double hourHeight,
  ) {
    final hourApps = apps.where((a) {
      final appHour = int.parse(a.time.split(':')[0]);
      return appHour == hour;
    }).toList();

    return hourApps.map((app) {
      final minutes = int.parse(app.time.split(':')[1]);
      final topOffset = (minutes / 60) * hourHeight;
      final height = (app.duration / 60) * hourHeight;

      return Positioned(
        top: topOffset,
        left: 0,
        right: 0,
        child: GestureDetector(
          onTap: () => _showAppointmentDetail(app),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: 50,
                child: Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: Text(
                    app.time,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey[600],
                    ),
                    textAlign: TextAlign.right,
                  ),
                ),
              ),
              Expanded(
                child: Container(
                  height: height.clamp(40, double.infinity),
                  margin: const EdgeInsets.only(right: 8, bottom: 8),
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: app.color,
                    borderRadius: BorderRadius.circular(6),
                    boxShadow: [
                      BoxShadow(
                        color: app.color.withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
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
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.3),
                              borderRadius: BorderRadius.circular(3),
                            ),
                            child: Text(
                              app.status.substring(0, 3).toUpperCase(),
                              style: const TextStyle(
                                fontSize: 7,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        app.procedure,
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.white.withOpacity(0.9),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }).toList();
  }

  Widget _buildViewButton(String label, String format) {
    final isSelected = _viewPeriod == format;
    return ElevatedButton(
      onPressed: () {
        setState(() {
          _viewPeriod = format;
        });
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: isSelected ? Colors.blue : Colors.white,
        foregroundColor: isSelected ? Colors.white : Colors.black,
        elevation: 0,
        side: BorderSide(
          color: isSelected ? Colors.transparent : Colors.grey[300]!,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      ),
      child: Text(label),
    );
  }

  String _getTimeRange(Appointment app) {
    final startTime = app.time;
    final parts = startTime.split(':');
    int hour = int.parse(parts[0]);
    int minute = int.parse(parts[1]);
    
    // Add duration to get end time
    minute += app.duration;
    hour += minute ~/ 60;
    minute = minute % 60;
    
    final endTime = '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}';
    return '$startTime - $endTime';
  }

  void _showAppointmentDetail(Appointment app) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Container(
          padding: const EdgeInsets.all(24),
          constraints: const BoxConstraints(maxWidth: 450),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  Container(
                    width: 6,
                    height: 60,
                    decoration: BoxDecoration(
                      color: app.color,
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        GestureDetector(
                          onTap: () {
                            // Navigate to patient profile
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Navigate to ${app.patientName}\'s profile')),
                            );
                          },
                          child: Text(
                            app.patientName,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.blue,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: app.color.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            app.status.toUpperCase(),
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: app.color,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Divider(color: Colors.grey[300]),
              const SizedBox(height: 16),

              // Appointment details
              _buildDetailRow('Procedure', app.procedure),
              const SizedBox(height: 12),
              _buildDetailRow('Date', DateFormat('EEEE, MMMM d, yyyy').format(_selectedDay)),
              const SizedBox(height: 12),
              _buildDetailRow('Time', _getTimeRange(app)),
              const SizedBox(height: 12),
              _buildDetailRow('Duration', '${app.duration} minutes'),
              const SizedBox(height: 12),
              _buildDetailRow('Doctor', app.doctor),
              const SizedBox(height: 20),

              // Action buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Close'),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      _showEditAppointmentDialog(app);
                    },
                    icon: const Icon(Icons.edit, size: 16),
                    label: const Text('Edit'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: app.color,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 80,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Colors.grey[700],
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  void _showEditAppointmentDialog(Appointment app) {
    final patientController = TextEditingController(text: app.patientName);
    final procedureController = TextEditingController(text: app.procedure);
    final doctorController = TextEditingController(text: app.doctor);
    final durationController = TextEditingController(text: app.duration.toString());

    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: SingleChildScrollView(
          child: Container(
            padding: const EdgeInsets.all(24),
            constraints: const BoxConstraints(maxWidth: 450),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Edit Appointment',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 20),

                // Patient name field
                Text(
                  'Patient Name',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[700],
                  ),
                ),
                const SizedBox(height: 6),
                TextField(
                  controller: patientController,
                  decoration: InputDecoration(
                    hintText: 'Enter patient name',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(6),
                    ),
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 10,
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Procedure field
                Text(
                  'Procedure',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[700],
                  ),
                ),
                const SizedBox(height: 6),
                TextField(
                  controller: procedureController,
                  decoration: InputDecoration(
                    hintText: 'Enter procedure type',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(6),
                    ),
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 10,
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Time field (read-only)
                Text(
                  'Time',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[700],
                  ),
                ),
                const SizedBox(height: 6),
                TextField(
                  readOnly: true,
                  controller: TextEditingController(text: _getTimeRange(app)),
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(6),
                    ),
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 10,
                    ),
                    filled: true,
                    fillColor: Colors.grey[100],
                  ),
                ),
                const SizedBox(height: 16),

                // Duration field
                Text(
                  'Duration (minutes)',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[700],
                  ),
                ),
                const SizedBox(height: 6),
                TextField(
                  controller: durationController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    hintText: 'Enter duration in minutes',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(6),
                    ),
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 10,
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Doctor field
                Text(
                  'Doctor',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[700],
                  ),
                ),
                const SizedBox(height: 6),
                TextField(
                  controller: doctorController,
                  decoration: InputDecoration(
                    hintText: 'Enter doctor name',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(6),
                    ),
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 10,
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Action buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancel'),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton.icon(
                      onPressed: () {
                        // Save changes
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Appointment updated successfully')),
                        );
                        Navigator.pop(context);
                      },
                      icon: const Icon(Icons.save, size: 16),
                      label: const Text('Save'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
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
  }

  void _showAddAppointmentDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Schedule New Appointment'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Patient',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                isExpanded: true,
                decoration: InputDecoration(
                  isDense: true,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(6)),
                ),
                items: const [
                  DropdownMenuItem(value: '1', child: Text('John Smith')),
                  DropdownMenuItem(value: '2', child: Text('Emma Wilson')),
                  DropdownMenuItem(value: '3', child: Text('Michael Brown')),
                ],
                onChanged: (val) {},
              ),
              const SizedBox(height: 16),
              const Text(
                'Treatment',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                isExpanded: true,
                decoration: InputDecoration(
                  isDense: true,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(6)),
                ),
                items: const [
                  DropdownMenuItem(value: 'cleaning', child: Text('Cleaning')),
                  DropdownMenuItem(value: 'filling', child: Text('Filling')),
                  DropdownMenuItem(value: 'crown', child: Text('Crown')),
                  DropdownMenuItem(value: 'root', child: Text('Root Canal')),
                ],
                onChanged: (val) {},
              ),
              const SizedBox(height: 16),
              const Text(
                'Date',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
              ),
              const SizedBox(height: 8),
              TextField(
                decoration: InputDecoration(
                  isDense: true,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                  hintText: 'mm/dd/yyyy',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(6)),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Time',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                isExpanded: true,
                decoration: InputDecoration(
                  isDense: true,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(6)),
                ),
                items: const [
                  DropdownMenuItem(value: '08:00', child: Text('08:00')),
                  DropdownMenuItem(value: '09:00', child: Text('09:00')),
                  DropdownMenuItem(value: '10:00', child: Text('10:00')),
                  DropdownMenuItem(value: '11:00', child: Text('11:00')),
                  DropdownMenuItem(value: '14:00', child: Text('14:00')),
                ],
                onChanged: (val) {},
              ),
              const SizedBox(height: 16),
              const Text(
                'Duration',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                isExpanded: true,
                decoration: InputDecoration(
                  isDense: true,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(6)),
                ),
                items: const [
                  DropdownMenuItem(value: '30', child: Text('30 minutes')),
                  DropdownMenuItem(value: '45', child: Text('45 minutes')),
                  DropdownMenuItem(value: '60', child: Text('60 minutes')),
                  DropdownMenuItem(value: '90', child: Text('90 minutes')),
                ],
                onChanged: (val) {},
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
            child: const Text('Schedule'),
          ),
        ],
      ),
    );
  }
}