import 'package:equatable/equatable.dart';

class MonthlyAppointmentStatus extends Equatable {
  final int month;  
  final int year;
  final int completedCount;
  final int confirmedCount;
  final int cancelledCount;
  final int noShowCount;
  final int totalCount;

  const MonthlyAppointmentStatus({
    required this.month,
    required this.year,
    required this.completedCount,
    required this.confirmedCount,
    required this.cancelledCount,
    required this.noShowCount,
    required this.totalCount,
  });

  double get completedPercentage => 
      totalCount > 0 ? (completedCount / totalCount) * 100 : 0.0;
  
  double get confirmedPercentage => 
      totalCount > 0 ? (confirmedCount / totalCount) * 100 : 0.0;
  
  double get cancelledPercentage => 
      totalCount > 0 ? (cancelledCount / totalCount) * 100 : 0.0;
  
  double get noShowPercentage => 
      totalCount > 0 ? (noShowCount / totalCount) * 100 : 0.0;

  @override
  List<Object?> get props => [
        month,
        year,
        completedCount,
        confirmedCount,
        cancelledCount,
        noShowCount,
        totalCount,
      ];
}

class DoctorPerformance extends Equatable {
  final String doctorId;
  final String doctorName;
  final int completedTreatments;
  final double progress; // 0.0 to 1.0

  const DoctorPerformance({
    required this.doctorId,
    required this.doctorName,
    required this. completedTreatments,
    required this.progress,
  });

  @override
  List<Object?> get props => [doctorId, doctorName, completedTreatments, progress];
}

class PerformanceChartData extends Equatable {
  final List<MonthlyAppointmentStatus> monthlyData;
  final int totalAppointments;
  final List<DoctorPerformance> doctorPerformance;
  final int maxDoctorTreatments;

  const PerformanceChartData({
    required this.monthlyData,
    required this.totalAppointments,
    required this.doctorPerformance,
    required this.maxDoctorTreatments,
  });

  @override
  List<Object? > get props => [monthlyData, totalAppointments, doctorPerformance, maxDoctorTreatments];
}