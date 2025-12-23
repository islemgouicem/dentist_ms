import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dentist_ms/features/dashboard/bloc/patients_event.dart';
import 'package:dentist_ms/features/dashboard/bloc/patients_state.dart';
import 'package:dentist_ms/features/dashboard/repositories/patients_repository.dart';

class PatientsBloc extends Bloc<PatientsEvent, PatientsState> {
  final PatientsRepository repository;

  PatientsBloc({required this.repository}) : super(PatientsInitial()) {
    on<LoadPatientsChart>(_onLoadPatientsChart);
    on<RefreshPatientsChart>(_onRefreshPatientsChart);
  }

  Future<void> _onLoadPatientsChart(
    LoadPatientsChart event,
    Emitter<PatientsState> emit,
  ) async {
    emit(PatientsLoadInProgress());
    try {
      final chartData = await repository.getPatientsChartData(year: event.year);
      emit(PatientsLoadSuccess(chartData));
    } catch (e) {
      emit(PatientsOperationFailure(e. toString()));
    }
  }

  Future<void> _onRefreshPatientsChart(
    RefreshPatientsChart event,
    Emitter<PatientsState> emit,
  ) async {
    emit(PatientsLoadInProgress());
    try {
      final currentYear = DateTime.now().year;
      final chartData = await repository. getPatientsChartData(year: currentYear);
      emit(PatientsLoadSuccess(chartData));
    } catch (e) {
      emit(PatientsOperationFailure(e.toString()));
    }
  }
}