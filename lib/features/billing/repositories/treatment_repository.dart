import 'package:dentist_ms/features/billing/data/treatment_remote.dart';
import 'package:dentist_ms/features/billing/models/treatment.dart';

/// Abstract Interface for the Repository
abstract class TreatmentRepository {
  Future<List<Treatment>> getAllTreatments();
  Future<Treatment> getTreatmentById(int id);
  Future<Treatment> createTreatment(Treatment treatment);
  Future<Treatment> updateTreatment(Treatment treatment);
  Future<void> deleteTreatment(int id);
}

/// Implementation using Supabase Remote Data Source
class SupabaseTreatmentRepository implements TreatmentRepository {
  final TreatmentRemoteDataSource _remote;

  SupabaseTreatmentRepository({required TreatmentRemoteDataSource remote})
    : _remote = remote;

  @override
  Future<List<Treatment>> getAllTreatments() async {
    return await _remote.getTreatments();
  }

  @override
  Future<Treatment> getTreatmentById(int id) async {
    return await _remote.getTreatmentById(id);
  }

  @override
  Future<Treatment> createTreatment(Treatment treatment) async {
    return await _remote.addTreatment(treatment);
  }

  @override
  Future<Treatment> updateTreatment(Treatment treatment) async {
    return await _remote.updateTreatment(treatment);
  }

  @override
  Future<void> deleteTreatment(int id) async {
    return await _remote.deleteTreatment(id);
  }
}
