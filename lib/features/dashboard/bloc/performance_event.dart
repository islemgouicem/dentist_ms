import 'package:equatable/equatable.dart';

abstract class PerformanceEvent extends Equatable {
  const PerformanceEvent();

  @override
  List<Object?> get props => [];
}

class LoadPerformanceChart extends PerformanceEvent {
  final int year;
  
  const LoadPerformanceChart({required this.year});

  @override
  List<Object?> get props => [year];
}

class RefreshPerformanceChart extends PerformanceEvent {}