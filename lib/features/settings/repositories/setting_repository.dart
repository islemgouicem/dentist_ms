// features/settings/repositories/setting_repository.dart
import 'package:dentist_ms/features/settings/data/setting_remote.dart';
import 'package:dentist_ms/features/settings/models/setting.dart';

abstract class SettingRepository {
  Future<Setting?> getUser(int userId);
  Future<Setting> updateUser(Setting user);
  Future<Setting> createDefaultUser(); // Add this line
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
  Future<Setting> createDefaultUser() async {
    return await _remote.createDefaultUser();
  }
}