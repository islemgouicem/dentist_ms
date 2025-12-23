import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dentist_ms/core/constants/app_colors.dart';
import 'package:dentist_ms/core/constants/app_text_styles.dart';
import 'package:intl/intl.dart';
import 'table_wrapper.dart';
import '../../utils/billing_responsive_helper.dart';
import '../../models/invoice.dart';
import '../../bloc/invoice_bloc.dart';
import '../../bloc/invoice_event.dart';
import '../pages/invoice_details.dart';

class BillingTableControls extends StatelessWidget {
  final BillingResponsiveHelper responsive;
  final String selectedStatus;
  final Function(String) onStatusChanged;
  final Function(String)? onSearchChanged;

  const BillingTableControls({
    Key? key,
    required this.responsive,
    this.selectedStatus = 'Tous les statuts',
    required this.onStatusChanged,
    this.onSearchChanged,
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
      onChanged: onSearchChanged,
      decoration: InputDecoration(
        hintText: 'Rechercher par patient...',
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

class InvoiceTable extends StatelessWidget {
  final List<Invoice> invoices;
  final BillingResponsiveHelper responsive;

  const InvoiceTable({
    Key? key,
    required this.invoices,
    required this.responsive,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BillingTableWrapper(
      headers: ['N° Facture', 'Patient', 'Date', 'Montant', 'Statut'],
      rows: _buildRows(context),
    );
  }

  List<Widget> _buildRows(BuildContext context) {
    return invoices.asMap().entries.map((entry) {
      final index = entry.key;
      final invoice = entry.value;
      final isLast = index == invoices.length - 1;

      final status = invoice.status ?? '';
      final totalAmount = invoice.totalAmount ?? 0.0;

      return InkWell(
        onTap: () async {
          if (invoice.id != null) {
            await Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) =>
                    InvoiceDetailScreenWrapper(invoiceId: invoice.id!),
              ),
            );
            // Reload invoices when returning to refresh totals
            if (context.mounted) {
              context.read<InvoiceBloc>().add(LoadInvoices());
            }
          }
        },
        child: BillingTableRow(
          isLast: isLast,
          cells: [
            Text(
              invoice.invoiceNumber ?? '',
              style: AppTextStyles.body1.copyWith(
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            Text(
              invoice.patientName ?? '-',
              style: AppTextStyles.body1.copyWith(color: AppColors.textPrimary),
            ),
            Text(
              _formatDate(invoice.startDate),
              style: AppTextStyles.body1.copyWith(color: AppColors.textPrimary),
            ),
            Text(
              '${totalAmount.toStringAsFixed(0)} DA',
              style: AppTextStyles.body1.copyWith(
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            _buildStatusBadge(status),
          ],
        ),
      );
    }).toList();
  }

  Widget _buildStatusBadge(String status) {
    final statusColor = _getStatusColor(status);
    final statusText = _getStatusText(status);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: statusColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        statusText,
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: statusColor,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  String _formatDate(DateTime? date) {
    if (date == null) return '';
    return DateFormat('dd-MM-yyyy').format(date);
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'paid':
        return const Color(0xFF10B981);
      case 'partial':
        return const Color(0xFFF59E0B);
      case 'unpaid':
        return const Color(0xFFEF4444);
      default:
        return AppColors.textSecondary;
    }
  }

  String _getStatusText(String status) {
    switch (status.toLowerCase()) {
      case 'paid':
        return 'payé';
      case 'partial':
        return 'Partiel';
      case 'unpaid':
        return 'Impayé';
      default:
        return status;
    }
  }
}
