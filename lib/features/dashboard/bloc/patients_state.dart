import 'package:equatable/equatable.dart';
import 'package:dentist_ms/features/dashboard/models/patients_chart_data.dart';

abstract class PatientsState extends Equatable {
  const PatientsState();

  @override
  List<Object? > get props => [];
}

class PatientsInitial extends PatientsState {}

class PatientsLoadInProgress extends PatientsState {}

class PatientsLoadSuccess extends PatientsState {
  final PatientsChartData chartData;

  const PatientsLoadSuccess(this.chartData);

  @override
  List<Object?> get props => [chartData];
}

class PatientsOperationFailure extends PatientsState {
  final String message;

  const PatientsOperationFailure(this.message);

  @override
  List<Object?> get props => [message];
}