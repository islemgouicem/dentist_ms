import 'package:equatable/equatable.dart';
import 'package:dentist_ms/features/dashboard/models/revenue_chart_data.dart';

abstract class RevenueState extends Equatable {
  const RevenueState();

  @override
  List<Object?> get props => [];
}

class RevenueInitial extends RevenueState {}

class RevenueLoadInProgress extends RevenueState {}

class RevenueLoadSuccess extends RevenueState {
  final RevenueChartData chartData;

  const RevenueLoadSuccess(this.chartData);

  @override
  List<Object?> get props => [chartData];
}

class RevenueOperationFailure extends RevenueState {
  final String message;

  const RevenueOperationFailure(this.message);

  @override
  List<Object?> get props => [message];
}