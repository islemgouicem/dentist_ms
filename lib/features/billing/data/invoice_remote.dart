import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:dentist_ms/features/billing/models/invoice.dart';

class InvoiceRemoteDataSource {
  final SupabaseClient _client;

  // Uses the singleton Supabase instance by default
  InvoiceRemoteDataSource({SupabaseClient? client})
    : _client = client ?? Supabase.instance.client;

  /// Fetch all invoices ordered by creation date
  Future<List<Invoice>> getInvoices() async {
    try {
      final response = await _client
          .from('invoices')
          .select(
            '*, patients(first_name, last_name), invoice_items(treatments(name))',
          )
          .order('created_at', ascending: false);

      return (response as List).map((json) => Invoice.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to load invoices: $e');
    }
  }

  /// Fetch invoices by patient ID
  Future<List<Invoice>> getInvoicesByPatientId(int patientId) async {
    try {
      final response = await _client
          .from('invoices')
          .select()
          .eq('patient_id', patientId)
          .order('created_at', ascending: false);

      return (response as List).map((json) => Invoice.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to load invoices for patient: $e');
    }
  }

  /// Fetch a single invoice by ID
  Future<Invoice> getInvoiceById(int id) async {
    try {
      final response = await _client
          .from('invoices')
          .select()
          .eq('id', id)
          .single();

      return Invoice.fromJson(response);
    } catch (e) {
      throw Exception('Failed to load invoice: $e');
    }
  }

  /// Add a new invoice
  Future<Invoice> addInvoice(Invoice invoice) async {
    try {
      final response = await _client
          .from('invoices')
          .insert(invoice.toJson())
          .select()
          .single();

      return Invoice.fromJson(response);
    } catch (e) {
      throw Exception('Failed to add invoice: $e');
    }
  }

  /// Update an existing invoice
  Future<Invoice> updateInvoice(Invoice invoice) async {
    if (invoice.id == null)
      throw Exception('Invoice ID is required for update');

    try {
      final response = await _client
          .from('invoices')
          .update(invoice.toJson())
          .eq('id', invoice.id!)
          .select()
          .single();

      return Invoice.fromJson(response);
    } catch (e) {
      throw Exception('Failed to update invoice: $e');
    }
  }

  /// Delete an invoice
  Future<void> deleteInvoice(int id) async {
    try {
      await _client.from('invoices').delete().eq('id', id);
    } catch (e) {
      throw Exception('Failed to delete invoice: $e');
    }
  }
}
