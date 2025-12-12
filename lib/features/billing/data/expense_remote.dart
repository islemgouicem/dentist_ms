import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:dentist_ms/features/billing/models/expense.dart';

class ExpenseRemoteDataSource {
  final SupabaseClient _client;

  ExpenseRemoteDataSource({SupabaseClient? client})
    : _client = client ?? Supabase.instance.client;

  /// Fetch all expenses ordered by date
  Future<List<Expense>> getExpenses() async {
    try {
      final response = await _client
          .from('expenses')
          .select('*, expense_categories(name)')
          .order('expense_date', ascending: false);

      return (response as List).map((json) => Expense.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to load expenses: $e');
    }
  }

  /// Fetch a single expense by ID
  Future<Expense> getExpenseById(int id) async {
    try {
      final response = await _client
          .from('expenses')
          .select()
          .eq('id', id)
          .single();

      return Expense.fromJson(response);
    } catch (e) {
      throw Exception('Failed to load expense: $e');
    }
  }

  /// Add a new expense
  Future<Expense> addExpense(Expense expense) async {
    try {
      final response = await _client
          .from('expenses')
          .insert(expense.toJson())
          .select()
          .single();

      return Expense.fromJson(response);
    } catch (e) {
      throw Exception('Failed to add expense: $e');
    }
  }

  /// Update an existing expense
  Future<Expense> updateExpense(Expense expense) async {
    if (expense.id == null) {
      throw Exception('Expense ID is required for update');
    }

    try {
      final response = await _client
          .from('expenses')
          .update(expense.toJson())
          .eq('id', expense.id!)
          .select()
          .single();

      return Expense.fromJson(response);
    } catch (e) {
      throw Exception('Failed to update expense: $e');
    }
  }

  /// Delete an expense
  Future<void> deleteExpense(int id) async {
    try {
      await _client.from('expenses').delete().eq('id', id);
    } catch (e) {
      throw Exception('Failed to delete expense: $e');
    }
  }
}
