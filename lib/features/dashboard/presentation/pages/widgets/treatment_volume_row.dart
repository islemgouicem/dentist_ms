import 'package:flutter/material.dart';
import 'package:dentist_ms/core/constants/app_colors.dart';

class TreatmentVolumeRow extends StatelessWidget {
  const TreatmentVolumeRow({
    super.key,
    required this.label,
    required this.value,
    required this.max,
  });
  final String label;
  final int value;
  final int max;

  @override
  Widget build(BuildContext context) {
    final pct = value / max;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(color: kTextPrimary),
            ),
          ),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: pct,
                minHeight: 10,
                color: const Color(0xFF60A5FA),
                backgroundColor: const Color(0xFFEFF2F7),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Text(
            '$value',
            style: const TextStyle(color: kTextSecondary),
          ),
        ],
      ),
    );
  }
}
