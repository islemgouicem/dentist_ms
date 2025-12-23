import 'package:equatable/equatable.dart';
import 'package:dentist_ms/features/billing/models/treatment.dart';

abstract class TreatmentState extends Equatable {
  const TreatmentState();

  @override
  List<Object?> get props => [];
}

class TreatmentsInitial extends TreatmentState {}

class TreatmentsLoadInProgress extends TreatmentState {}

class TreatmentsLoadSuccess extends TreatmentState {
  final List<Treatment> treatments;

  const TreatmentsLoadSuccess(this.treatments);

  @override
  List<Object?> get props => [treatments];
}

class TreatmentsOperationFailure extends TreatmentState {
  final String message;

  const TreatmentsOperationFailure(this.message);

  @override
  List<Object?> get props => [message];
}
