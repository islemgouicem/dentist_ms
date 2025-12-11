import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dentist_ms/features/billing/repositories/treatment_repository.dart';
import 'treatment_event.dart';
import 'treatment_state.dart';

class TreatmentBloc extends Bloc<TreatmentEvent, TreatmentState> {
  final TreatmentRepository _repository;

  TreatmentBloc({required TreatmentRepository repository})
    : _repository = repository,
      super(TreatmentsInitial()) {
    on<LoadTreatments>(_onLoadTreatments);
    on<AddTreatment>(_onAddTreatment);
    on<UpdateTreatment>(_onUpdateTreatment);
    on<DeleteTreatment>(_onDeleteTreatment);
  }

  Future<void> _onLoadTreatments(
    LoadTreatments event,
    Emitter<TreatmentState> emit,
  ) async {
    emit(TreatmentsLoadInProgress());
    try {
      final treatments = await _repository.getAllTreatments();
      emit(TreatmentsLoadSuccess(treatments));
    } catch (e) {
      emit(TreatmentsOperationFailure(e.toString()));
    }
  }

  Future<void> _onAddTreatment(
    AddTreatment event,
    Emitter<TreatmentState> emit,
  ) async {
    try {
      await _repository.createTreatment(event.treatment);
      // Reload the list after adding
      add(LoadTreatments());
    } catch (e) {
      emit(TreatmentsOperationFailure(e.toString()));
    }
  }

  Future<void> _onUpdateTreatment(
    UpdateTreatment event,
    Emitter<TreatmentState> emit,
  ) async {
    try {
      await _repository.updateTreatment(event.treatment);
      // Reload the list after updating
      add(LoadTreatments());
    } catch (e) {
      emit(TreatmentsOperationFailure(e.toString()));
    }
  }

  Future<void> _onDeleteTreatment(
    DeleteTreatment event,
    Emitter<TreatmentState> emit,
  ) async {
    try {
      await _repository.deleteTreatment(event.id);
      // Reload the list after deleting
      add(LoadTreatments());
    } catch (e) {
      emit(TreatmentsOperationFailure(e.toString()));
    }
  }
}
