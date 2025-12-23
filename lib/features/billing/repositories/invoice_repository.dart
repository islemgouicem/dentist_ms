import 'package:dentist_ms/features/billing/data/invoice_remote.dart';
import 'package:dentist_ms/features/billing/models/invoice.dart';

/// Abstract Interface for the Repository
abstract class InvoiceRepository {
  Future<List<Invoice>> getAllInvoices();
  Future<List<Invoice>> getInvoicesByPatientId(int patientId);
  Future<Invoice> getInvoiceById(int id);
  Future<Invoice> createInvoice(Invoice invoice);
  Future<Invoice> updateInvoice(Invoice invoice);
  Future<void> deleteInvoice(int id);
}

/// Implementation using Supabase Remote Data Source
class SupabaseInvoiceRepository implements InvoiceRepository {
  final InvoiceRemoteDataSource _remote;

  SupabaseInvoiceRepository({required InvoiceRemoteDataSource remote})
    : _remote = remote;

  @override
  Future<List<Invoice>> getAllInvoices() async {
    return await _remote.getInvoices();
  }

  @override
  Future<List<Invoice>> getInvoicesByPatientId(int patientId) async {
    return await _remote.getInvoicesByPatientId(patientId);
  }

  @override
  Future<Invoice> getInvoiceById(int id) async {
    return await _remote.getInvoiceById(id);
  }

  @override
  Future<Invoice> createInvoice(Invoice invoice) async {
    return await _remote.addInvoice(invoice);
  }

  @override
  Future<Invoice> updateInvoice(Invoice invoice) async {
    return await _remote.updateInvoice(invoice);
  }

  @override
  Future<void> deleteInvoice(int id) async {
    return await _remote.deleteInvoice(id);
  }
}
