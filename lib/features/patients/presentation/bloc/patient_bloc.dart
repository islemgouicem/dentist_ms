import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dentist_ms/features/patients/data/models/patient_model.dart';
import 'package:dentist_ms/features/patients/data/repositories/patient_repository.dart';
import 'patient_event.dart';
import 'patient_state.dart';

/// BLoC for managing patient state
class PatientBloc extends Bloc<PatientEvent, PatientState> {
  final PatientRepository _repository;

  PatientBloc({PatientRepository? repository})
      : _repository = repository ?? PatientRepository(),
        super(const PatientInitial()) {
    on<LoadPatients>(_onLoadPatients);
    on<LoadPatientStats>(_onLoadPatientStats);
    on<AddPatient>(_onAddPatient);
    on<UpdatePatient>(_onUpdatePatient);
    on<DeletePatient>(_onDeletePatient);
    on<SearchPatients>(_onSearchPatients);
    on<ClearPatientError>(_onClearError);
  }

  Future<void> _onLoadPatients(
    LoadPatients event,
    Emitter<PatientState> emit,
  ) async {
    emit(const PatientLoading());
    try {
      final patients = await _repository.getPatients(
        searchQuery: event.searchQuery,
        status: event.status,
      );
      final stats = await _repository.getPatientStats();
      emit(PatientLoaded(
        patients: patients,
        stats: stats,
        searchQuery: event.searchQuery,
      ));
    } catch (e) {
      emit(PatientError(message: e.toString()));
    }
  }

  Future<void> _onLoadPatientStats(
    LoadPatientStats event,
    Emitter<PatientState> emit,
  ) async {
    final currentState = state;
    List<Patient> currentPatients = [];
    if (currentState is PatientLoaded) {
      currentPatients = currentState.patients;
    }

    try {
      final stats = await _repository.getPatientStats();
      emit(PatientLoaded(
        patients: currentPatients,
        stats: stats,
      ));
    } catch (e) {
      emit(PatientError(
        message: e.toString(),
        patients: currentPatients,
      ));
    }
  }

  Future<void> _onAddPatient(
    AddPatient event,
    Emitter<PatientState> emit,
  ) async {
    final currentState = state;
    List<Patient> currentPatients = [];
    PatientStats? currentStats;

    if (currentState is PatientLoaded) {
      currentPatients = currentState.patients;
      currentStats = currentState.stats;
    }

    emit(PatientOperationInProgress(
      patients: currentPatients,
      stats: currentStats,
      operation: 'Adding patient...',
    ));

    try {
      final newPatient = await _repository.createPatient(event.patient);
      final updatedPatients = [newPatient, ...currentPatients];
      final stats = await _repository.getPatientStats();

      emit(PatientOperationSuccess(
        patients: updatedPatients,
        stats: stats,
        message: 'Patient added successfully',
      ));

      // After success, return to loaded state
      emit(PatientLoaded(
        patients: updatedPatients,
        stats: stats,
      ));
    } catch (e) {
      emit(PatientError(
        message: 'Failed to add patient: $e',
        patients: currentPatients,
        stats: currentStats,
      ));
    }
  }

  Future<void> _onUpdatePatient(
    UpdatePatient event,
    Emitter<PatientState> emit,
  ) async {
    final currentState = state;
    List<Patient> currentPatients = [];
    PatientStats? currentStats;

    if (currentState is PatientLoaded) {
      currentPatients = currentState.patients;
      currentStats = currentState.stats;
    }

    emit(PatientOperationInProgress(
      patients: currentPatients,
      stats: currentStats,
      operation: 'Updating patient...',
    ));

    try {
      final updatedPatient = await _repository.updatePatient(event.patient);
      final updatedPatients = currentPatients.map((p) {
        return p.id == updatedPatient.id ? updatedPatient : p;
      }).toList();
      final stats = await _repository.getPatientStats();

      emit(PatientOperationSuccess(
        patients: updatedPatients,
        stats: stats,
        message: 'Patient updated successfully',
      ));

      emit(PatientLoaded(
        patients: updatedPatients,
        stats: stats,
      ));
    } catch (e) {
      emit(PatientError(
        message: 'Failed to update patient: $e',
        patients: currentPatients,
        stats: currentStats,
      ));
    }
  }

  Future<void> _onDeletePatient(
    DeletePatient event,
    Emitter<PatientState> emit,
  ) async {
    final currentState = state;
    List<Patient> currentPatients = [];
    PatientStats? currentStats;

    if (currentState is PatientLoaded) {
      currentPatients = currentState.patients;
      currentStats = currentState.stats;
    }

    emit(PatientOperationInProgress(
      patients: currentPatients,
      stats: currentStats,
      operation: 'Deleting patient...',
    ));

    try {
      await _repository.deletePatient(event.id);
      final updatedPatients =
          currentPatients.where((p) => p.id != event.id).toList();
      final stats = await _repository.getPatientStats();

      emit(PatientOperationSuccess(
        patients: updatedPatients,
        stats: stats,
        message: 'Patient deleted successfully',
      ));

      emit(PatientLoaded(
        patients: updatedPatients,
        stats: stats,
      ));
    } catch (e) {
      emit(PatientError(
        message: 'Failed to delete patient: $e',
        patients: currentPatients,
        stats: currentStats,
      ));
    }
  }

  Future<void> _onSearchPatients(
    SearchPatients event,
    Emitter<PatientState> emit,
  ) async {
    final currentState = state;
    PatientStats? currentStats;

    if (currentState is PatientLoaded) {
      currentStats = currentState.stats;
    }

    try {
      final patients = await _repository.getPatients(
        searchQuery: event.query,
      );
      emit(PatientLoaded(
        patients: patients,
        stats: currentStats,
        searchQuery: event.query,
      ));
    } catch (e) {
      emit(PatientError(message: 'Search failed: $e'));
    }
  }

  void _onClearError(
    ClearPatientError event,
    Emitter<PatientState> emit,
  ) {
    final currentState = state;
    if (currentState is PatientError) {
      emit(PatientLoaded(
        patients: currentState.patients,
        stats: currentState.stats,
      ));
    }
  }
}
