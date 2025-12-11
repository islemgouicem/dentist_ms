import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dentist_ms/core/constants/app_colors.dart';
import 'package:dentist_ms/core/constants/app_text_styles.dart';
import 'table_wrapper.dart';
import '../../utils/billing_responsive_helper.dart';
import '../dialogs/add_treatments.dart';
import '../../bloc/treatment_bloc.dart';
import '../../bloc/treatment_event.dart';
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
  final List<Map<String, dynamic>> Treatments;
  final BillingResponsiveHelper responsive;

  const BillingTreatmentCatalogTable({
    Key? key,
    required this.Treatments,
    required this.responsive,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BillingTableWrapper(
      headers: ['Nom du Treatment', 'Prix', 'Actions'],
      rows: _buildRows(),
    );
  }

  List<Widget> _buildRows() {
    return Treatments.asMap().entries.map((entry) {
      final index = entry.key;
      final Treatment = entry.value;
      final isLast = index == Treatments.length - 1;

      return BillingTableRow(
        isLast: isLast,
        cells: [
          Text(
            Treatment['name'],
            style: AppTextStyles.body1.copyWith(
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          Text(
            '\$${Treatment['price'].toStringAsFixed(0)}',
            style: AppTextStyles.body1.copyWith(
              fontWeight: FontWeight.w600,
              color: Colors.green,
            ),
          ),
          _buildActionButtons(),
        ],
      );
    }).toList();
  }

  Widget _buildActionButtons() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        OutlinedButton(
          onPressed: () {},
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
          onPressed: () {},
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            side: BorderSide(color: AppColors.border),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(6),
            ),
          ),
          child: Text(
            'Supprimer',
            style: AppTextStyles.body1.copyWith(
              color: AppColors.textPrimary,
              fontSize: 14,
            ),
          ),
        ),
      ],
    );
  }
}
