import 'package:flutter_bloc/flutter_bloc.dart';
import 'setting_event.dart';
import 'setting_state.dart';
import 'package:dentist_ms/features/settings/repositories/setting_repository.dart';

class SettingBloc extends Bloc<SettingEvent, SettingState> { 
  final SettingRepository repository;

  SettingBloc({required this.repository}) : super(SettingsInitial()) {
    on<LoadUser>(_onLoadUser);
    on<UpdateUser>(_onUpdateUser);
    on<ChangePassword>(_onChangePassword); 
  }
  
  Future<void> _onLoadUser(LoadUser event,Emitter<SettingState> emit) async {
    emit(SettingsLoadInProgress());
    try {
      final user = await repository.getUser(event.userId);
      if (user != null) {
        emit(SettingsLoadSuccess([user]));
      } else {
        emit(SettingsOperationFailure("user does not exist"));
      }
    } catch (e) {
      emit(SettingsOperationFailure('Failed to load user: ${e.toString()}'));
    }
  } 
  Future<void> _onUpdateUser(UpdateUser event, Emitter<SettingState> emit) async {
    emit(SettingsLoadInProgress());
    try {
      await repository.updateUser(event.user);
      add(LoadUser(event.user.id!));
    } catch (e) {
      emit(SettingsOperationFailure(e.toString()));
    }
  }
  Future<void> _onChangePassword(ChangePassword event, Emitter<SettingState> emit) async {
    emit(SettingsLoadInProgress());
    try {
      final success = await repository.changePassword(
        userId: event.userId,
        currentPassword: event.currentPassword,
        newPassword: event.newPassword,
      );
      
      if (success) {
        // Success - reload user data
        add(LoadUser(event.userId));
      } else {
        emit(SettingsOperationFailure("Mot de passe actuel incorrect"));
      }
    } catch (e) {
      emit(SettingsOperationFailure('Failed to change password: ${e.toString()}'));
    }
  }
}