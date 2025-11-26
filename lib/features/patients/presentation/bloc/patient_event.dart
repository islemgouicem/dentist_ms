import 'package:equatable/equatable.dart';
import 'package:dentist_ms/features/patients/data/models/patient_model.dart';

/// Base class for all patient events
abstract class PatientEvent extends Equatable {
  const PatientEvent();

  @override
  List<Object?> get props => [];
}

/// Event to load all patients
class LoadPatients extends PatientEvent {
  final String? searchQuery;
  final String? status;

  const LoadPatients({this.searchQuery, this.status});

  @override
  List<Object?> get props => [searchQuery, status];
}

/// Event to load patient statistics
class LoadPatientStats extends PatientEvent {
  const LoadPatientStats();
}

/// Event to add a new patient
class AddPatient extends PatientEvent {
  final Patient patient;

  const AddPatient(this.patient);

  @override
  List<Object?> get props => [patient];
}

/// Event to update an existing patient
class UpdatePatient extends PatientEvent {
  final Patient patient;

  const UpdatePatient(this.patient);

  @override
  List<Object?> get props => [patient];
}

/// Event to delete a patient
class DeletePatient extends PatientEvent {
  final String id;

  const DeletePatient(this.id);

  @override
  List<Object?> get props => [id];
}

/// Event to search patients
class SearchPatients extends PatientEvent {
  final String query;

  const SearchPatients(this.query);

  @override
  List<Object?> get props => [query];
}

/// Event to clear any error state
class ClearPatientError extends PatientEvent {
  const ClearPatientError();
}
