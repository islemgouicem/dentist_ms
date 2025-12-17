import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:dentist_ms/core/constants/app_colors.dart';
import 'package:dentist_ms/core/constants/app_text_styles.dart';
import 'table_wrapper.dart';
import '../../utils/billing_responsive_helper.dart';
import '../dialogs/add_expense.dart';
import '../dialogs/delete_confirmation_dialog.dart';
import 'billing_controls.dart';
import '../../bloc/expense_bloc.dart';
import '../../bloc/expense_event.dart';
import '../../models/expense.dart';

class BillingExpensesControls extends StatelessWidget {
  final BillingResponsiveHelper responsive;
  final VoidCallback onAddExpense;
  final String selectedCategory;
  final Function(String) onCategoryChanged;
  final List<String> categories;

  const BillingExpensesControls({
    Key? key,
    required this.responsive,
    required this.onAddExpense,
    this.selectedCategory = 'Toutes les catégories',
    required this.onCategoryChanged,
    this.categories = const [],
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final allCategories = ['Toutes les catégories', ...categories];
    return BillingControls(
      responsive: responsive,
      leftWidget: BillingDropdownFilter(
        value: selectedCategory,
        items: allCategories,
        onChanged: onCategoryChanged,
      ),
      buttonText: 'Ajouter une dépense',
      onButtonPressed: () async {
        final result = await showDialog(
          context: context,
          builder: (context) => const AddExpenseDialog(),
        );

        if (result != null && context.mounted) {
          final expense = Expense(
            description: result['description'] as String,
            amount: result['amount'] as double,
            expenseDate: DateTime.parse(result['date'] as String),
            categoryId: result['categoryId'] as int?,
          );

          context.read<ExpenseBloc>().add(AddExpense(expense));
          onAddExpense();
        }
      },
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
            _formatDate(expense['date']),
            style: AppTextStyles.body1.copyWith(color: AppColors.textPrimary),
          ),
          Text(
            expense['description']?.toString() ?? 'N/A',
            style: AppTextStyles.body1.copyWith(color: AppColors.textPrimary),
          ),
          Text(
            "-${_formatAmount(expense['amount'])} DA",
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

  String _formatDate(dynamic date) {
    if (date is DateTime) {
      return DateFormat('dd-MM-yyyy').format(date);
    } else if (date is String && date.isNotEmpty) {
      try {
        return DateFormat('dd-MM-yyyy').format(DateTime.parse(date));
      } catch (_) {
        return date;
      }
    }
    return 'N/A';
  }

  String _formatAmount(dynamic amount) {
    if (amount is num) {
      return amount.toStringAsFixed(0);
    } else if (amount is String) {
      try {
        return double.parse(amount).toStringAsFixed(0);
      } catch (_) {
        return '0';
      }
    }
    return '0';
  }

  Widget _buildActionButtons(Map<String, dynamic> expense) {
    return Builder(
      builder: (context) => Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            constraints: const BoxConstraints(minWidth: 70),
            child: OutlinedButton(
              onPressed: () => _handleEdit(context, expense),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
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
              onPressed: () => _handleDelete(context, expense),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                side: BorderSide(
                  color: AppColors.statusCancelled.withOpacity(0.2),
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
              child: Text(
                'Supprimer',
                style: AppTextStyles.body1.copyWith(
                  color: AppColors.statusCancelled,
                  fontSize: 13,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _handleEdit(
    BuildContext context,
    Map<String, dynamic> expense,
  ) async {
    final result = await showDialog(
      context: context,
      builder: (context) => AddExpenseDialog(expense: expense),
    );

    if (result != null && context.mounted) {
      // Create updated Expense object
      final updatedExpense = Expense(
        id: expense['id'] as int?,
        description: result['description'] as String,
        amount: result['amount'] as double,
        expenseDate: DateTime.parse(result['date'] as String),
        categoryId: result['categoryId'] as int?,
      );

      // Dispatch UpdateExpense event
      context.read<ExpenseBloc>().add(UpdateExpense(updatedExpense));
    }
  }

  Future<void> _handleDelete(
    BuildContext context,
    Map<String, dynamic> expense,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => DeleteConfirmationDialog(
        itemName: expense['description']?.toString() ?? 'N/A',
        itemType: 'la dépense',
      ),
    );

    if (confirmed == true && context.mounted) {
      final expenseId = expense['id'] as int?;
      if (expenseId != null) {
        context.read<ExpenseBloc>().add(DeleteExpense(expenseId));
      }
    }
  }
}
