import 'package:equatable/equatable.dart';
import 'package:dentist_ms/features/billing/models/treatment.dart';

abstract class TreatmentEvent extends Equatable {
  const TreatmentEvent();

  @override
  List<Object?> get props => [];
}

class LoadTreatments extends TreatmentEvent {}

class AddTreatment extends TreatmentEvent {
  final Treatment treatment;

  const AddTreatment(this.treatment);

  @override
  List<Object?> get props => [treatment];
}

class UpdateTreatment extends TreatmentEvent {
  final Treatment treatment;

  const UpdateTreatment(this.treatment);

  @override
  List<Object?> get props => [treatment];
}

class DeleteTreatment extends TreatmentEvent {
  final int id;

  const DeleteTreatment(this.id);

  @override
  List<Object?> get props => [id];
}
