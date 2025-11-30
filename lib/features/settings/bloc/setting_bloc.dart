import 'package:flutter_bloc/flutter_bloc.dart';
import 'setting_event.dart';
import 'setting_state.dart';
import 'package:dentist_ms/features/settings/repositories/setting_repository.dart';

class SettingBloc extends Bloc<SettingEvent, SettingState> {  // Use SettingEvent, not UserEvent
  final SettingRepository repository;

  SettingBloc({required this.repository}) : super(SettingsInitial()) {
    on<LoadUser>(_onLoadUser);
    on<UpdateUser>(_onUpdateUser);
  }
  // In your setting_bloc.dart, replace the _onLoadUser method with this:
  Future<void> _onLoadUser(
    LoadUser event,
    Emitter<SettingState> emit,
  ) async {
    emit(SettingsLoadInProgress());
    try {
      final user = await repository.getUser(event.userId);
      if (user != null) {
        emit(SettingsLoadSuccess([user]));
      } else {
        // User doesn't exist - create default user
        final defaultUser = await repository.createDefaultUser();
        emit(SettingsLoadSuccess([defaultUser]));
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
}