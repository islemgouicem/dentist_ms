import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:dentist_ms/features/billing/models/invoice_item.dart';

class InvoiceItemRemoteDataSource {
  final SupabaseClient _client;

  // Uses the singleton Supabase instance by default
  InvoiceItemRemoteDataSource({SupabaseClient? client})
    : _client = client ?? Supabase.instance.client;

  /// Fetch all invoice items
  Future<List<InvoiceItem>> getInvoiceItems() async {
    try {
      final response = await _client
          .from('invoice_items')
          .select()
          .order('id', ascending: true);

      return (response as List)
          .map((json) => InvoiceItem.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception('Failed to load invoice items: $e');
    }
  }

  /// Fetch invoice items by invoice ID
  Future<List<InvoiceItem>> getInvoiceItemsByInvoiceId(int invoiceId) async {
    try {
      final response = await _client
          .from('invoice_items')
          .select('*, treatments(name)')
          .eq('invoice_id', invoiceId)
          .order('id', ascending: true);

      return (response as List)
          .map((json) => InvoiceItem.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception('Failed to load invoice items for invoice: $e');
    }
  }

  /// Fetch a single invoice item by ID
  Future<InvoiceItem> getInvoiceItemById(int id) async {
    try {
      final response = await _client
          .from('invoice_items')
          .select('*, treatments(name)')
          .eq('id', id)
          .single();

      return InvoiceItem.fromJson(response);
    } catch (e) {
      throw Exception('Failed to load invoice item: $e');
    }
  }

  /// Add a new invoice item
  Future<InvoiceItem> addInvoiceItem(InvoiceItem item) async {
    try {
      final response = await _client
          .from('invoice_items')
          .insert(item.toJson())
          .select('*, treatments(name)')
          .single();

      return InvoiceItem.fromJson(response);
    } catch (e) {
      throw Exception('Failed to add invoice item: $e');
    }
  }

  /// Update an existing invoice item
  Future<InvoiceItem> updateInvoiceItem(InvoiceItem item) async {
    if (item.id == null)
      throw Exception('Invoice item ID is required for update');

    try {
      final response = await _client
          .from('invoice_items')
          .update(item.toJson())
          .eq('id', item.id!)
          .select('*, treatments(name)')
          .single();

      return InvoiceItem.fromJson(response);
    } catch (e) {
      throw Exception('Failed to update invoice item: $e');
    }
  }

  /// Delete an invoice item
  Future<void> deleteInvoiceItem(int id) async {
    try {
      await _client.from('invoice_items').delete().eq('id', id);
    } catch (e) {
      throw Exception('Failed to delete invoice item: $e');
    }
  }
}
