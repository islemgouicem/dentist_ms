import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:dentist_ms/features/billing/models/expense_category.dart';

class ExpenseCategoryRemoteDataSource {
  final SupabaseClient _client;

  ExpenseCategoryRemoteDataSource({SupabaseClient? client})
    : _client = client ?? Supabase.instance.client;

  /// Fetch all expense categories
  Future<List<ExpenseCategory>> getExpenseCategories() async {
    try {
      final response = await _client
          .from('expense_categories')
          .select()
          .order('name', ascending: true);

      return (response as List)
          .map((json) => ExpenseCategory.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception('Failed to load expense categories: $e');
    }
  }
}
