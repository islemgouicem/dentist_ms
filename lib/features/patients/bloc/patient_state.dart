import 'package:equatable/equatable.dart';
import 'package:dentist_ms/features/patients/models/patient.dart';

abstract class PatientState extends Equatable {
  const PatientState();
  
  @override
  List<Object?> get props => [];
}

class PatientsInitial extends PatientState {}

class PatientsLoadInProgress extends PatientState {}

class PatientsLoadSuccess extends PatientState {
  final List<Patient> patients;

  const PatientsLoadSuccess(this.patients);

  @override
  List<Object?> get props => [patients];
}

class PatientsOperationFailure extends PatientState {
  final String message;

  const PatientsOperationFailure(this.message);

  @override
  List<Object?> get props => [message];
}