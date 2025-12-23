import 'package:dentist_ms/features/dashboard/data/patients_remote.dart';
import 'package:dentist_ms/features/dashboard/models/patients_chart_data.dart';
abstract class PatientsRepository {
  Future<PatientsChartData> getPatientsChartData({required int year});
}
class SupabasePatientsRepository implements PatientsRepository {
  final PatientsRemoteDataSource _remote;

  SupabasePatientsRepository({required PatientsRemoteDataSource remote})
      : _remote = remote;

  @override
  Future<PatientsChartData> getPatientsChartData({required int year}) async {
    return await _remote.getPatientsChartData(year: year);
  }
}