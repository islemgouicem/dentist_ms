import 'package:equatable/equatable.dart';

abstract class RevenueEvent extends Equatable {
  const RevenueEvent();

  @override
  List<Object?> get props => [];
}

class LoadRevenueChart extends RevenueEvent {
  final int year;
  
  const LoadRevenueChart({required this.year});

  @override
  List<Object?> get props => [year];
}

class RefreshRevenueChart extends RevenueEvent {}