import 'package:flutter/material.dart';
import 'package:dentist_ms/core/constants/app_colors.dart';
import 'package:dentist_ms/core/constants/app_text_styles.dart';
import '../../utils/billing_responsive_helper.dart';

class BillingControls extends StatelessWidget {
  final BillingResponsiveHelper responsive;
  final Widget leftWidget;
  final String buttonText;
  final IconData buttonIcon;
  final VoidCallback onButtonPressed;

  const BillingControls({
    Key? key,
    required this.responsive,
    required this.leftWidget,
    required this.buttonText,
    this.buttonIcon = Icons.add,
    required this.onButtonPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(responsive.controlsPadding),
      child: Row(
        children: [
          Expanded(child: leftWidget),
          const SizedBox(width: 16),
          _buildAddButton(),
        ],
      ),
    );
  }

  Widget _buildAddButton() {
    return ElevatedButton.icon(
      onPressed: onButtonPressed,
      icon: Icon(buttonIcon, size: 20),
      label: Text(
        buttonText,
        style: AppTextStyles.body1.copyWith(
          color: Colors.white,
          fontWeight: FontWeight.w600,
        ),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        minimumSize: const Size(0, 48),
      ),
    );
  }
}

class BillingSearchField extends StatelessWidget {
  final String hintText;
  final Function(String)? onChanged;

  const BillingSearchField({Key? key, required this.hintText, this.onChanged})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextField(
      onChanged: onChanged,
      decoration: InputDecoration(
        hintText: hintText,
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
}

class BillingDropdownFilter extends StatelessWidget {
  final String value;
  final List<String> items;
  final Function(String) onChanged;
  final IconData prefixIcon;

  const BillingDropdownFilter({
    Key? key,
    required this.value,
    required this.items,
    required this.onChanged,
    this.prefixIcon = Icons.filter_list,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      value: value,
      decoration: InputDecoration(
        filled: true,
        fillColor: AppColors.cardgrey,
        prefixIcon: Icon(prefixIcon, size: 20, color: AppColors.textSecondary),
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
      items: items.map((String item) {
        return DropdownMenuItem<String>(
          value: item,
          child: Text(
            item,
            style: AppTextStyles.body1.copyWith(color: AppColors.textPrimary),
          ),
        );
      }).toList(),
      onChanged: (String? newValue) {
        if (newValue != null) {
          onChanged(newValue);
        }
      },
      icon: Icon(Icons.keyboard_arrow_down, color: AppColors.textSecondary),
    );
  }
}
