import 'package:equatable/equatable.dart';

class MonthlyPatientCount extends Equatable {
  final int month;  
  final int year;
  final int cumulativeCount; 
  final int newPatients;  

  const MonthlyPatientCount({
    required this.month,
    required this.year,
    required this.cumulativeCount,
    required this.newPatients,
  });

  @override
  List<Object? > get props => [month, year, cumulativeCount, newPatients];
}

class PatientsChartData extends Equatable {
  final List<MonthlyPatientCount> monthlyData;
  final int maxPatientCount;

  const PatientsChartData({
    required this.monthlyData,
    required this.maxPatientCount,
  });
  int get yAxisMax {
    final max = maxPatientCount;
    if (max == 0) return 100;  
    if (max <= 50) {
      return ((max / 10).ceil() * 10);
    } else if (max <= 100) {
      return ((max / 20).ceil() * 20);
    } else if (max <= 500) {
      return ((max / 100).ceil() * 100);
    } else if (max <= 1000) {
      return ((max / 200).ceil() * 200);
    } else if (max <= 5000) {
      return ((max / 1000).ceil() * 1000);
    } else if (max <= 10000) {
      return ((max / 2000).ceil() * 2000);
    } else if (max <= 30000) {
      return ((max / 5000).ceil() * 5000);
    } else {
      return ((max / 10000).ceil() * 10000);
    }
  }
  double get yAxisInterval => yAxisMax / 5;

  @override
  List<Object? > get props => [monthlyData, maxPatientCount];
}