import 'package:flutter/material.dart';
import 'package:dentist_ms/core/constants/app_colors.dart';
import 'package:dentist_ms/core/constants/app_text_styles.dart';
import 'package:intl/intl.dart';
import 'status_badge.dart';
import 'table_wrapper.dart';
import '../../utils/billing_responsive_helper.dart';
import '../../models/invoice.dart';

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
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildHeader(),
          const SizedBox(height: 8),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: invoices.length,
            itemBuilder: (context, index) => _buildRow(invoices[index]),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          _headerCell('N° Facture', flex: 2),
          _headerCell('Patient', flex: 2),
          _headerCell('Date', flex: 2),
          _headerCell('Traitement', flex: 3),
          _headerCell('Montant', flex: 2, align: TextAlign.right),
          _headerCell('Payé', flex: 2, align: TextAlign.right),
          _headerCell('Statut', flex: 2, align: TextAlign.center),
          const SizedBox(width: 40),
        ],
      ),
    );
  }

  Widget _headerCell(
    String text, {
    int flex = 1,
    TextAlign align = TextAlign.left,
  }) {
    return Expanded(
      flex: flex,
      child: Text(
        text,
        textAlign: align,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: AppColors.textSecondary,
        ),
      ),
    );
  }

  Widget _buildRow(Invoice invoice) {
    final status = invoice.status ?? '';
    final totalAmount = invoice.totalAmount ?? 0.0;
    final paidAmount = status == 'paid'
        ? totalAmount
        : (status == 'partial' ? totalAmount / 2 : 0.0);

    return Container(
      margin: const EdgeInsets.only(bottom: 4),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.border.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          _dataCell(invoice.invoiceNumber ?? '', flex: 2, bold: true),
          _dataCell('', flex: 2),
          _dataCell(_formatDate(invoice.startDate), flex: 2),
          _dataCell(invoice.notes ?? '', flex: 3),
          _dataCell(
            '\$${totalAmount.toStringAsFixed(0)}',
            flex: 2,
            align: TextAlign.right,
            bold: true,
          ),
          _dataCell(
            '\$${paidAmount.toStringAsFixed(0)}',
            flex: 2,
            align: TextAlign.right,
          ),
          _statusCell(status, flex: 2),
          SizedBox(
            width: 40,
            child: IconButton(
              icon: Icon(Icons.more_vert, color: AppColors.textSecondary),
              onPressed: () {},
              iconSize: 20,
            ),
          ),
        ],
      ),
    );
  }

  Widget _dataCell(
    String text, {
    int flex = 1,
    TextAlign align = TextAlign.left,
    bool bold = false,
  }) {
    return Expanded(
      flex: flex,
      child: Text(
        text,
        textAlign: align,
        style: TextStyle(
          fontSize: 14,
          fontWeight: bold ? FontWeight.w600 : FontWeight.normal,
          color: AppColors.textPrimary,
        ),
        overflow: TextOverflow.ellipsis,
      ),
    );
  }

  Widget _statusCell(String status, {int flex = 1}) {
    final statusColor = _getStatusColor(status);
    final statusText = _getStatusText(status);

    return Expanded(
      flex: flex,
      child: Center(
        child: Container(
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
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime? date) {
    if (date == null) return '';
    return DateFormat('yyyy-MM-dd').format(date);
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
        return 'Payé';
      case 'partial':
        return 'En attente';
      case 'unpaid':
        return 'En retard';
      default:
        return status;
    }
  }
}
