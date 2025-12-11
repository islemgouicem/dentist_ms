import 'package:flutter/material.dart';
import 'package:dentist_ms/core/constants/app_colors.dart';
import 'package:dentist_ms/core/constants/app_text_styles.dart';
import 'package:intl/intl.dart';
import 'table_wrapper.dart';
import '../../utils/billing_responsive_helper.dart';

class BillingPaymentHistoryControls extends StatelessWidget {
  final BillingResponsiveHelper responsive;

  const BillingPaymentHistoryControls({Key? key, required this.responsive})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(responsive.controlsPadding),
      child: Row(
        children: [
          Expanded(child: _buildSearchField()),
          const SizedBox(width: 16),
          _buildDateRangeButton(),
        ],
      ),
    );
  }

  Widget _buildSearchField() {
    return TextField(
      decoration: InputDecoration(
        hintText: 'Rechercher des paiements...',
        hintStyle: AppTextStyles.body1.copyWith(color: AppColors.textSecondary),
        prefixIcon: Icon(
          Icons.search,
          size: 20,
          color: AppColors.textSecondary,
        ),
        filled: true,
        fillColor: AppColors.cardgrey,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: AppColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: AppColors.primary, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
      ),
    );
  }

  Widget _buildDateRangeButton() {
    return OutlinedButton.icon(
      onPressed: () {},
      icon: Icon(Icons.calendar_today, size: 18, color: AppColors.textPrimary),
      label: Text(
        'Plage de dates',
        style: AppTextStyles.body1.copyWith(color: AppColors.textPrimary),
      ),
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        side: BorderSide(color: AppColors.border),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }
}

class BillingPaymentHistoryTable extends StatelessWidget {
  final List<Map<String, dynamic>> payments;
  final BillingResponsiveHelper responsive;

  const BillingPaymentHistoryTable({
    Key? key,
    required this.payments,
    required this.responsive,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BillingTableWrapper(
      headers: ['Date', 'N° Facture', 'Patient', 'Montant', 'Statut'],
      rows: _buildRows(),
    );
  }

  List<Widget> _buildRows() {
    return payments.asMap().entries.map((entry) {
      final index = entry.key;
      final payment = entry.value;
      final isLast = index == payments.length - 1;

      final double amount = (payment['amount'] ?? 0.0) as double;

      // Format date to yyyy-MM-dd
      String dateStr = '';
      final rawDate = payment['payment_date'] ?? payment['date'] ?? '';
      if (rawDate is DateTime) {
        dateStr = DateFormat('yyyy-MM-dd').format(rawDate);
      } else if (rawDate is String && rawDate.isNotEmpty) {
        try {
          dateStr = DateFormat('yyyy-MM-dd').format(DateTime.parse(rawDate));
        } catch (_) {
          dateStr = rawDate;
        }
      }

      return BillingTableRow(
        isLast: isLast,
        cells: [
          Text(
            dateStr,
            style: AppTextStyles.body1.copyWith(color: AppColors.textSecondary),
          ),
          Text(
            (payment['invoiceId'] ?? payment['invoice_id'] ?? '').toString(),
            style: AppTextStyles.body1.copyWith(
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          Text(
            (payment['patient'] ?? '').toString(),
            style: AppTextStyles.body1.copyWith(color: AppColors.textPrimary),
          ),
          Text(
            '\$${amount.toStringAsFixed(2)}',
            style: AppTextStyles.body1.copyWith(
              fontWeight: FontWeight.w600,
              color: Colors.green,
            ),
          ),
          Container(
            width: 100,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.green.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              (payment['status'] ?? payment['notes'] ?? '').toString(),
              textAlign: TextAlign.center,
              style: AppTextStyles.body1.copyWith(
                fontSize: 13,
                color: Colors.green,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      );
    }).toList();
  }
}
