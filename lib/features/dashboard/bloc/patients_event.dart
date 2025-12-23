import 'package:equatable/equatable.dart';

abstract class PatientsEvent extends Equatable {
  const PatientsEvent();

  @override
  List<Object?> get props => [];
}

class LoadPatientsChart extends PatientsEvent {
  final int year;
  
  const LoadPatientsChart({required this.year});

  @override
  List<Object?> get props => [year];
}

class RefreshPatientsChart extends PatientsEvent {}