import 'package:flutter/material.dart';
import 'package:dentist_ms/core/constants/app_colors.dart';
import 'package:dentist_ms/core/constants/app_text_styles.dart';

class BillingTableWrapper extends StatelessWidget {
  final List<String> headers;
  final List<Widget> rows;
  final Widget? searchControls;

  const BillingTableWrapper({
    Key? key,
    required this.headers,
    required this.rows,
    this.searchControls,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (searchControls != null) searchControls!,
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              // Header Row
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 16,
                ),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(color: AppColors.border, width: 1),
                  ),
                ),
                child: Row(
                  children: headers.map((header) {
                    return Expanded(
                      child: Text(
                        header,
                        style: AppTextStyles.smallLabel.copyWith(
                          fontWeight: FontWeight.w600,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
              // Data Rows
              ...rows,
            ],
          ),
        ),
      ],
    );
  }
}

class BillingTableRow extends StatelessWidget {
  final List<Widget> cells;
  final bool isLast;

  const BillingTableRow({Key? key, required this.cells, this.isLast = false})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      decoration: BoxDecoration(
        border: isLast
            ? null
            : Border(
                bottom: BorderSide(color: AppColors.border.withOpacity(0.3)),
              ),
      ),
      child: Row(
        children: cells.map((cell) {
          return Expanded(child: cell);
        }).toList(),
      ),
    );
  }
}
