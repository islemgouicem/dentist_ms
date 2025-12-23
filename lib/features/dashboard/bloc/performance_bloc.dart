import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dentist_ms/features/dashboard/bloc/performance_event.dart';
import 'package:dentist_ms/features/dashboard/bloc/performance_state.dart';
import 'package:dentist_ms/features/dashboard/repositories/performance_repository.dart';

class PerformanceBloc extends Bloc<PerformanceEvent, PerformanceState> {
  final PerformanceRepository repository;

  PerformanceBloc({required this.repository}) : super(PerformanceInitial()) {
    on<LoadPerformanceChart>(_onLoadPerformanceChart);
    on<RefreshPerformanceChart>(_onRefreshPerformanceChart);
  }

  Future<void> _onLoadPerformanceChart(
    LoadPerformanceChart event,
    Emitter<PerformanceState> emit,
  ) async {
    emit(PerformanceLoadInProgress());
    try {
      final chartData = await repository.getPerformanceChartData(year: event.year);
      emit(PerformanceLoadSuccess(chartData));
    } catch (e) {
      emit(PerformanceOperationFailure(e.toString()));
    }
  }

  Future<void> _onRefreshPerformanceChart(
    RefreshPerformanceChart event,
    Emitter<PerformanceState> emit,
  ) async {
    emit(PerformanceLoadInProgress());
    try {
      final currentYear = DateTime.now().year;
      final chartData = await repository. getPerformanceChartData(year: currentYear);
      emit(PerformanceLoadSuccess(chartData));
    } catch (e) {
      emit(PerformanceOperationFailure(e.toString()));
    }
  }
}