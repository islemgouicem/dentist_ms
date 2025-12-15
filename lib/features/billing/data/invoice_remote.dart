import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:dentist_ms/features/billing/models/invoice.dart';

class InvoiceRemoteDataSource {
  final SupabaseClient _client;

  // Uses the singleton Supabase instance by default
  InvoiceRemoteDataSource({SupabaseClient? client})
    : _client = client ?? Supabase.instance.client;

  /// Get all invoices with patient and treatment information
  Future<List<Invoice>> getInvoices() async {
    try {
      final response = await _client
          .from('invoices')
          .select('''
            *,
            patients(first_name, last_name),
            invoice_items(
              treatments(name)
            )
          ''')
          .order('created_at', ascending: false);

      return (response as List)
          .map((json) => Invoice.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch invoices: $e');
    }
  }

  /// Get invoices for a specific patient
  Future<List<Invoice>> getInvoicesByPatientId(int patientId) async {
    try {
      final response = await _client
          .from('invoices')
          .select('''
            *,
            patients(first_name, last_name),
            invoice_items(
              treatments(name)
            )
          ''')
          .eq('patient_id', patientId)
          .order('created_at', ascending: false);

      return (response as List)
          .map((json) => Invoice.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch patient invoices: $e');
    }
  }

  /// Get a specific invoice by ID
  Future<Invoice> getInvoiceById(int id) async {
    try {
      final response = await _client
          .from('invoices')
          .select('''
            *,
            patients(first_name, last_name),
            invoice_items(
              treatments(name)
            )
          ''')
          .eq('id', id)
          .single();

      return Invoice.fromJson(response as Map<String, dynamic>);
    } catch (e) {
      throw Exception('Failed to fetch invoice: $e');
    }
  }

  /// Create a new invoice
  Future<Invoice> addInvoice(Invoice invoice) async {
    try {
      final response = await _client
          .from('invoices')
          .insert(invoice.toJson())
          .select('''
            *,
            patients(first_name, last_name),
            invoice_items(
              treatments(name)
            )
          ''')
          .single();

      return Invoice.fromJson(response as Map<String, dynamic>);
    } catch (e) {
      throw Exception('Failed to create invoice: $e');
    }
  }

  /// Update an existing invoice
  Future<Invoice> updateInvoice(Invoice invoice) async {
    try {
      final response = await _client
          .from('invoices')
          .update(invoice.toJson())
          .eq('id', invoice.id!)
          .select('''
            *,
            patients(first_name, last_name),
            invoice_items(
              treatments(name)
            )
          ''')
          .single();

      return Invoice.fromJson(response as Map<String, dynamic>);
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

  /// Recalculate invoice totals from invoice items
  /// This calls the Supabase RPC function
  Future<void> recalculateInvoiceTotals(int invoiceId) async {
    try {
      await _client.rpc(
        'recalculate_invoice_totals',
        params: {'p_invoice_id': invoiceId},
      );
    } catch (e) {
      throw Exception('Failed to recalculate invoice totals: $e');
    }
  }
}
