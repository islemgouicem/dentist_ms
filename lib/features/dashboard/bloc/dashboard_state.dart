import 'package:equatable/equatable.dart';
import 'package:dentist_ms/features/dashboard/models/dashboard_metrics.dart';

abstract class DashboardState extends Equatable {
  const DashboardState();

  @override
  List<Object?> get props => [];
}

class DashboardInitial extends DashboardState {}

class DashboardLoadInProgress extends DashboardState {}

class DashboardLoadSuccess extends DashboardState {
  final DashboardMetrics metrics;

  const DashboardLoadSuccess(this.metrics);

  @override
  List<Object?> get props => [metrics];
}

class DashboardOperationFailure extends DashboardState {
  final String message;

  const DashboardOperationFailure(this.message);

  @override
  List<Object?> get props => [message];
}