import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dentist_ms/core/constants/app_colors.dart';
import 'package:dentist_ms/core/constants/app_text_styles.dart';
import 'table_wrapper.dart';
import '../../utils/billing_responsive_helper.dart';
import '../dialogs/add_treatments.dart';
import '../dialogs/treatment_details_dialog.dart';
import '../../bloc/treatment_bloc.dart';
import '../../bloc/treatment_event.dart';
import '../../bloc/treatment_state.dart';
import '../../models/treatment.dart';

class BillingTreatmentCatalogControls extends StatelessWidget {
  final BillingResponsiveHelper responsive;
  final VoidCallback onAddTreatment;

  const BillingTreatmentCatalogControls({
    Key? key,
    required this.responsive,
    required this.onAddTreatment,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(responsive.controlsPadding),
      child: Row(
        children: [
          Expanded(child: _buildSearchField()),
          const SizedBox(width: 16),
          _buildAddButton(context),
        ],
      ),
    );
  }

  Widget _buildSearchField() {
    return TextField(
      decoration: InputDecoration(
        hintText: 'Rechercher des Treatments...',
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

  Widget _buildAddButton(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: () async {
        final result = await showDialog(
          context: context,
          builder: (context) => const AddTreatmentDialog(),
        );

        if (result != null && context.mounted) {
          // Create Treatment object from the dialog result
          final treatment = Treatment(
            code: result['code'] as String?,
            name: result['name'] as String,
            description: result['description'] as String?,
            basePrice: result['price'] as double,
          );

          // Dispatch the AddTreatment event to the BLoC
          context.read<TreatmentBloc>().add(AddTreatment(treatment));
          onAddTreatment();
        }
      },
      icon: const Icon(Icons.add, size: 20),
      label: Text(
        'Ajouter un Treatment',
        style: AppTextStyles.body1.copyWith(
          color: Colors.white,
          fontWeight: FontWeight.w600,
        ),
      ),
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
            '\$${treatment.basePrice?.toStringAsFixed(0) ?? '0'}',
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
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Colors.orange, size: 28),
            const SizedBox(width: 12),
            Text('Confirmer la suppression', style: AppTextStyles.headline2),
          ],
        ),
        content: Text(
          'Êtes-vous sûr de vouloir supprimer le traitement "${treatment.name}" ?\n\nCette action est irréversible.',
          style: AppTextStyles.body1,
        ),
        actions: [
          OutlinedButton(
            onPressed: () => Navigator.of(context).pop(false),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              side: BorderSide(color: AppColors.border),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text(
              'Annuler',
              style: AppTextStyles.body1.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text(
              'Supprimer',
              style: AppTextStyles.body1.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted && treatment.id != null) {
      context.read<TreatmentBloc>().add(DeleteTreatment(treatment.id!));
    }
  }
}
