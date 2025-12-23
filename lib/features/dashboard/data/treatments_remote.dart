import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:dentist_ms/features/dashboard/models/treatments_chart_data.dart';

class TreatmentsRemoteDataSource {
  final SupabaseClient _client;

  TreatmentsRemoteDataSource({SupabaseClient? client})
      : _client = client ??  Supabase.instance.client;
  Future<TreatmentsChartData> getTreatmentsChartData() async {
    try {
      print('\n=== FETCHING TREATMENTS DATA ===');
      final treatmentsResponse = await _client
          .from('treatments')
          .select('id, name')
          .order('name', ascending: true);

      final treatments = treatmentsResponse as List;
      print('Found ${treatments.length} treatments in database');

      if (treatments.isEmpty) {
        print('WARNING: No treatments found in database! ');
        return const TreatmentsChartData(
          treatments: [],
          totalCount:  0,
        );
      }
      final patientTreatmentsResponse = await _client
          .from('patient_treatments')
          .select('treatment_id');

      final patientTreatments = patientTreatmentsResponse as List;
      final totalCount = patientTreatments.length;
      print('Found $totalCount patient_treatments records');
      Map<int, int> treatmentCounts = {};

      for (var pt in patientTreatments) {
        final treatmentId = pt['treatment_id'] as int? ;
        if (treatmentId != null) {
          treatmentCounts[treatmentId] = (treatmentCounts[treatmentId] ?? 0) + 1;
        }
      }

      print('Treatment counts:  $treatmentCounts');
      List<TreatmentDistribution> treatmentDistributions = [];

      for (var treatment in treatments) {
        final treatmentId = treatment['id'] as int;
        final treatmentName = treatment['name'] as String?  ?? 'Unknown';
        final count = treatmentCounts[treatmentId] ?? 0;
        final percentage = totalCount > 0 ? (count / totalCount) * 100 : 0.0;

        print('Treatment: $treatmentName (ID: $treatmentId)');
        print('  Count: $count');
        print('  Percentage:  ${percentage.toStringAsFixed(1)}%');

        treatmentDistributions.add(TreatmentDistribution(
          treatmentId: treatmentId,
          treatmentName: treatmentName,
          count: count,
          percentage: percentage,
        ));
      }
      treatmentDistributions.sort((a, b) => b.count.compareTo(a.count));

      print('\n=== SUMMARY ===');
      print('Total patient_treatments:  $totalCount');
      print('Number of treatment types: ${treatmentDistributions.length}');
      print('Treatments with data: ${treatmentDistributions. where((t) => t.count > 0).length}');

      return TreatmentsChartData(
        treatments: treatmentDistributions,
        totalCount: totalCount,
      );
    } catch (e, stackTrace) {
      print('ERROR in getTreatmentsChartData: $e');
      print('Stack trace: $stackTrace');
      throw Exception('Failed to load treatments chart data:  $e');
    }
  }
}