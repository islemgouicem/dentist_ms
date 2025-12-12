import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:dentist_ms/features/settings/models/setting.dart';

class SettingRemoteDataSource {
  final SupabaseClient _client;

  SettingRemoteDataSource({SupabaseClient? client})
      : _client = client ?? Supabase.instance.client;

  // In setting_remote.dart - FIX the getUser method:
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

  // Add this method to your SettingRemoteDataSource class
  Future<Setting> createDefaultUser() async {
    try {
      final defaultUser = {
        'first_name': 'Korim',
        'last_name': 'Lounis', 
        'email': 'Karim@clinic.com',
        'phone': '+1234567890',
        'role': 'admin',
        'specialization': 'General Security',
        'bio': 'Default admin user',
        'identification_number': '12345',
        'password_hash': 'WIWWW'
      };

      final response = await _client
          .from('users')
          .insert(defaultUser)
          .select()
          .single();

      return Setting.fromJson(response);
    } catch (e) {
      throw Exception('Failed to create default user: ${e.toString()}');
    }
  }
  
  Future<bool> verifyCurrentPassword(String email, String password) async {
    try {
      // If using Supabase Auth, you can sign in to verify password
      final response = await _client.auth.signInWithPassword(
        email: email,
        password: password,
      );
      
      return response.user != null;
    } catch (e) {
      // If sign-in fails, password is incorrect
      return false;
    }
  }

  /// Update user password in Supabase Auth
  Future<void> updatePassword(String newPassword) async {
    try {
      final response = await _client.auth.updateUser(
        UserAttributes(password: newPassword),
      );
      
      if (response.user == null) {
        throw Exception('Failed to update password');
      }
    } catch (e) {
      throw Exception('Failed to update password: $e');
    }
  }

  /// Alternative: If storing passwords in your users table (not recommended)
  Future<bool> verifyCurrentPasswordInUsersTable(int userId, String password) async {
    try {
      await _client
          .from('users')
          .select('password_hash')
          .eq('id', userId)
          .single();

      // You would need to compare hashed passwords here
      // This is just a placeholder - implement proper hashing
      
      // TODO: Implement proper password verification
      // return verifyPasswordHash(password, storedHash);
      
      return true; // Placeholder
    } catch (e) {
      return false;
    }
  }

}