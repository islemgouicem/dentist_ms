import 'package:dentist_ms/features/patients/data/patient_remote.dart';
import 'package:dentist_ms/features/patients/models/patient.dart';

/// Abstract Interface for the Repository
abstract class PatientRepository {
  Future<List<Patient>> getAllPatients();
  Future<Patient> createPatient(Patient patient);
  Future<Patient> updatePatient(Patient patient);
  Future<void> deletePatient(int id);
}

/// Implementation using Supabase Remote Data Source
class SupabasePatientRepository implements PatientRepository {
  final PatientRemoteDataSource _remote;

  SupabasePatientRepository({required PatientRemoteDataSource remote})
    : _remote = remote;

  @override
  Future<List<Patient>> getAllPatients() async {
    return await _remote.getPatients();
  }

  @override
  Future<Patient> createPatient(Patient patient) async {
    return await _remote.addPatient(patient);
  }

  @override
  Future<Patient> updatePatient(Patient patient) async {
    return await _remote.updatePatient(patient);
  }

  @override
  Future<void> deletePatient(int id) async {
    return await _remote.deletePatient(id);
  }
}
