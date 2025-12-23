import 'package:dentist_ms/features/dashboard/data/dashboard_remote.dart';
import 'package:dentist_ms/features/dashboard/models/dashboard_metrics.dart';
abstract class DashboardRepository {
  Future<DashboardMetrics> getDashboardMetrics({required String dateRange});
}
class SupabaseDashboardRepository implements DashboardRepository {
  final DashboardRemoteDataSource _remote;

  SupabaseDashboardRepository({required DashboardRemoteDataSource remote})
      : _remote = remote;

  @override
  Future<DashboardMetrics> getDashboardMetrics({required String dateRange}) async {
    return await _remote.getDashboardMetrics(dateRange: dateRange);
  }
}