import 'package:equatable/equatable.dart';

class TreatmentDistribution extends Equatable {
  final int treatmentId;
  final String treatmentName;
  final int count;  
  final double percentage;  

  const TreatmentDistribution({
    required this.treatmentId,
    required this.treatmentName,
    required this.count,
    required this.percentage,
  });

  @override
  List<Object? > get props => [treatmentId, treatmentName, count, percentage];
}

class TreatmentsChartData extends Equatable {
  final List<TreatmentDistribution> treatments;
  final int totalCount;

  const TreatmentsChartData({
    required this. treatments,
    required this.totalCount,
  });
  int get maxCount {
    if (treatments.isEmpty) return 10;
    final max = treatments.map((t) => t.count).reduce((a, b) => a > b ? a : b);
    return max > 0 ? max : 10;  
  }

  @override
  List<Object?> get props => [treatments, totalCount];
}