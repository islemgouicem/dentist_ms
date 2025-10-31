import 'package:flutter/material.dart';
import 'package:dentist_ms/core/constants/app_colors.dart';
import 'package:dentist_ms/core/constants/app_text_styles.dart';
import 'status_badge.dart';
import 'table_wrapper.dart';
import '../../utils/billing_responsive_helper.dart';

class BillingTableControls extends StatelessWidget {
  final BillingResponsiveHelper responsive;
  final String selectedStatus;
  final Function(String) onStatusChanged;

  const BillingTableControls({
    Key? key,
    required this.responsive,
    this.selectedStatus = 'Tous les statuts',
    required this.onStatusChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(responsive.controlsPadding),
      child: Row(
        children: [
          Expanded(child: _buildSearchField()),
          const SizedBox(width: 16),
          SizedBox(width: 200, child: _buildStatusDropdown()),
        ],
      ),
    );
  }

  Widget _buildSearchField() {
    return TextField(
      decoration: InputDecoration(
        hintText: 'Rechercher des factures...',
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

  Widget _buildStatusDropdown() {
    return DropdownButtonFormField<String>(
      value: selectedStatus,
      decoration: InputDecoration(
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
      items: ['Tous les statuts', 'Payé', 'Partiel', 'Non payé'].map((
        String status,
      ) {
        return DropdownMenuItem<String>(
          value: status,
          child: Text(
            status,
            style: AppTextStyles.body1.copyWith(color: AppColors.textPrimary),
          ),
        );
      }).toList(),
      onChanged: (String? newValue) {
        if (newValue != null) {
          onStatusChanged(newValue);
        }
      },
      icon: Icon(Icons.keyboard_arrow_down, color: AppColors.textSecondary),
    );
  }
}

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
            style: AppTextStyles.body1.copyWith(color: AppColors.textPrimary),
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
        ],
      );
    }).toList();
  }
}
