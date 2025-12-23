import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dentist_ms/features/dashboard/bloc/revenue_event.dart';
import 'package:dentist_ms/features/dashboard/bloc/revenue_state.dart';
import 'package:dentist_ms/features/dashboard/repositories/revenue_repository.dart';

class RevenueBloc extends Bloc<RevenueEvent, RevenueState> {
  final RevenueRepository repository;

  RevenueBloc({required this.repository}) : super(RevenueInitial()) {
    on<LoadRevenueChart>(_onLoadRevenueChart);
    on<RefreshRevenueChart>(_onRefreshRevenueChart);
  }

  Future<void> _onLoadRevenueChart(
    LoadRevenueChart event,
    Emitter<RevenueState> emit,
  ) async {
    emit(RevenueLoadInProgress());
    try {
      final chartData = await repository.getRevenueChartData(year: event.year);
      emit(RevenueLoadSuccess(chartData));
    } catch (e) {
      emit(RevenueOperationFailure(e. toString()));
    }
  }

  Future<void> _onRefreshRevenueChart(
    RefreshRevenueChart event,
    Emitter<RevenueState> emit,
  ) async {
    emit(RevenueLoadInProgress());
    try {
      final currentYear = DateTime.now().year;
      final chartData = await repository. getRevenueChartData(year: currentYear);
      emit(RevenueLoadSuccess(chartData));
    } catch (e) {
      emit(RevenueOperationFailure(e. toString()));
    }
  }
}