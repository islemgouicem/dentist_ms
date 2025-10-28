import 'package:flutter/material.dart';
import 'package:dentist_ms/core/constants/app_colors.dart';
import 'package:dentist_ms/core/constants/app_text_styles.dart';
import 'table_wrapper.dart';
import '../../utils/billing_responsive_helper.dart';
import '../dialogs/add_expense.dart';

class BillingExpensesControls extends StatelessWidget {
  final BillingResponsiveHelper responsive;
  final VoidCallback onAddExpense;

  const BillingExpensesControls({
    Key? key,
    required this.responsive,
    required this.onAddExpense,
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
        hintText: 'Rechercher des dépenses...',
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
          builder: (context) => const AddExpenseDialog(),
        );

        if (result != null) {
          print('New expense added: $result');
          onAddExpense(); // Call the callback to refresh the list
          // TODO: Add expense to list and update backend
        }
      },
      icon: const Icon(Icons.add, size: 20),
      label: Text(
        'Ajouter une dépense',
        style: AppTextStyles.body1.copyWith(
          color: Colors.white,
          fontWeight: FontWeight.w600,
        ),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.black,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }
}

class BillingExpensesTable extends StatelessWidget {
  final List<Map<String, dynamic>> expenses;
  final BillingResponsiveHelper responsive;

  const BillingExpensesTable({
    Key? key,
    required this.expenses,
    required this.responsive,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BillingTableWrapper(
      headers: ['Date', 'Description', 'Montant', 'Actions'],
      rows: _buildRows(),
    );
  }

  List<Widget> _buildRows() {
    return expenses.asMap().entries.map((entry) {
      final index = entry.key;
      final expense = entry.value;
      final isLast = index == expenses.length - 1;

      return BillingTableRow(
        isLast: isLast,
        cells: [
          Text(
            expense['date'],
            style: AppTextStyles.body1.copyWith(color: AppColors.textSecondary),
          ),
          Text(
            expense['description'],
            style: AppTextStyles.body1.copyWith(color: AppColors.textPrimary),
          ),
          Text(
            '-\$${expense['amount'].toStringAsFixed(0)}',
            style: AppTextStyles.body1.copyWith(
              fontWeight: FontWeight.w600,
              color: Colors.red,
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
          onPressed: () {
            // TODO: Edit expense
          },
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
          onPressed: () {
            // TODO: Delete expense
          },
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
