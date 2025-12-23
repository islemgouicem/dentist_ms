import 'package:dentist_ms/features/dashboard/data/revenue_remote.dart';
import 'package:dentist_ms/features/dashboard/models/revenue_chart_data.dart';
abstract class RevenueRepository {
  Future<RevenueChartData> getRevenueChartData({required int year});
}
class SupabaseRevenueRepository implements RevenueRepository {
  final RevenueRemoteDataSource _remote;

  SupabaseRevenueRepository({required RevenueRemoteDataSource remote})
      : _remote = remote;

  @override
  Future<RevenueChartData> getRevenueChartData({required int year}) async {
    return await _remote.getRevenueChartData(year: year);
  }
}