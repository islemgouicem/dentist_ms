import 'package:equatable/equatable.dart';
import 'package:dentist_ms/features/dashboard/models/treatments_chart_data.dart';

abstract class TreatmentsState extends Equatable {
  const TreatmentsState();

  @override
  List<Object?> get props => [];
}

class TreatmentsInitial extends TreatmentsState {}

class TreatmentsLoadInProgress extends TreatmentsState {}

class TreatmentsLoadSuccess extends TreatmentsState {
  final TreatmentsChartData chartData;

  const TreatmentsLoadSuccess(this.chartData);

  @override
  List<Object?> get props => [chartData];
}

class TreatmentsOperationFailure extends TreatmentsState {
  final String message;

  const TreatmentsOperationFailure(this. message);

  @override
  List<Object?> get props => [message];
}