import 'package:equatable/equatable.dart';
import 'package:dentist_ms/features/settings/models/setting.dart';

abstract class SettingState extends Equatable {
  const SettingState();
  
  @override
  List<Object?> get props => [];
}

class SettingsInitial extends SettingState {}

class SettingsLoadInProgress extends SettingState {}

class SettingsLoadSuccess extends SettingState {
  final List<Setting> users;

  const SettingsLoadSuccess(this.users);

  @override
  List<Object?> get props => [users];
}

class SettingsOperationFailure extends SettingState {
  final String message;

  const SettingsOperationFailure(this.message);

  @override
  List<Object?> get props => [message];
}
