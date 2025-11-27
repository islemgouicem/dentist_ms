import 'package:flutter/material.dart';
import 'package:dentist_ms/core/constants/app_colors.dart';

class TreatmentRow extends StatelessWidget {
  const TreatmentRow({
    super.key,
    required this.title,
    required this.amount,
    required this.progress,
    required this.count,
  });

  final String title;
  final String amount;
  final double progress;
  final int count;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    color: kTextPrimary,
                  ),
                ),
              ),
              Text(
                amount,
                style: const TextStyle(
                  color: Color(0xFF16A34A),
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: LinearProgressIndicator(
                    value: progress,
                    minHeight: 8,
                    color: const Color(0xFF2563EB),
                    backgroundColor: const Color(0xFFEFF2F7),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Text(
                '$count',
                style: const TextStyle(color: kTextSecondary, fontSize: 12),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
