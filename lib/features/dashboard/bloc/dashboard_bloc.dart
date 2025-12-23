import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dentist_ms/features/dashboard/bloc/dashboard_event.dart';
import 'package:dentist_ms/features/dashboard/bloc/dashboard_state.dart';
import 'package:dentist_ms/features/dashboard/repositories/dashboard_repository.dart';

class DashboardBloc extends Bloc<DashboardEvent, DashboardState> {
  final DashboardRepository repository;

  DashboardBloc({required this.repository}) : super(DashboardInitial()) {
    on<LoadDashboardMetrics>(_onLoadDashboardMetrics);
    on<RefreshDashboardMetrics>(_onRefreshDashboardMetrics);
  }

  Future<void> _onLoadDashboardMetrics(
    LoadDashboardMetrics event,
    Emitter<DashboardState> emit,
  ) async {
    emit(DashboardLoadInProgress());
    try {
      final metrics = await repository.getDashboardMetrics(
        dateRange: event.dateRange,
      );
      emit(DashboardLoadSuccess(metrics));
    } catch (e) {
      emit(DashboardOperationFailure(e.toString()));
    }
  }

  Future<void> _onRefreshDashboardMetrics(
    RefreshDashboardMetrics event,
    Emitter<DashboardState> emit,
  ) async {
    emit(DashboardLoadInProgress());
    try {
      final metrics = await repository.getDashboardMetrics(
        dateRange: event.dateRange,
      );
      emit(DashboardLoadSuccess(metrics));
    } catch (e) {
      emit(DashboardOperationFailure(e.toString()));
    }
  }
}