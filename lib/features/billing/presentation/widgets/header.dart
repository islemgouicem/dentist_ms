import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dentist_ms/core/constants/app_text_styles.dart';
import '../../utils/billing_responsive_helper.dart';
import '../dialogs/add_invoice.dart';
import '../../bloc/invoice_bloc.dart';
import '../../bloc/invoice_event.dart';
import '../../models/invoice.dart';

class BillingHeader extends StatelessWidget {
  final BillingResponsiveHelper responsive;

  const BillingHeader({Key? key, required this.responsive}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Facturation & Factures',
          style: AppTextStyles.headline1.copyWith(
            fontSize: responsive.headerFontSize,
          ),
        ),
        ElevatedButton.icon(
          onPressed: () => _showAddInvoiceDialog(context),
          icon: const Icon(Icons.add, size: 20),
          label: const Text('Nouvelle facture'),
        ),
      ],
    );
  }

  Future<void> _showAddInvoiceDialog(BuildContext context) async {
    final result = await showDialog(
      context: context,
      builder: (context) => const AddInvoiceDialog(),
    );

    if (result != null && context.mounted) {
      // Create Invoice object from the dialog result
      final invoice = Invoice(
        invoiceNumber: result['invoiceNumber'] as String,
        patientId: result['patientId'] as int?,
        status: result['status'] as String,
        startDate: DateTime.parse(result['date'] as String),
        dueDate: DateTime.parse(
          result['date'] as String,
        ).add(const Duration(days: 7)),
        subtotalAmount: result['amount'] as double,
        discountAmount: 0.0,
        totalAmount: result['amount'] as double,
        notes: result['notes'] as String,
      );

      // Dispatch the AddInvoice event to the BLoC with treatment info
      context.read<InvoiceBloc>().add(
        AddInvoice(
          invoice,
          treatmentId: result['treatmentId'] as int?,
          treatmentPrice: result['amount'] as double,
        ),
      );
    }
  }
}
