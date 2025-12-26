import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:dentist_ms/features/settings/models/setting.dart';

class SettingRemoteDataSource {
  final SupabaseClient _client;

  SettingRemoteDataSource({SupabaseClient? client}) : _client = client ?? Supabase.instance.client;

  Future<Setting?> getUser(int userId) async {
    try {
      final response = await _client
          .from('users')
          .select()
          .eq('id', userId)
          .maybeSingle(); // Use maybeSingle instead of single

      if (response == null) {
        return null; // No user found
      }

      return Setting.fromJson(response);
    } catch (e) {
      // Return null for "no rows" error, rethrow for other errors
      if (e.toString().contains('PGRST116') || e.toString().contains('0 rows')) {
        return null;
      }
      throw Exception('Failed to load user: ${e.toString()}');
    }
  }
  Future<Setting> updateUser(Setting user) async {
    if (user.id == null) throw Exception('User ID is required for update');

    try {
      final response = await _client
          .from('users')
          .update(user.toJson())
          .eq('id', user.id!)
          .select()
          .single();

      return Setting.fromJson(response);
    } catch (e) {
      throw Exception('Failed to update user: $e');
    }
  }
  Future<void> updatePassword(int userId, String newPasswordHash) async {
    try {
      await _client
          .from('users')
          .update({
            'password_hash': newPasswordHash,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', userId);
    } catch (e) {
      throw Exception('Failed to update password: $e');
    }
  } 
  Future<String?> getPasswordHash(int userId) async {
    try {
      final response = await _client
          .from('users')
          .select('password_hash')
          .eq('id', userId)
          .single();
      
      return response['password_hash'] as String?;
    } catch (e) {
      return null;
    }
  }
}