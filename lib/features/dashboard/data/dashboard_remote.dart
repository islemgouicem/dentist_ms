import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:dentist_ms/features/dashboard/models/dashboard_metrics.dart';

class DashboardRemoteDataSource {
  final SupabaseClient _client;

  DashboardRemoteDataSource({SupabaseClient? client})
      : _client = client ??  Supabase.instance.client;

  Future<DashboardMetrics> getDashboardMetrics({required String dateRange}) async {
    try {
      print('\n=== FETCHING DASHBOARD METRICS FOR:  $dateRange ===');

       final now = DateTime.now();
      DateTime startDate;
      DateTime endDate = now;

      switch (dateRange) {
        case 'Today':
          startDate = DateTime(now.year, now.month, now.day, 0, 0, 0);
          endDate = DateTime(now.year, now.month, now.day, 23, 59, 59);
          break;
        case 'This Month':
          startDate = DateTime(now.year, now.month, 1, 0, 0, 0);
          endDate = DateTime(now.year, now.month + 1, 0, 23, 59, 59);
          break;
        case 'This Quarter':
          final currentQuarter = ((now.month - 1) ~/ 3);
          startDate = DateTime(now.year, currentQuarter * 3 + 1, 1, 0, 0, 0);
          final endMonth = (currentQuarter + 1) * 3;
          endDate = DateTime(now.year, endMonth + 1, 0, 23, 59, 59);
          break;
        case 'This Year':
          startDate = DateTime(now.year, 1, 1, 0, 0, 0);
          endDate = DateTime(now.year, 12, 31, 23, 59, 59);
          break;
        case 'Last Year':
          startDate = DateTime(now.year - 1, 1, 1, 0, 0, 0);
          endDate = DateTime(now.year - 1, 12, 31, 23, 59, 59);
          break;
        default:
          startDate = DateTime(now.year, 1, 1, 0, 0, 0);
          endDate = DateTime(now. year, 12, 31, 23, 59, 59);
      }

      print('Date Range: ${startDate.toIso8601String()} to ${endDate.toIso8601String()}');

       final paymentsResponse = await _client
          .from('payments')
          .select('amount, payment_date')
          .gte('payment_date', startDate.toIso8601String())
          .lte('payment_date', endDate.toIso8601String());

      final payments = paymentsResponse as List;
      final totalPayments = payments.fold<double>(
        0.0,
        (sum, payment) => sum + ((payment['amount'] as num?)?.toDouble() ?? 0.0),
      );

      print('Total Payments: $totalPayments DA');

      final expensesResponse = await _client
          . from('expenses')
          .select('amount, expense_date')
          .gte('expense_date', startDate.toIso8601String())
          .lte('expense_date', endDate. toIso8601String());

      final expenses = expensesResponse as List;
      final totalExpenses = expenses.fold<double>(
        0.0,
        (sum, expense) => sum + ((expense['amount'] as num?)?.toDouble() ?? 0.0),
      );

      print('Total Expenses: $totalExpenses DA');

      final totalRevenue = totalPayments - totalExpenses;

      print('Net Revenue (Payments - Expenses): $totalRevenue DA');

      final patientsResponse = await _client
          .from('patients')
          .select('id, created_at')
          .gte('created_at', startDate.toIso8601String())
          .lte('created_at', endDate.toIso8601String());

      final patients = patientsResponse as List;
      final totalPatients = patients.length;

      print('New Patients in range: $totalPatients');

      final appointmentsResponse = await _client
          . from('appointments')
          .select('id, status, start_datetime')
          .gte('start_datetime', startDate.toIso8601String())
          .lte('start_datetime', endDate.toIso8601String())
          .eq('status', 'completed');

      final appointments = appointmentsResponse as List;
      final completedAppointments = appointments.length;

      print('Completed Appointments:  $completedAppointments');

      final averageRevenuePerPatient = totalPatients > 0 
          ? totalRevenue / totalPatients 
          : 0.0;

      print('Average Revenue Per Patient: ${averageRevenuePerPatient.toStringAsFixed(2)} DA');

      String? revenueTrend;
      String? patientsTrend;
      String? appointmentsTrend;

      final periodDuration = endDate.difference(startDate);
      final previousEndDate = startDate.subtract(const Duration(seconds: 1));
      final previousStartDate = previousEndDate.subtract(periodDuration);

      print('Previous period: ${previousStartDate.toIso8601String()} to ${previousEndDate.toIso8601String()}');

      final previousPaymentsResponse = await _client
          .from('payments')
          .select('amount')
          .gte('payment_date', previousStartDate.toIso8601String())
          .lte('payment_date', previousEndDate.toIso8601String());

      final previousPayments = previousPaymentsResponse as List;
      final previousTotalPayments = previousPayments. fold<double>(
        0.0,
        (sum, payment) => sum + ((payment['amount'] as num?)?.toDouble() ?? 0.0),
      );

      final previousExpensesResponse = await _client
          .from('expenses')
          .select('amount')
          .gte('expense_date', previousStartDate. toIso8601String())
          .lte('expense_date', previousEndDate.toIso8601String());

      final previousExpenses = previousExpensesResponse as List;
      final previousTotalExpenses = previousExpenses. fold<double>(
        0.0,
        (sum, expense) => sum + ((expense['amount'] as num?)?.toDouble() ?? 0.0),
      );

      final previousRevenue = previousTotalPayments - previousTotalExpenses;

      print('Previous Revenue: $previousRevenue DA');

      if (previousRevenue > 0) {
        final revenueChange = ((totalRevenue - previousRevenue) / previousRevenue * 100);
        revenueTrend = revenueChange >= 0 
            ? '+${revenueChange.toStringAsFixed(0)}% par rapport à la période précédente'
            : '${revenueChange.toStringAsFixed(0)}% par rapport à la période précédente';
      } else if (totalRevenue > 0) {
        revenueTrend = 'Première période avec revenus';
      }

      final previousPatientsResponse = await _client
          .from('patients')
          .select('id')
          .gte('created_at', previousStartDate. toIso8601String())
          .lte('created_at', previousEndDate.toIso8601String());

      final previousPatients = previousPatientsResponse as List;
      final previousPatientCount = previousPatients.length;

      print('Previous Patients: $previousPatientCount');

      if (previousPatientCount > 0) {
        final patientChange = ((totalPatients - previousPatientCount) / previousPatientCount * 100);
        patientsTrend = patientChange >= 0 
            ? '+${patientChange.toStringAsFixed(0)}% par rapport à la période précédente'
            : '${patientChange.toStringAsFixed(0)}% par rapport à la période précédente';
      } else if (totalPatients > 0) {
        patientsTrend = 'Première période avec patients';
      }

      final previousAppointmentsResponse = await _client
          .from('appointments')
          .select('id')
          .gte('start_datetime', previousStartDate.toIso8601String())
          .lte('start_datetime', previousEndDate.toIso8601String())
          .eq('status', 'completed');

      final previousAppointments = previousAppointmentsResponse as List;
      final previousAppointmentCount = previousAppointments.length;

      print('Previous Appointments: $previousAppointmentCount');

      if (previousAppointmentCount > 0) {
        final appointmentChange = ((completedAppointments - previousAppointmentCount) / previousAppointmentCount * 100);
        appointmentsTrend = appointmentChange >= 0 
            ? '+${appointmentChange.toStringAsFixed(0)}% par rapport à la période précédente'
            : '${appointmentChange.toStringAsFixed(0)}% par rapport à la période précédente';
      } else if (completedAppointments > 0) {
        appointmentsTrend = 'Première période avec rendez-vous';
      }

      print('=== METRICS CALCULATED SUCCESSFULLY ===\n');

      return DashboardMetrics(
        totalRevenue: totalRevenue,
        totalPatients: totalPatients,
        completedAppointments: completedAppointments,
        totalAppointments: completedAppointments,
        averageRevenuePerPatient: averageRevenuePerPatient,
        revenueTrend: revenueTrend,
        patientsTrend: patientsTrend,
        appointmentsTrend:  appointmentsTrend,
      );
    } catch (e, stackTrace) {
      print('ERROR in getDashboardMetrics:  $e');
      print('Stack trace:  $stackTrace');
      throw Exception('Failed to load dashboard metrics: $e');
    }
  }
}