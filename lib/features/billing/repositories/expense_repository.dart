import 'package:dentist_ms/features/billing/data/expense_remote.dart';
import 'package:dentist_ms/features/billing/models/expense.dart';

/// Abstract Interface for the Repository
abstract class ExpenseRepository {
  Future<List<Expense>> getAllExpenses();
  Future<Expense> getExpenseById(int id);
  Future<Expense> createExpense(Expense expense);
  Future<Expense> updateExpense(Expense expense);
  Future<void> deleteExpense(int id);
}

/// Implementation using Supabase Remote Data Source
class SupabaseExpenseRepository implements ExpenseRepository {
  final ExpenseRemoteDataSource _remote;

  SupabaseExpenseRepository({required ExpenseRemoteDataSource remote})
    : _remote = remote;

  @override
  Future<List<Expense>> getAllExpenses() async {
    return await _remote.getExpenses();
  }

  @override
  Future<Expense> getExpenseById(int id) async {
    return await _remote.getExpenseById(id);
  }

  @override
  Future<Expense> createExpense(Expense expense) async {
    return await _remote.addExpense(expense);
  }

  @override
  Future<Expense> updateExpense(Expense expense) async {
    return await _remote.updateExpense(expense);
  }

  @override
  Future<void> deleteExpense(int id) async {
    return await _remote.deleteExpense(id);
  }
}
