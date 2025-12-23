import 'package:dentist_ms/features/dashboard/data/treatments_remote.dart';
import 'package:dentist_ms/features/dashboard/models/treatments_chart_data.dart';
abstract class TreatmentsRepository {
  Future<TreatmentsChartData> getTreatmentsChartData();
}
class SupabaseTreatmentsRepository implements TreatmentsRepository {
  final TreatmentsRemoteDataSource _remote;

  SupabaseTreatmentsRepository({required TreatmentsRemoteDataSource remote})
      : _remote = remote;

  @override
  Future<TreatmentsChartData> getTreatmentsChartData() async {
    return await _remote.getTreatmentsChartData();
  }
}