import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:dentist_ms/features/patients/models/patient.dart';

class PatientRemoteDataSource {
  final SupabaseClient _client;

  // Uses the singleton Supabase instance by default
  PatientRemoteDataSource({SupabaseClient? client})
      : _client = client ?? Supabase.instance.client;

  /// Fetch all patients ordered by creation date
  Future<List<Patient>> getPatients() async {
    try {
      final response = await _client
          .from('patients')
          .select()
          .order('created_at', ascending: false);

      // Supabase returns a List<dynamic>, we map it to List<Patient>
      return (response as List).map((json) => Patient.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to load patients: $e');
    }
  }

  /// Add a new patient
  Future<Patient> addPatient(Patient patient) async {
    try {
      final response = await _client
          .from('patients')
          .insert(patient.toJson())
          .select()
          .single(); // .single() returns the created object

      return Patient.fromJson(response);
    } catch (e) {
      throw Exception('Failed to add patient: $e');
    }
  }

  /// Update an existing patient
  Future<Patient> updatePatient(Patient patient) async {
    if (patient.id == null) throw Exception('Patient ID is required for update');

    try {
      final response = await _client
          .from('patients')
          .update(patient.toJson())
          .eq('id', patient.id!)
          .select()
          .single();

      return Patient.fromJson(response);
    } catch (e) {
      throw Exception('Failed to update patient: $e');
    }
  }

  /// Delete a patient
  Future<void> deletePatient(int id) async {
    try {
      await _client.from('patients').delete().eq('id', id);
    } catch (e) {
      throw Exception('Failed to delete patient: $e');
    }
  }
}