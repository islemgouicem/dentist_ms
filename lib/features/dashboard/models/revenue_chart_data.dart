import 'package:equatable/equatable.dart';

class MonthlyRevenue extends Equatable {
  final int month;  
  final int year;
  final double totalRevenue;  
  final double netProfit;  

  const MonthlyRevenue({
    required this.month,
    required this.year,
    required this.totalRevenue,
    required this.netProfit,
  });

  @override
  List<Object?> get props => [month, year, totalRevenue, netProfit];
}

class TreatmentRevenue extends Equatable {
  final int treatmentId;
  final String treatmentName;
  final double totalAmount;
  final int count;
  final double progress;  

  const TreatmentRevenue({
    required this.treatmentId,
    required this. treatmentName,
    required this.totalAmount,
    required this.count,
    required this. progress,
  });

  @override
  List<Object?> get props => [treatmentId, treatmentName, totalAmount, count, progress];
}

class RevenueChartData extends Equatable {
  final List<MonthlyRevenue> monthlyData;
  final double maxRevenue;
  final double maxProfit;
  final List<TreatmentRevenue> topTreatments;

  const RevenueChartData({
    required this.monthlyData,
    required this.maxRevenue,
    required this.maxProfit,
    required this. topTreatments,
  });

  double get maxYValue => maxRevenue > maxProfit ? maxRevenue :  maxProfit;
  double get yAxisMax {
    final max = maxYValue;
    if (max == 0) return 10000;  
    if (max <= 10000) {
      return ((max / 2000).ceil() * 2000).toDouble();
    } else if (max <= 50000) {
      return ((max / 10000).ceil() * 10000).toDouble();
    } else if (max <= 100000) {
      return ((max / 20000).ceil() * 20000).toDouble();
    } else if (max <= 500000) {
      return ((max / 100000).ceil() * 100000).toDouble();
    } else if (max <= 1000000) {
      return ((max / 200000).ceil() * 200000).toDouble();
    } else if (max <= 5000000) {
      return ((max / 1000000).ceil() * 1000000).toDouble();
    } else {
      return ((max / 2000000).ceil() * 2000000).toDouble();
    }
  }
  double get yAxisInterval => yAxisMax / 5;

  @override
  List<Object?> get props => [monthlyData, maxRevenue, maxProfit, topTreatments];
}