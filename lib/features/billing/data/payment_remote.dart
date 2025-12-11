import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:dentist_ms/features/billing/models/payment.dart';

class PaymentRemoteDataSource {
  final SupabaseClient _client;

  // Uses the singleton Supabase instance by default
  PaymentRemoteDataSource({SupabaseClient? client})
    : _client = client ?? Supabase.instance.client;

  /// Fetch all payments ordered by payment date
  Future<List<Payment>> getPayments() async {
    try {
      final response = await _client
          .from('payments')
          .select()
          .order('payment_date', ascending: false);

      return (response as List).map((json) => Payment.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to load payments: $e');
    }
  }

  /// Fetch payments by invoice ID
  Future<List<Payment>> getPaymentsByInvoiceId(int invoiceId) async {
    try {
      final response = await _client
          .from('payments')
          .select()
          .eq('invoice_id', invoiceId)
          .order('payment_date', ascending: false);

      return (response as List).map((json) => Payment.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to load payments for invoice: $e');
    }
  }

  /// Fetch a single payment by ID
  Future<Payment> getPaymentById(int id) async {
    try {
      final response = await _client
          .from('payments')
          .select()
          .eq('id', id)
          .single();

      return Payment.fromJson(response);
    } catch (e) {
      throw Exception('Failed to load payment: $e');
    }
  }

  /// Add a new payment
  Future<Payment> addPayment(Payment payment) async {
    try {
      final response = await _client
          .from('payments')
          .insert(payment.toJson())
          .select()
          .single();

      return Payment.fromJson(response);
    } catch (e) {
      throw Exception('Failed to add payment: $e');
    }
  }

  /// Update an existing payment
  Future<Payment> updatePayment(Payment payment) async {
    if (payment.id == null)
      throw Exception('Payment ID is required for update');

    try {
      final response = await _client
          .from('payments')
          .update(payment.toJson())
          .eq('id', payment.id!)
          .select()
          .single();

      return Payment.fromJson(response);
    } catch (e) {
      throw Exception('Failed to update payment: $e');
    }
  }

  /// Delete a payment
  Future<void> deletePayment(int id) async {
    try {
      await _client.from('payments').delete().eq('id', id);
    } catch (e) {
      throw Exception('Failed to delete payment: $e');
    }
  }
}
