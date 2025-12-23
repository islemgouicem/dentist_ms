import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:dentist_ms/features/dashboard/models/performance_chart_data.dart';

class PerformanceRemoteDataSource {
  final SupabaseClient _client;

  PerformanceRemoteDataSource({SupabaseClient? client})
      : _client = client ??   Supabase.instance. client;

  Future<PerformanceChartData> getPerformanceChartData({required int year}) async {
    try {
      print('\n=== FETCHING PERFORMANCE DATA FOR YEAR $year ===');
      final startDate = DateTime(year, 1, 1);
      final endDate = DateTime(year, 12, 31, 23, 59, 59);
      final appointmentsResponse = await _client
          .from('appointments')
          .select('id, status, start_datetime')
          .gte('start_datetime', startDate.toIso8601String().split('T')[0])
          .lte('start_datetime', endDate.toIso8601String().split('T')[0])
          .not('status', 'is', null);

      final appointments = appointmentsResponse as List;
      print('Found ${appointments.length} appointments in $year');
      Map<int, Map<String, int>> appointmentsByMonth = {};
      for (int month = 1; month <= 12; month++) {
        appointmentsByMonth[month] = {
          'completed': 0,
          'confirmed': 0,
          'cancelled': 0,
          'no-show': 0,
        };
      }

      for (var appointment in appointments) {
        if (appointment['start_datetime'] != null && appointment['status'] != null) {
          try {
            final startDatetime = DateTime.parse(appointment['start_datetime']. toString());
            final month = startDatetime.month;
            final status = appointment['status'].toString().toLowerCase();

            if (appointmentsByMonth. containsKey(month)) {
              if (status == 'completed') {
                appointmentsByMonth[month]!['completed'] = 
                    (appointmentsByMonth[month]! ['completed'] ?? 0) + 1;
              } else if (status == 'confirmed' || status == 'scheduled') {
                appointmentsByMonth[month]!['confirmed'] = 
                    (appointmentsByMonth[month]!['confirmed'] ?? 0) + 1;
              } else if (status == 'cancelled') {
                appointmentsByMonth[month]!['cancelled'] = 
                    (appointmentsByMonth[month]!['cancelled'] ?? 0) + 1;
              } else if (status == 'no-show' || status == 'noshow' || status == 'no_show') {
                appointmentsByMonth[month]!['no-show'] = 
                    (appointmentsByMonth[month]!['no-show'] ?? 0) + 1;
              } else {
                print('Unknown status found: "$status"');
              }
            }
          } catch (e) {
            print('Error parsing start_datetime: ${appointment['start_datetime']}, error: $e');
          }
        }
      }

      List<MonthlyAppointmentStatus> monthlyData = [];
      int totalAppointments = 0;

      final monthNames = ['', 'Jan', 'Fév', 'Mar', 'Avr', 'Mai', 'Jun', 'Jul', 'Aoû', 'Sep', 'Oct', 'Nov', 'Déc'];

      print('\n=== MONTHLY BREAKDOWN ===');

      for (int month = 1; month <= 12; month++) {
        final completed = appointmentsByMonth[month]!['completed']!;
        final confirmed = appointmentsByMonth[month]!['confirmed']! ;
        final cancelled = appointmentsByMonth[month]!['cancelled']!;
        final noShow = appointmentsByMonth[month]!['no-show']!;
        final total = completed + confirmed + cancelled + noShow;

        totalAppointments += total;

        if (total > 0) {
          print('${monthNames[month]. padRight(4)}: Total=$total (Completed=$completed, Confirmed=$confirmed, Cancelled=$cancelled, No-show=$noShow)');
        }

        monthlyData.add(MonthlyAppointmentStatus(
          month:  month,
          year: year,
          completedCount: completed,
          confirmedCount: confirmed,
          cancelledCount: cancelled,
          noShowCount: noShow,
          totalCount: total,
        ));
      }
      print('\n=== FETCHING DOCTOR PERFORMANCE ===');
      final treatmentsResponse = await _client
          .from('patient_treatments')
          .select('doctor_id, status, session_date')
          .eq('status', 'completed')
          . gte('session_date', startDate.toIso8601String().split('T')[0])
          .lte('session_date', endDate.toIso8601String().split('T')[0]);

      final treatments = treatmentsResponse as List;
      print('Found ${treatments.length} completed treatments in $year');
      Map<String, int> treatmentsByDoctor = {};
      for (var treatment in treatments) {
        final doctorId = treatment['doctor_id']?.toString();
        if (doctorId != null && doctorId.isNotEmpty) {
          treatmentsByDoctor[doctorId] = (treatmentsByDoctor[doctorId] ??  0) + 1;
        }
      }
      List<DoctorPerformance> doctorPerformanceList = [];
      int maxTreatments = 0;

      if (treatmentsByDoctor. isNotEmpty) {
        final doctorIds = treatmentsByDoctor.keys.toList();
        
        final usersResponse = await _client
            .from('users')
            .select('id, first_name, last_name')
            .inFilter('id', doctorIds);

        final users = usersResponse as List;
        Map<String, String> doctorNames = {};
        for (var user in users) {
          final id = user['id']. toString();
          final firstName = user['first_name']?.toString() ?? '';
          final lastName = user['last_name']?.toString() ?? '';
          doctorNames[id] = '$firstName $lastName'. trim();
          if (doctorNames[id]!.isEmpty) {
            doctorNames[id] = 'Docteur ${id. substring(0, 8)}';
          }
        }
        maxTreatments = treatmentsByDoctor.values.reduce((a, b) => a > b ? a : b);
        for (var entry in treatmentsByDoctor.entries) {
          final doctorId = entry.key;
          final count = entry.value;
          final name = doctorNames[doctorId] ?? 'Docteur inconnu';
          final progress = maxTreatments > 0 ? count / maxTreatments : 0.0;

          doctorPerformanceList. add(DoctorPerformance(
            doctorId: doctorId,
            doctorName: name,
            completedTreatments: count,
            progress: progress,
          ));
        }
        doctorPerformanceList.sort((a, b) => b.completedTreatments.compareTo(a.completedTreatments));

        print('\n=== DOCTOR PERFORMANCE RANKING ===');
        for (int i = 0; i < doctorPerformanceList.length; i++) {
          final doc = doctorPerformanceList[i];
          print('${i + 1}. ${doc. doctorName}:  ${doc.completedTreatments} treatments');
        }
      }

      print('\n=== SUMMARY ===');
      print('Total appointments in $year:  $totalAppointments');
      print('Total doctors with completed treatments:  ${doctorPerformanceList. length}');

      return PerformanceChartData(
        monthlyData: monthlyData,
        totalAppointments: totalAppointments,
        doctorPerformance: doctorPerformanceList,
        maxDoctorTreatments: maxTreatments,
      );
    } catch (e, stackTrace) {
      print('ERROR in getPerformanceChartData:  $e');
      print('Stack trace: $stackTrace');
      throw Exception('Failed to load performance chart data: $e');
    }
  }
}