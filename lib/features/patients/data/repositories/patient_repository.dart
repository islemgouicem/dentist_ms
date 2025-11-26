import 'package:dentist_ms/core/services/supabase_service.dart';
import 'package:dentist_ms/features/patients/data/models/patient_model.dart';

/// Repository for patient data operations with Supabase.
class PatientRepository {
  static const String _tableName = 'patients';

  /// Get all patients from the database
  Future<List<Patient>> getPatients({
    String? searchQuery,
    String? status,
  }) async {
    try {
      var query = SupabaseService.client.from(_tableName).select();

      if (status != null && status.isNotEmpty) {
        query = query.eq('status', status);
      }

      final response = await query.order('created_at', ascending: false);

      List<Patient> patients = (response as List)
          .map((json) => Patient.fromJson(json as Map<String, dynamic>))
          .toList();

      // Apply search filter client-side for flexibility
      if (searchQuery != null && searchQuery.isNotEmpty) {
        final query = searchQuery.toLowerCase();
        patients = patients.where((patient) {
          return patient.firstName.toLowerCase().contains(query) ||
              patient.lastName.toLowerCase().contains(query) ||
              (patient.email?.toLowerCase().contains(query) ?? false) ||
              (patient.phone?.contains(query) ?? false) ||
              (patient.id?.toLowerCase().contains(query) ?? false);
        }).toList();
      }

      return patients;
    } catch (e) {
      throw PatientRepositoryException('Failed to fetch patients: $e');
    }
  }

  /// Get a single patient by ID
  Future<Patient?> getPatientById(String id) async {
    try {
      final response = await SupabaseService.client
          .from(_tableName)
          .select()
          .eq('id', id)
          .maybeSingle();

      if (response == null) return null;
      return Patient.fromJson(response);
    } catch (e) {
      throw PatientRepositoryException('Failed to fetch patient: $e');
    }
  }

  /// Create a new patient
  Future<Patient> createPatient(Patient patient) async {
    try {
      final response = await SupabaseService.client
          .from(_tableName)
          .insert(patient.toJson())
          .select()
          .single();

      return Patient.fromJson(response);
    } catch (e) {
      throw PatientRepositoryException('Failed to create patient: $e');
    }
  }

  /// Update an existing patient
  Future<Patient> updatePatient(Patient patient) async {
    if (patient.id == null) {
      throw PatientRepositoryException('Patient ID is required for update');
    }

    try {
      final data = patient.toJson();
      data['updated_at'] = DateTime.now().toIso8601String();

      final response = await SupabaseService.client
          .from(_tableName)
          .update(data)
          .eq('id', patient.id!)
          .select()
          .single();

      return Patient.fromJson(response);
    } catch (e) {
      throw PatientRepositoryException('Failed to update patient: $e');
    }
  }

  /// Delete a patient by ID
  Future<void> deletePatient(String id) async {
    try {
      await SupabaseService.client.from(_tableName).delete().eq('id', id);
    } catch (e) {
      throw PatientRepositoryException('Failed to delete patient: $e');
    }
  }

  /// Get patient statistics
  Future<PatientStats> getPatientStats() async {
    try {
      final allPatients = await getPatients();

      final now = DateTime.now();
      final startOfMonth = DateTime(now.year, now.month, 1);

      int totalPatients = allPatients.length;
      int activePatients =
          allPatients.where((p) => p.status == 'active').length;
      int newThisMonth = allPatients
          .where((p) =>
              p.createdAt != null && p.createdAt!.isAfter(startOfMonth))
          .length;
      double totalBalance =
          allPatients.fold(0, (sum, p) => sum + p.balance);

      return PatientStats(
        totalPatients: totalPatients,
        activePatients: activePatients,
        newThisMonth: newThisMonth,
        pendingBalance: totalBalance,
      );
    } catch (e) {
      throw PatientRepositoryException('Failed to fetch patient stats: $e');
    }
  }
}

/// Patient statistics data class
class PatientStats {
  final int totalPatients;
  final int activePatients;
  final int newThisMonth;
  final double pendingBalance;

  const PatientStats({
    required this.totalPatients,
    required this.activePatients,
    required this.newThisMonth,
    required this.pendingBalance,
  });
}

/// Exception class for patient repository errors
class PatientRepositoryException implements Exception {
  final String message;

  PatientRepositoryException(this.message);

  @override
  String toString() => message;
}
