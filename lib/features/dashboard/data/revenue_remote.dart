import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:dentist_ms/features/dashboard/models/revenue_chart_data.dart';

class RevenueRemoteDataSource {
  final SupabaseClient _client;

  RevenueRemoteDataSource({SupabaseClient? client})
      : _client = client ??  Supabase.instance.client;
  Future<RevenueChartData> getRevenueChartData({required int year}) async {
    try {
      final startDate = DateTime(year, 1, 1);
      final endDate = DateTime(year, 12, 31, 23, 59, 59);

      print('\n=== FETCHING DATA FOR YEAR $year ===');
      print('Date range: ${startDate.toIso8601String()} to ${endDate.toIso8601String()}');
      final paymentsResponse = await _client
          .from('payments')
          .select('payment_date, amount')
          .gte('payment_date', startDate.toIso8601String().split('T')[0])
          .lte('payment_date', endDate.toIso8601String().split('T')[0]);
      final expensesResponse = await _client
          .from('expenses')
          .select('expense_date, amount')
          .gte('expense_date', startDate.toIso8601String().split('T')[0])
          .lte('expense_date', endDate.toIso8601String().split('T')[0]);

      print('Payments response: ${paymentsResponse.length} records');
      print('Expenses response: ${expensesResponse.length} records');
      Map<int, double> paymentsByMonth = {};
      for (var payment in (paymentsResponse as List)) {
        if (payment['payment_date'] != null && payment['amount'] != null) {
          try {
            final date = DateTime.parse(payment['payment_date']. toString());
            final month = date.month;
            final amount = (payment['amount'] is num) 
                ? (payment['amount'] as num).toDouble() 
                : 0.0;
            
            paymentsByMonth[month] = (paymentsByMonth[month] ??  0.0) + amount;
          } catch (e) {
            print('Error parsing payment date: ${payment['payment_date']}, error: $e');
          }
        }
      }
      Map<int, double> expensesByMonth = {};
      for (var expense in (expensesResponse as List)) {
        if (expense['expense_date'] != null && expense['amount'] != null) {
          try {
            final date = DateTime.parse(expense['expense_date'].toString());
            final month = date.month;
            final amount = (expense['amount'] is num) 
                ? (expense['amount'] as num).toDouble() 
                : 0.0;
            
            expensesByMonth[month] = (expensesByMonth[month] ?? 0.0) + amount;
          } catch (e) {
            print('Error parsing expense date: ${expense['expense_date']}, error: $e');
          }
        }
      }

      print('\n=== MONTHLY BREAKDOWN ===');
      final monthNames = ['', 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
      List<MonthlyRevenue> monthlyData = [];
      double maxRevenue = 0.0;
      double maxProfit = 0.0;

      for (int month = 1; month <= 12; month++) {
        final revenue = paymentsByMonth[month] ?? 0.0;
        final expenses = expensesByMonth[month] ?? 0.0;
        final profit = revenue - expenses;

        print('${monthNames[month]. padRight(4)}: Revenue=${revenue.toStringAsFixed(2).padLeft(10)} DA | Expenses=${expenses.toStringAsFixed(2).padLeft(10)} DA | Profit=${profit.toStringAsFixed(2).padLeft(10)} DA');

        if (revenue > maxRevenue) maxRevenue = revenue;
        if (profit > maxProfit) maxProfit = profit;

        monthlyData.add(MonthlyRevenue(
          month: month,
          year: year,
          totalRevenue: revenue,
          netProfit: profit,
        ));
      }

      print('\n=== SUMMARY ===');
      print('Max Revenue: ${maxRevenue.toStringAsFixed(2)} DA');
      print('Max Profit:  ${maxProfit.toStringAsFixed(2)} DA');
      print('Total Payments: ${paymentsByMonth.values.fold<double>(0.0, (sum, val) => sum + val).toStringAsFixed(2)} DA');
      print('Total Expenses: ${expensesByMonth.values.fold<double>(0.0, (sum, val) => sum + val).toStringAsFixed(2)} DA');
      final topTreatments = await _fetchTopTreatments();

      return RevenueChartData(
        monthlyData: monthlyData,
        maxRevenue: maxRevenue,
        maxProfit: maxProfit,
        topTreatments: topTreatments,
      );
    } catch (e) {
      print('ERROR in getRevenueChartData:  $e');
      throw Exception('Failed to load revenue chart data:  $e');
    }
  }
  Future<List<TreatmentRevenue>> _fetchTopTreatments() async {
    try {
      print('\n=== FETCHING TOP TREATMENTS ===');
      final treatmentsResponse = await _client
          .from('treatments')
          .select('id, name');

      final treatments = treatmentsResponse as List;
      print('Found ${treatments.length} treatments in database');
      final patientTreatmentsResponse = await _client
          .from('patient_treatments')
          .select('treatment_id, price');

      final patientTreatments = patientTreatmentsResponse as List;
      print('Found ${patientTreatments.length} patient_treatments records');
      double totalRevenue = 0.0;
      for (var pt in patientTreatments) {
        if (pt['price'] != null) {
          final price = (pt['price'] is num) 
              ? (pt['price'] as num).toDouble() 
              : 0.0;
          totalRevenue += price;
        }
      }

      print('Total revenue from all patient_treatments: ${totalRevenue. toStringAsFixed(2)} DA');
      Map<int, Map<String, dynamic>> treatmentMetrics = {};
      for (var treatment in treatments) {
        final treatmentId = treatment['id'] as int;
        final treatmentName = treatment['name'] as String?  ?? 'Unknown';

        treatmentMetrics[treatmentId] = {
          'name': treatmentName,
          'totalAmount': 0.0,
          'count': 0,
          'progress': 0.0,
        };
      }
      for (var pt in patientTreatments) {
        final treatmentId = pt['treatment_id'] as int? ;
        if (treatmentId != null && treatmentMetrics.containsKey(treatmentId)) {
          final price = (pt['price'] is num) 
              ? (pt['price'] as num).toDouble() 
              : 0.0;
          
          treatmentMetrics[treatmentId]!['totalAmount'] += price;
          treatmentMetrics[treatmentId]!['count'] += 1;
        }
      }
      for (var entry in treatmentMetrics.entries) {
        final totalAmount = entry.value['totalAmount'] as double;
        final progress = totalRevenue > 0 ? totalAmount / totalRevenue : 0.0;
        entry.value['progress'] = progress;
        
        print('Treatment: ${entry. value['name']}, Amount: ${totalAmount.toStringAsFixed(2)} DA, Count: ${entry.value['count']}, Progress: ${(progress * 100).toStringAsFixed(1)}%');
      }
      List<TreatmentRevenue> treatmentRevenueList = treatmentMetrics.entries
          .map((entry) => TreatmentRevenue(
                treatmentId: entry.key,
                treatmentName: entry. value['name'],
                totalAmount: entry.value['totalAmount'],
                count: entry.value['count'],
                progress: entry. value['progress'],
              ))
          .toList();
      treatmentRevenueList.sort((a, b) => b.totalAmount.compareTo(a.totalAmount));

      print('\nTop 5 treatments (sorted by revenue):');
      for (var t in treatmentRevenueList. take(5)) {
        print('  - ${t.treatmentName}: ${t.totalAmount.toStringAsFixed(2)} DA (${t.count} times)');
      }
      return treatmentRevenueList.take(5).toList();
    } catch (e) {
      print('ERROR in _fetchTopTreatments: $e');
      throw Exception('Failed to load top treatments: $e');
    }
  }
}