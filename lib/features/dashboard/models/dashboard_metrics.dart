import 'package:equatable/equatable.dart';

class DashboardMetrics extends Equatable {
  final double totalRevenue;
  final int totalPatients;
  final int completedAppointments;
  final int totalAppointments;  
  final double averageRevenuePerPatient;
  final String?  revenueTrend;
  final String? patientsTrend;
  final String? appointmentsTrend;

  const DashboardMetrics({
    required this.totalRevenue,
    required this.totalPatients,
    required this.completedAppointments,
    int? totalAppointments,  
    required this.averageRevenuePerPatient,
    this.revenueTrend,
    this.patientsTrend,
    this.appointmentsTrend,
  }) : totalAppointments = totalAppointments ?? completedAppointments;

  factory DashboardMetrics.fromJson(Map<String, dynamic> json) {
    return DashboardMetrics(
      totalRevenue: (json['total_revenue'] as num?)?.toDouble() ?? 0.0,
      totalPatients:  (json['total_patients'] as int?) ?? 0,
      completedAppointments: (json['completed_appointments'] as int?) ?? 0,
      totalAppointments: (json['total_appointments'] as int? ),
      averageRevenuePerPatient: (json['average_revenue_per_patient'] as num?)?.toDouble() ?? 0.0,
      revenueTrend: json['revenue_trend'] as String?,
      patientsTrend: json['patients_trend'] as String?,
      appointmentsTrend: json['appointments_trend'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'total_revenue': totalRevenue,
      'total_patients': totalPatients,
      'completed_appointments': completedAppointments,
      'total_appointments': totalAppointments,
      'average_revenue_per_patient': averageRevenuePerPatient,
      'revenue_trend': revenueTrend,
      'patients_trend': patientsTrend,
      'appointments_trend':  appointmentsTrend,
    };
  }

  @override
  List<Object?> get props => [
        totalRevenue,
        totalPatients,
        completedAppointments,
        totalAppointments,
        averageRevenuePerPatient,
        revenueTrend,
        patientsTrend,
        appointmentsTrend,
      ];
}