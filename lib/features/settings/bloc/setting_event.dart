import 'package:dentist_ms/features/settings/models/setting.dart';
import 'package:equatable/equatable.dart';

abstract class SettingEvent extends Equatable {  // Should be SettingEvent, not UserEvent
  const SettingEvent();

  @override
  List<Object?> get props => [];
}

class LoadUser extends SettingEvent {
  final int userId;
  const LoadUser(this.userId);

  @override
  List<Object?> get props => [userId];
}

class UpdateUser extends SettingEvent {
  final Setting user;
  const UpdateUser(this.user);

  @override
  List<Object?> get props => [user];
}
