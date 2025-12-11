import 'package:dentist_ms/features/billing/data/invoice_item_remote.dart';
import 'package:dentist_ms/features/billing/models/invoice_item.dart';

/// Abstract Interface for the Repository
abstract class InvoiceItemRepository {
  Future<List<InvoiceItem>> getAllInvoiceItems();
  Future<List<InvoiceItem>> getInvoiceItemsByInvoiceId(int invoiceId);
  Future<InvoiceItem> getInvoiceItemById(int id);
  Future<InvoiceItem> createInvoiceItem(InvoiceItem item);
  Future<InvoiceItem> updateInvoiceItem(InvoiceItem item);
  Future<void> deleteInvoiceItem(int id);
}

/// Implementation using Supabase Remote Data Source
class SupabaseInvoiceItemRepository implements InvoiceItemRepository {
  final InvoiceItemRemoteDataSource _remote;

  SupabaseInvoiceItemRepository({required InvoiceItemRemoteDataSource remote})
    : _remote = remote;

  @override
  Future<List<InvoiceItem>> getAllInvoiceItems() async {
    return await _remote.getInvoiceItems();
  }

  @override
  Future<List<InvoiceItem>> getInvoiceItemsByInvoiceId(int invoiceId) async {
    return await _remote.getInvoiceItemsByInvoiceId(invoiceId);
  }

  @override
  Future<InvoiceItem> getInvoiceItemById(int id) async {
    return await _remote.getInvoiceItemById(id);
  }

  @override
  Future<InvoiceItem> createInvoiceItem(InvoiceItem item) async {
    return await _remote.addInvoiceItem(item);
  }

  @override
  Future<InvoiceItem> updateInvoiceItem(InvoiceItem item) async {
    return await _remote.updateInvoiceItem(item);
  }

  @override
  Future<void> deleteInvoiceItem(int id) async {
    return await _remote.deleteInvoiceItem(id);
  }
}
