import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dentist_ms/core/constants/app_colors.dart';
import 'package:dentist_ms/core/constants/app_text_styles.dart';
import 'table_wrapper.dart';
import '../../utils/billing_responsive_helper.dart';
import '../dialogs/add_expense.dart';
import '../../bloc/expense_bloc.dart';
import '../../bloc/expense_event.dart';
import '../../models/expense.dart';

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

        if (result != null && context.mounted) {
          // Create Expense object from the dialog result
          final expense = Expense(
            description: result['description'] as String,
            amount: result['amount'] as double,
            expenseDate: DateTime.parse(result['date'] as String),
            categoryId: result['categoryId'] as int?,
          );

          // Dispatch the AddExpense event to the BLoC
          context.read<ExpenseBloc>().add(AddExpense(expense));
          onAddExpense();
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
      headers: ['Date', 'Description', 'Catégorie', 'Montant', 'Actions'],
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
          _buildCategoryChip(expense['category'] as String? ?? 'Autre'),
          Text(
            '-\$${expense['amount'].toStringAsFixed(0)}',
            style: AppTextStyles.body1.copyWith(
              fontWeight: FontWeight.w600,
              color: Colors.red,
            ),
          ),
          _buildActionButtons(expense),
        ],
      );
    }).toList();
  }

  Widget _buildCategoryChip(String category) {
    return Container(
      child: Text(
        category,
        style: AppTextStyles.body1.copyWith(color: AppColors.textPrimary),
      ),
    );
  }

  Widget _buildActionButtons(Map<String, dynamic> expense) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          constraints: const BoxConstraints(minWidth: 70),
          child: OutlinedButton(
            onPressed: () {},
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              side: BorderSide(color: AppColors.border),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(6),
              ),
            ),
            child: Text(
              'Modifier',
              style: AppTextStyles.body1.copyWith(
                color: AppColors.textPrimary,
                fontSize: 13,
              ),
            ),
          ),
        ),
        const SizedBox(width: 6),
        Container(
          constraints: const BoxConstraints(minWidth: 80),
          child: OutlinedButton(
            onPressed: () {},
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              side: BorderSide(color: AppColors.border),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(6),
              ),
            ),
            child: Text(
              'Supprimer',
              style: AppTextStyles.body1.copyWith(
                color: AppColors.textPrimary,
                fontSize: 13,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
