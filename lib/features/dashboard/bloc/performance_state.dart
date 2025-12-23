import 'package:equatable/equatable.dart';
import 'package:dentist_ms/features/dashboard/models/performance_chart_data.dart';

abstract class PerformanceState extends Equatable {
  const PerformanceState();

  @override
  List<Object?> get props => [];
}

class PerformanceInitial extends PerformanceState {}

class PerformanceLoadInProgress extends PerformanceState {}

class PerformanceLoadSuccess extends PerformanceState {
  final PerformanceChartData chartData;

  const PerformanceLoadSuccess(this.chartData);

  @override
  List<Object?> get props => [chartData];
}

class PerformanceOperationFailure extends PerformanceState {
  final String message;

  const PerformanceOperationFailure(this.message);

  @override
  List<Object?> get props => [message];
}