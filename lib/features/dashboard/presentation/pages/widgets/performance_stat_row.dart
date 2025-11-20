import 'package:flutter/material.dart';
import 'package:dentist_ms/core/constants/app_colors.dart';

class PerformanceStatRow extends StatelessWidget {
  const PerformanceStatRow({
    super.key,
    required this.label,
    required this.value,
    required this.percentLabel,
    required this.color,
  });

  final String label;
  final double value;
  final String percentLabel;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                label,
                style: const TextStyle(
                  fontSize: 14,
                  color: kTextPrimary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            Text(
              percentLabel,
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF2563EB),
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(999),
          child: LinearProgressIndicator(
            value: value,
            minHeight: 10,
            color: color,
            backgroundColor: const Color(0xFFEFF2F7),
          ),
        ),
      ],
    );
  }
}
