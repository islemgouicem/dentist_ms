import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dentist_ms/features/patients/bloc/patient_event.dart';
import 'package:dentist_ms/features/patients/bloc/patient_state.dart';
import 'package:dentist_ms/features/patients/repositories/patient_repository.dart';

class PatientBloc extends Bloc<PatientEvent, PatientState> {
  final PatientRepository repository;

  PatientBloc({required this.repository}) : super(PatientsInitial()) {
    on<LoadPatients>(_onLoadPatients);
    on<AddPatient>(_onAddPatient);
    on<UpdatePatient>(_onUpdatePatient);
    on<DeletePatient>(_onDeletePatient);
  }

  Future<void> _onLoadPatients(
    LoadPatients event,
    Emitter<PatientState> emit,
  ) async {
    emit(PatientsLoadInProgress());
    try {
      final patients = await repository.getAllPatients();
      emit(PatientsLoadSuccess(patients));
    } catch (e) {
      emit(PatientsOperationFailure(e.toString()));
    }
  }

  Future<void> _onAddPatient(
    AddPatient event,
    Emitter<PatientState> emit,
  ) async {
    // comments for me :)
    // Optimistic UI update or show loading could go here.
    // For simplicity, we keep the previous state visually or show loading if needed.
    // Ideally, we want to stay on the list or show a "saving" indicator.
    
    // NOTE: In a real app, you might not want to set LoadInProgress here 
    // because it wipes the list from the UI. 
    // But to refresh the list reliably after add:
    emit(PatientsLoadInProgress()); 
    
    try {
      await repository.createPatient(event.patient);
      // Reload the list to get the new ID and sorted order from DB
      add(LoadPatients()); 
    } catch (e) {
      emit(PatientsOperationFailure(e.toString()));
    }
  }

  Future<void> _onUpdatePatient(
    UpdatePatient event,
    Emitter<PatientState> emit,
  ) async {
    emit(PatientsLoadInProgress());
    try {
      await repository.updatePatient(event.patient);
      add(LoadPatients());
    } catch (e) {
      emit(PatientsOperationFailure(e.toString()));
    }
  }

  Future<void> _onDeletePatient(
    DeletePatient event,
    Emitter<PatientState> emit,
  ) async {
    try {
      await repository.deletePatient(event.patientId);
      add(LoadPatients());
    } catch (e) {
      emit(PatientsOperationFailure(e.toString()));
    }
  }
}