import 'package:dentist_ms/features/dashboard/data/performance_remote.dart';
import 'package:dentist_ms/features/dashboard/models/performance_chart_data.dart';
abstract class PerformanceRepository {
  Future<PerformanceChartData> getPerformanceChartData({required int year});
}
class SupabasePerformanceRepository implements PerformanceRepository {
  final PerformanceRemoteDataSource _remote;

  SupabasePerformanceRepository({required PerformanceRemoteDataSource remote})
      : _remote = remote;

  @override
  Future<PerformanceChartData> getPerformanceChartData({required int year}) async {
    return await _remote.getPerformanceChartData(year: year);
  }
}