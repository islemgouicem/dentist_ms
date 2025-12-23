import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:dentist_ms/features/dashboard/models/patients_chart_data.dart';

class PatientsRemoteDataSource {
  final SupabaseClient _client;

  PatientsRemoteDataSource({SupabaseClient? client})
      : _client = client ??  Supabase.instance.client;
 
  Future<PatientsChartData> getPatientsChartData({required int year}) async {
    try {
      print('\n=== FETCHING PATIENTS DATA FOR YEAR $year ===');
 
      final startDate = DateTime(year, 1, 1);
      final endDate = DateTime(year, 12, 31, 23, 59, 59);

      final patientsResponse = await _client
          .from('patients')
          .select('id, created_at')
          .order('created_at', ascending: true);

      final allPatients = patientsResponse as List;
      print('Total patients in database: ${allPatients.length}');

      Map<int, int> newPatientsByMonth = {};
      int patientsBeforeYear = 0;

      for (var patient in allPatients) {
        if (patient['created_at'] != null) {
          try {
            final createdAt = DateTime.parse(patient['created_at']. toString());
             
            if (createdAt.year < year) {
              patientsBeforeYear++;
            } 
            else if (createdAt.year == year) {
              final month = createdAt.month;
              newPatientsByMonth[month] = (newPatientsByMonth[month] ?? 0) + 1;
            }
          } catch (e) {
            print('Error parsing patient created_at: ${patient['created_at']}, error: $e');
          }
        }
      }

      print('Patients registered before $year: $patientsBeforeYear');
      print('New patients by month in $year: $newPatientsByMonth');
 
      List<MonthlyPatientCount> monthlyData = [];
      int cumulativeCount = patientsBeforeYear;
      int maxPatientCount = cumulativeCount;

      final monthNames = ['', 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];

      for (int month = 1; month <= 12; month++) {
        final newPatients = newPatientsByMonth[month] ?? 0;
        cumulativeCount += newPatients;

        if (cumulativeCount > maxPatientCount) {
          maxPatientCount = cumulativeCount;
        }

        print('${monthNames[month]. padRight(4)}: New=${newPatients. toString().padLeft(3)}, Cumulative=$cumulativeCount');

        monthlyData.add(MonthlyPatientCount(
          month: month,
          year:  year,
          cumulativeCount: cumulativeCount,
          newPatients: newPatients,
        ));
      }

      print('\n=== SUMMARY ===');
      print('Max cumulative patient count: $maxPatientCount');

      return PatientsChartData(
        monthlyData: monthlyData,
        maxPatientCount: maxPatientCount,
      );
    } catch (e) {
      print('ERROR in getPatientsChartData: $e');
      throw Exception('Failed to load patients chart data: $e');
    }
  }
}