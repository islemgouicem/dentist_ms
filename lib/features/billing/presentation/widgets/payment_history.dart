import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dentist_ms/core/constants/app_colors.dart';
import 'package:dentist_ms/core/constants/app_text_styles.dart';
import 'package:intl/intl.dart';
import 'table_wrapper.dart';
import '../../utils/billing_responsive_helper.dart';
import '../../models/payment.dart';
import '../../models/invoice.dart';
import '../../bloc/payment_bloc.dart';
import '../../bloc/payment_event.dart';
import '../../bloc/invoice_bloc.dart';
import '../../bloc/invoice_state.dart';
import '../dialogs/add_payment.dart';

class BillingPaymentHistoryControls extends StatelessWidget {
  final BillingResponsiveHelper responsive;
  final VoidCallback onAddPayment;
  final String selectedPatient;
  final Function(String) onPatientChanged;
  final List<String> patients;

  const BillingPaymentHistoryControls({
    Key? key,
    required this.responsive,
    required this.onAddPayment,
    this.selectedPatient = 'Tous les patients',
    required this.onPatientChanged,
    this.patients = const [],
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(responsive.controlsPadding),
      child: Row(
        children: [
          Expanded(child: _buildPatientFilter()),
          const SizedBox(width: 16),
          _buildAddPaymentButton(context),
        ],
      ),
    );
  }

  Widget _buildPatientFilter() {
    final allPatients = ['Tous les patients', ...patients];
    return DropdownButtonFormField<String>(
      value: selectedPatient,
      decoration: InputDecoration(
        filled: true,
        fillColor: AppColors.cardgrey,
        prefixIcon: Icon(
          Icons.filter_list,
          size: 20,
          color: AppColors.textSecondary,
        ),
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
      items: allPatients.map((String patient) {
        return DropdownMenuItem<String>(
          value: patient,
          child: Text(
            patient,
            style: AppTextStyles.body1.copyWith(color: AppColors.textPrimary),
          ),
        );
      }).toList(),
      onChanged: (String? newValue) {
        if (newValue != null) {
          onPatientChanged(newValue);
        }
      },
      icon: Icon(Icons.keyboard_arrow_down, color: AppColors.textSecondary),
    );
  }

  Widget _buildAddPaymentButton(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: () async {
        // Get invoices from the bloc before opening dialog
        final invoices =
            context.read<InvoiceBloc>().state is InvoicesLoadSuccess
            ? (context.read<InvoiceBloc>().state as InvoicesLoadSuccess)
                  .invoices
            : <Invoice>[];

        final result = await showDialog(
          context: context,
          builder: (context) => AddPaymentDialog(invoices: invoices),
        );

        if (result != null && context.mounted) {
          // Create Payment object from the dialog result
          final payment = Payment(
            invoiceId: result['invoiceId'] as int?,
            amount: result['amount'] as double,
            paymentDate: DateTime.parse(result['paymentDate'] as String),
            method: result['method'] as String?,
            reference: result['reference'] as String?,
            notes: result['notes'] as String?,
          );

          // Dispatch the AddPayment event to the BLoC
          context.read<PaymentBloc>().add(AddPayment(payment));
          onAddPayment();
        }
      },
      icon: const Icon(Icons.add, size: 20),
      label: Text(
        'Ajouter un paiement',
        style: AppTextStyles.body1.copyWith(
          color: Colors.white,
          fontWeight: FontWeight.w600,
        ),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
            style: AppTextStyles.body1.copyWith(color: AppColors.textPrimary),
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
