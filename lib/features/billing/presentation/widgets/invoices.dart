import 'package:flutter/material.dart';
import 'package:dentist_ms/core/constants/app_colors.dart';
import 'package:dentist_ms/core/constants/app_text_styles.dart';
import 'status_badge.dart';
import 'table_wrapper.dart';
import '../../utils/billing_responsive_helper.dart';

class BillingDataTable extends StatelessWidget {
  final List<Map<String, dynamic>> invoices;
  final BillingResponsiveHelper responsive;

  const BillingDataTable({
    Key? key,
    required this.invoices,
    required this.responsive,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BillingTableWrapper(
      headers: [
        'N° Facture',
        'Patient',
        'Date',
        'Traitement',
        'Montant',
        'Payé',
        'Solde',
        'Statut',
        'Actions',
      ],
      rows: _buildRows(),
    );
  }

  List<Widget> _buildRows() {
    return invoices.asMap().entries.map((entry) {
      final index = entry.key;
      final invoice = entry.value;
      final double amount = invoice['amount'];
      final double paid = invoice['paid'] ?? 0.0;
      final double balance = amount - paid;
      final isLast = index == invoices.length - 1;

      return BillingTableRow(
        isLast: isLast,
        cells: [
          Text(
            invoice['id'],
            style: AppTextStyles.body1.copyWith(
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          Text(
            invoice['patient'],
            style: AppTextStyles.body1.copyWith(color: AppColors.textPrimary),
          ),
          Text(
            invoice['date'],
            style: AppTextStyles.body1.copyWith(color: AppColors.textSecondary),
          ),
          Text(
            invoice['treatment'],
            style: AppTextStyles.body1.copyWith(color: AppColors.textSecondary),
          ),
          Text(
            '\$${amount.toStringAsFixed(0)}',
            style: AppTextStyles.body1.copyWith(
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          Text(
            '\$${paid.toStringAsFixed(0)}',
            style: AppTextStyles.body1.copyWith(color: AppColors.textPrimary),
          ),
          Text(
            '\$${balance.toStringAsFixed(0)}',
            style: AppTextStyles.body1.copyWith(
              fontWeight: FontWeight.w600,
              color: balance > 0 ? Colors.red : Colors.green,
            ),
          ),
          BillingStatusBadge(status: invoice['status']),
          _buildActionButtons(),
        ],
      );
    }).toList();
  }

  Widget _buildActionButtons() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: const Color(0xFF4A5568),
            borderRadius: BorderRadius.circular(8),
          ),
          child: IconButton(
            icon: const Icon(Icons.description_outlined, size: 18),
            color: Colors.white,
            padding: EdgeInsets.zero,
            onPressed: () {
              // TODO: View invoice details
            },
            tooltip: 'Voir',
          ),
        ),
      ],
    );
  }
}
