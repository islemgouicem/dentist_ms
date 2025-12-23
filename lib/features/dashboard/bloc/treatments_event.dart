import 'package:equatable/equatable.dart';

abstract class TreatmentsEvent extends Equatable {
  const TreatmentsEvent();

  @override
  List<Object?> get props => [];
}

class LoadTreatmentsChart extends TreatmentsEvent {}

class RefreshTreatmentsChart extends TreatmentsEvent {}