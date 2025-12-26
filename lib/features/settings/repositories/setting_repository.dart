import 'package:dentist_ms/features/settings/data/setting_remote.dart';
import 'package:dentist_ms/features/settings/models/setting.dart';
import 'package:dentist_ms/features/settings/utils/password_hasher.dart';

abstract class SettingRepository {
  Future<Setting?> getUser(int userId);
  Future<Setting> updateUser(Setting user);
  // Add password change method
  Future<bool> changePassword({
    required int userId,
    required String currentPassword,
    required String newPassword,
  });
}

class SupabaseSettingRepository implements SettingRepository {
  final SettingRemoteDataSource _remote;

  SupabaseSettingRepository({required SettingRemoteDataSource remote})
    : _remote = remote;

  @override
  Future<Setting?> getUser(int userId) async {
    return await _remote.getUser(userId);
  }

  @override
  Future<Setting> updateUser(Setting user) async {
    return await _remote.updateUser(user);
  }

  @override
  Future<bool> changePassword({
    required int userId,
    required String currentPassword,
    required String newPassword,
  }) async {
    // Get current password hash from database
    final storedHash = await _remote.getPasswordHash(userId);
    if (storedHash == null) {
      throw Exception('User not found');
    }
    
    // Verify current password
    final currentHash = PasswordHasher.hashPassword(currentPassword);
    if (currentHash != storedHash) {
      return false; // Wrong current password
    }
    
    // Hash new password
    final newHash = PasswordHasher.hashPassword(newPassword);
    
    // Update password in database
    await _remote.updatePassword(userId, newHash);
    
    return true;
  }
}