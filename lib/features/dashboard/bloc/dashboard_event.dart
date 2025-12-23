import 'package:equatable/equatable.dart';

abstract class DashboardEvent extends Equatable {
  const DashboardEvent();

  @override
  List<Object? > get props => [];
}

class LoadDashboardMetrics extends DashboardEvent {
  final String dateRange;

  const LoadDashboardMetrics({required this.dateRange});

  @override
  List<Object?> get props => [dateRange];
}

class RefreshDashboardMetrics extends DashboardEvent {
  final String dateRange;

  const RefreshDashboardMetrics({this.dateRange = 'This Year'});

  @override
  List<Object?> get props => [dateRange];
}