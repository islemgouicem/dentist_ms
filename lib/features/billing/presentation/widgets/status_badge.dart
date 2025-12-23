import 'package:flutter/material.dart';
import 'package:dentist_ms/core/constants/app_colors.dart';
import 'package:dentist_ms/core/constants/app_text_styles.dart';

class BillingStatusBadge extends StatelessWidget {
  final String status;

  const BillingStatusBadge({Key? key, required this.status}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final colors = _getStatusColors();

    return Container(
      width: 100,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: colors['background'],
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        _getStatusText(),
        textAlign: TextAlign.center,
        style: AppTextStyles.smallLabel.copyWith(
          color: colors['text'],
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  String _getStatusText() {
    switch (status.toLowerCase()) {
      case 'paid':
        return 'Payé';
      case 'pending':
      case 'partial':
        return 'En attente';
      case 'overdue':
      case 'unpaid':
        return 'En retard';
      default:
        return status;
    }
  }

  Map<String, Color> _getStatusColors() {
    switch (status.toLowerCase()) {
      case 'paid':
        return {
          'background': AppColors.statusCompleted.withOpacity(0.1),
          'text': AppColors.statusCompleted,
        };
      case 'pending':
      case 'partial':
        return {
          'background': AppColors.statusNoShow.withOpacity(0.1),
          'text': AppColors.statusNoShow,
        };
      case 'overdue':
      case 'unpaid':
        return {
          'background': AppColors.statusCancelled.withOpacity(0.1),
          'text': AppColors.statusCancelled,
        };
      default:
        return {'background': AppColors.border, 'text': Colors.grey[600]!};
    }
  }
}
