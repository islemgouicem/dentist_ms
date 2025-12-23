import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dentist_ms/features/dashboard/bloc/treatments_event.dart';
import 'package:dentist_ms/features/dashboard/bloc/treatments_state.dart';
import 'package:dentist_ms/features/dashboard/repositories/treatments_repository.dart';

class TreatmentsBloc extends Bloc<TreatmentsEvent, TreatmentsState> {
  final TreatmentsRepository repository;

  TreatmentsBloc({required this.repository}) : super(TreatmentsInitial()) {
    on<LoadTreatmentsChart>(_onLoadTreatmentsChart);
    on<RefreshTreatmentsChart>(_onRefreshTreatmentsChart);
  }

  Future<void> _onLoadTreatmentsChart(
    LoadTreatmentsChart event,
    Emitter<TreatmentsState> emit,
  ) async {
    emit(TreatmentsLoadInProgress());
    try {
      final chartData = await repository.getTreatmentsChartData();
      emit(TreatmentsLoadSuccess(chartData));
    } catch (e) {
      emit(TreatmentsOperationFailure(e.toString()));
    }
  }

  Future<void> _onRefreshTreatmentsChart(
    RefreshTreatmentsChart event,
    Emitter<TreatmentsState> emit,
  ) async {
    emit(TreatmentsLoadInProgress());
    try {
      final chartData = await repository.getTreatmentsChartData();
      emit(TreatmentsLoadSuccess(chartData));
    } catch (e) {
      emit(TreatmentsOperationFailure(e.toString()));
    }
  }
}