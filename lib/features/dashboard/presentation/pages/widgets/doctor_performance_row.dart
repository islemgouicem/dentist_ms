import 'package:flutter/material.dart';
import 'package:dentist_ms/core/constants/app_colors.dart';

class DoctorPerformanceRow extends StatelessWidget {
  final String doctorName;
  final int completedTreatments;
  final double progress; // 0.0 to 1.0
  final int rank;

  const DoctorPerformanceRow({
    super.key,
    required this. doctorName,
    required this.completedTreatments,
    required this.progress,
    required this.rank,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: _getRankColor().withOpacity(0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child:  Center(
                  child: Text(
                    '$rank',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: _getRankColor(),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  doctorName,
                  style: const TextStyle(
                    fontSize:  14,
                    fontWeight: FontWeight.w600,
                    color: kTextPrimary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Text(
                '$completedTreatments',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: kTextPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height:  8),
          Stack(
            children:  [
              Container(
                height: 8,
                decoration:  BoxDecoration(
                  color: const Color(0xFFE7E7E7),
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
              FractionallySizedBox(
                widthFactor: progress. clamp(0.0, 1.0),
                child: Container(
                  height: 8,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [_getRankColor(), _getRankColor().withOpacity(0.7)],
                    ),
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Color _getRankColor() {
    switch (rank) {
      case 1:
        return const Color(0xFFFFD700); // Gold
      case 2:
        return const Color(0xFFC0C0C0); // Silver
      case 3:
        return const Color(0xFFCD7F32); // Bronze
      default:
        return const Color(0xFF6366F1); // Default purple
    }
  }
}