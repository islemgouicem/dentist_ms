import 'package:dentist_ms/features/billing/data/payment_remote.dart';
import 'package:dentist_ms/features/billing/models/payment.dart';

/// Abstract Interface for the Repository
abstract class PaymentRepository {
  Future<List<Payment>> getAllPayments();
  Future<List<Payment>> getPaymentsByInvoiceId(int invoiceId);
  Future<Payment> getPaymentById(int id);
  Future<Payment> createPayment(Payment payment);
  Future<Payment> updatePayment(Payment payment);
  Future<void> deletePayment(int id);
}

/// Implementation using Supabase Remote Data Source
class SupabasePaymentRepository implements PaymentRepository {
  final PaymentRemoteDataSource _remote;

  SupabasePaymentRepository({required PaymentRemoteDataSource remote})
    : _remote = remote;

  @override
  Future<List<Payment>> getAllPayments() async {
    return await _remote.getPayments();
  }

  @override
  Future<List<Payment>> getPaymentsByInvoiceId(int invoiceId) async {
    return await _remote.getPaymentsByInvoiceId(invoiceId);
  }

  @override
  Future<Payment> getPaymentById(int id) async {
    return await _remote.getPaymentById(id);
  }

  @override
  Future<Payment> createPayment(Payment payment) async {
    return await _remote.addPayment(payment);
  }

  @override
  Future<Payment> updatePayment(Payment payment) async {
    return await _remote.updatePayment(payment);
  }

  @override
  Future<void> deletePayment(int id) async {
    return await _remote.deletePayment(id);
  }
}
