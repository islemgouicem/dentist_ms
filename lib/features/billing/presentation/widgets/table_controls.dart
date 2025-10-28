import 'package:flutter/material.dart';
import 'package:dentist_ms/core/constants/app_colors.dart';
import 'package:dentist_ms/core/constants/app_text_styles.dart';
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
    if (responsive.isMobile) {
      return Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildSearchField(),
            const SizedBox(height: 12),
            _buildStatusDropdown(),
          ],
        ),
      );
    }

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
