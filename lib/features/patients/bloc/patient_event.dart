import 'package:equatable/equatable.dart';
import 'package:dentist_ms/features/patients/models/patient.dart';

abstract class PatientEvent extends Equatable {
  const PatientEvent();

  @override
  List<Object?> get props => [];
}

class LoadPatients extends PatientEvent {}

class AddPatient extends PatientEvent {
  final Patient patient;
  const AddPatient(this.patient);

  @override
  List<Object?> get props => [patient];
}

class UpdatePatient extends PatientEvent {
  final Patient patient;
  const UpdatePatient(this.patient);

  @override
  List<Object?> get props => [patient];
}

class DeletePatient extends PatientEvent {
  final int patientId;
  const DeletePatient(this.patientId);

  @override
  List<Object?> get props => [patientId];
}