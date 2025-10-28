import 'package:flutter/material.dart';
import 'package:dentist_ms/core/constants/app_text_styles.dart';
import '../../utils/billing_responsive_helper.dart';
import '../dialogs/add_invoice.dart'; // Add this import

class BillingHeader extends StatelessWidget {
  final BillingResponsiveHelper responsive;

  const BillingHeader({Key? key, required this.responsive}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (responsive.isMobile) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Facturation & Factures',
            style: AppTextStyles.headline1.copyWith(
              fontSize: responsive.headerFontSize,
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => _showAddInvoiceDialog(context),
              icon: const Icon(Icons.add, size: 20),
              label: const Text('Nouvelle facture'),
            ),
          ),
        ],
      );
    }

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

    if (result != null) {
      // Handle the returned invoice data
      print('New invoice created: $result');
      // TODO: Add invoice to list and update backend
    }
  }
}
