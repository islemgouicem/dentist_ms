import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:dentist_ms/features/billing/models/treatment.dart';

class TreatmentRemoteDataSource {
  final SupabaseClient _client;

  TreatmentRemoteDataSource({SupabaseClient? client})
    : _client = client ?? Supabase.instance.client;

  /// Fetch all treatments
  Future<List<Treatment>> getTreatments() async {
    try {
      final response = await _client
          .from('treatments')
          .select()
          .order('name', ascending: true);

      return (response as List)
          .map((json) => Treatment.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception('Failed to load treatments: $e');
    }
  }

  /// Fetch a single treatment by ID
  Future<Treatment> getTreatmentById(int id) async {
    try {
      final response = await _client
          .from('treatments')
          .select()
          .eq('id', id)
          .single();

      return Treatment.fromJson(response);
    } catch (e) {
      throw Exception('Failed to load treatment: $e');
    }
  }

  /// Add a new treatment
  Future<Treatment> addTreatment(Treatment treatment) async {
    try {
      final response = await _client
          .from('treatments')
          .insert(treatment.toJson())
          .select()
          .single();

      return Treatment.fromJson(response);
    } catch (e) {
      throw Exception('Failed to add treatment: $e');
    }
  }

  /// Update an existing treatment
  Future<Treatment> updateTreatment(Treatment treatment) async {
    if (treatment.id == null) {
      throw Exception('Treatment ID is required for update');
    }

    try {
      final response = await _client
          .from('treatments')
          .update(treatment.toJson())
          .eq('id', treatment.id!)
          .select()
          .single();

      return Treatment.fromJson(response);
    } catch (e) {
      throw Exception('Failed to update treatment: $e');
    }
  }

  /// Delete a treatment
  Future<void> deleteTreatment(int id) async {
    try {
      await _client.from('treatments').delete().eq('id', id);
    } catch (e) {
      throw Exception('Failed to delete treatment: $e');
    }
  }
}
