import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dentist_ms/core/constants/app_colors.dart';
import 'package:dentist_ms/core/constants/app_text_styles.dart';
import 'table_wrapper.dart';
import '../../utils/billing_responsive_helper.dart';
import '../dialogs/add_treatments.dart';
import '../dialogs/treatment_details_dialog.dart';
import '../dialogs/delete_confirmation_dialog.dart';
import 'billing_controls.dart';
import '../../bloc/treatment_bloc.dart';
import '../../bloc/treatment_event.dart';
import '../../models/treatment.dart';

class BillingTreatmentCatalogControls extends StatelessWidget {
  final BillingResponsiveHelper responsive;
  final VoidCallback onAddTreatment;
  final Function(String)? onSearchChanged;

  const BillingTreatmentCatalogControls({
    Key? key,
    required this.responsive,
    required this.onAddTreatment,
    this.onSearchChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BillingControls(
      responsive: responsive,
      leftWidget: BillingSearchField(
        hintText: 'Rechercher des traitements...',
        onChanged: onSearchChanged,
      ),
      buttonText: 'Ajouter un Traitement',
      onButtonPressed: () async {
        final result = await showDialog(
          context: context,
          builder: (context) => const AddTreatmentDialog(),
        );

        if (result != null && context.mounted) {
          final treatment = Treatment(
            code: result['code'] as String?,
            name: result['name'] as String,
            description: result['description'] as String?,
            basePrice: result['price'] as double,
          );

          context.read<TreatmentBloc>().add(AddTreatment(treatment));
          onAddTreatment();
        }
      },
    );
  }
}

class BillingTreatmentCatalogTable extends StatelessWidget {
  final List<Treatment> treatments;
  final BillingResponsiveHelper responsive;

  const BillingTreatmentCatalogTable({
    Key? key,
    required this.treatments,
    required this.responsive,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BillingTableWrapper(
      headers: ['Nom du Treatment', 'Prix', 'Actions'],
      rows: _buildRows(context),
    );
  }

  List<Widget> _buildRows(BuildContext context) {
    return treatments.asMap().entries.map((entry) {
      final index = entry.key;
      final treatment = entry.value;
      final isLast = index == treatments.length - 1;

      return BillingTableRow(
        isLast: isLast,
        cells: [
          InkWell(
            onTap: () => _showTreatmentDetails(context, treatment),
            child: Text(
              treatment.name ?? 'N/A',
              style: AppTextStyles.body1.copyWith(
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          Text(
            '${treatment.basePrice?.toStringAsFixed(0) ?? '0'} DA',
            style: AppTextStyles.body1.copyWith(
              fontWeight: FontWeight.w600,
              color: Colors.green,
            ),
          ),
          _buildActionButtons(context, treatment),
        ],
      );
    }).toList();
  }

  void _showTreatmentDetails(BuildContext context, Treatment treatment) {
    showDialog(
      context: context,
      builder: (context) => TreatmentDetailsDialog(treatment: treatment),
    );
  }

  Widget _buildActionButtons(BuildContext context, Treatment treatment) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        OutlinedButton(
          onPressed: () => _handleEdit(context, treatment),
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            side: BorderSide(color: AppColors.border),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(6),
            ),
          ),
          child: Text(
            'Modifier',
            style: AppTextStyles.body1.copyWith(
              color: AppColors.textPrimary,
              fontSize: 14,
            ),
          ),
        ),
        const SizedBox(width: 8),
        OutlinedButton(
          onPressed: () => _handleDelete(context, treatment),
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            side: BorderSide(color: Colors.red.shade300),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(6),
            ),
          ),
          child: Text(
            'Supprimer',
            style: AppTextStyles.body1.copyWith(
              color: Colors.red,
              fontSize: 14,
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _handleEdit(BuildContext context, Treatment treatment) async {
    final result = await showDialog(
      context: context,
      builder: (context) => AddTreatmentDialog(
        treatment: {
          'id': treatment.id,
          'code': treatment.code,
          'name': treatment.name,
          'price': treatment.basePrice,
          'description': treatment.description,
        },
      ),
    );

    if (result != null && context.mounted) {
      final updatedTreatment = Treatment(
        id: treatment.id,
        code: result['code'] as String?,
        name: result['name'] as String,
        description: result['description'] as String?,
        basePrice: result['price'] as double,
      );

      context.read<TreatmentBloc>().add(UpdateTreatment(updatedTreatment));
    }
  }

  Future<void> _handleDelete(BuildContext context, Treatment treatment) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => DeleteConfirmationDialog(
        itemName: treatment.name ?? 'N/A',
        itemType: 'le traitement',
      ),
    );

    if (confirmed == true && context.mounted && treatment.id != null) {
      context.read<TreatmentBloc>().add(DeleteTreatment(treatment.id!));
    }
  }
}
