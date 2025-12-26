import 'package:dentist_ms/features/settings/models/setting.dart';
import 'package:equatable/equatable.dart';

abstract class SettingEvent extends Equatable {
  const SettingEvent();
  @override List<Object?> get props => [];
}

class LoadUser extends SettingEvent {
  final int userId;
  const LoadUser(this.userId);
  @override List<Object?> get props => [userId];
}

class UpdateUser extends SettingEvent {
  final Setting user;
  const UpdateUser(this.user);
  @override List<Object?> get props => [user];
}

class ChangePassword extends SettingEvent {
  final int userId;
  final String currentPassword;
  final String newPassword;
  const ChangePassword({
    required this.userId,
    required this.currentPassword,
    required this.newPassword,
  });
  @override List<Object?> get props => [userId, currentPassword, newPassword];
}