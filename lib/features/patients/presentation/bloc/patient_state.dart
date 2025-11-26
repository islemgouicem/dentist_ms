import 'package:equatable/equatable.dart';
import 'package:dentist_ms/features/patients/data/models/patient_model.dart';
import 'package:dentist_ms/features/patients/data/repositories/patient_repository.dart';

/// Base class for all patient states
abstract class PatientState extends Equatable {
  const PatientState();

  @override
  List<Object?> get props => [];
}

/// Initial state before any data is loaded
class PatientInitial extends PatientState {
  const PatientInitial();
}

/// State when patients are being loaded
class PatientLoading extends PatientState {
  const PatientLoading();
}

/// State when patients are successfully loaded
class PatientLoaded extends PatientState {
  final List<Patient> patients;
  final PatientStats? stats;
  final String? searchQuery;

  const PatientLoaded({
    required this.patients,
    this.stats,
    this.searchQuery,
  });

  @override
  List<Object?> get props => [patients, stats, searchQuery];

  PatientLoaded copyWith({
    List<Patient>? patients,
    PatientStats? stats,
    String? searchQuery,
  }) {
    return PatientLoaded(
      patients: patients ?? this.patients,
      stats: stats ?? this.stats,
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }
}

/// State when a patient operation is in progress
class PatientOperationInProgress extends PatientState {
  final List<Patient> patients;
  final PatientStats? stats;
  final String operation;

  const PatientOperationInProgress({
    required this.patients,
    this.stats,
    required this.operation,
  });

  @override
  List<Object?> get props => [patients, stats, operation];
}

/// State when a patient operation is successful
class PatientOperationSuccess extends PatientState {
  final List<Patient> patients;
  final PatientStats? stats;
  final String message;

  const PatientOperationSuccess({
    required this.patients,
    this.stats,
    required this.message,
  });

  @override
  List<Object?> get props => [patients, stats, message];
}

/// State when there's an error
class PatientError extends PatientState {
  final String message;
  final List<Patient> patients;
  final PatientStats? stats;

  const PatientError({
    required this.message,
    this.patients = const [],
    this.stats,
  });

  @override
  List<Object?> get props => [message, patients, stats];
}
