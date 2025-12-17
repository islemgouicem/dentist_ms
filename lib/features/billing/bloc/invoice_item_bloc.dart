import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dentist_ms/features/billing/bloc/invoice_item_event.dart';
import 'package:dentist_ms/features/billing/bloc/invoice_item_state.dart';
import 'package:dentist_ms/features/billing/repositories/invoice_item_repository.dart';
import 'package:dentist_ms/features/billing/repositories/payment_repository.dart';
import 'package:dentist_ms/features/billing/data/invoice_remote.dart';
import 'package:dentist_ms/features/billing/data/payment_remote.dart';

class InvoiceItemBloc extends Bloc<InvoiceItemEvent, InvoiceItemState> {
  final InvoiceItemRepository repository;
  final InvoiceRemoteDataSource invoiceDataSource;
  final PaymentRepository paymentRepository;

  InvoiceItemBloc({
    required this.repository,
    InvoiceRemoteDataSource? invoiceDataSource,
    PaymentRepository? paymentRepository,
  }) : invoiceDataSource = invoiceDataSource ?? InvoiceRemoteDataSource(),
       paymentRepository =
           paymentRepository ??
           SupabasePaymentRepository(remote: PaymentRemoteDataSource()),
       super(InvoiceItemsInitial()) {
    on<LoadInvoiceItems>(_onLoadInvoiceItems);
    on<LoadInvoiceItemsByInvoice>(_onLoadInvoiceItemsByInvoice);
    on<LoadInvoiceItemById>(_onLoadInvoiceItemById);
    on<AddInvoiceItem>(_onAddInvoiceItem);
    on<UpdateInvoiceItem>(_onUpdateInvoiceItem);
    on<DeleteInvoiceItem>(_onDeleteInvoiceItem);
  }

  /// Recalculate invoice totals and update status in a single operation
  Future<void> _recalculateInvoiceTotalsAndStatus(int invoiceId) async {
    try {
      // Get all items for this invoice
      final items = await repository.getInvoiceItemsByInvoiceId(invoiceId);

      // Calculate subtotal from all items
      final subtotal = items.fold<double>(
        0.0,
        (sum, item) => sum + (item.totalPrice ?? 0.0),
      );

      // Get current invoice to preserve discount
      final invoice = await invoiceDataSource.getInvoiceById(invoiceId);
      final discount = invoice.discountAmount ?? 0.0;

      // Calculate total
      final total = subtotal - discount;

      // Get all payments to determine status
      final payments = await paymentRepository.getPaymentsByInvoiceId(invoiceId);
      final totalPaid = payments.fold<double>(
        0.0,
        (sum, payment) => sum + (payment.amount ?? 0.0),
      );

      // Determine new status based on payments vs new total
      String newStatus;
      if (totalPaid <= 0) {
        newStatus = 'unpaid';
      } else if (totalPaid >= total) {
        newStatus = 'paid';
      } else {
        newStatus = 'partial';
      }

      // Update invoice with new totals and status in one go
      final updatedInvoice = invoice.copyWith(
        subtotalAmount: subtotal,
        totalAmount: total,
        status: newStatus,
      );

      await invoiceDataSource.updateInvoice(updatedInvoice);
    } catch (e) {
      print('Warning: Failed to recalculate invoice totals and status: $e');
    }
  }

  Future<void> _onLoadInvoiceItems(
    LoadInvoiceItems event,
    Emitter<InvoiceItemState> emit,
  ) async {
    emit(InvoiceItemsLoadInProgress());
    try {
      final items = await repository.getAllInvoiceItems();
      emit(InvoiceItemsLoadSuccess(items));
    } catch (e) {
      emit(InvoiceItemsOperationFailure(e.toString()));
    }
  }

  Future<void> _onLoadInvoiceItemsByInvoice(
    LoadInvoiceItemsByInvoice event,
    Emitter<InvoiceItemState> emit,
  ) async {
    emit(InvoiceItemsLoadInProgress());
    try {
      final items = await repository.getInvoiceItemsByInvoiceId(
        event.invoiceId,
      );
      emit(InvoiceItemsLoadSuccess(items));
    } catch (e) {
      emit(InvoiceItemsOperationFailure(e.toString()));
    }
  }

  Future<void> _onLoadInvoiceItemById(
    LoadInvoiceItemById event,
    Emitter<InvoiceItemState> emit,
  ) async {
    emit(InvoiceItemsLoadInProgress());
    try {
      final item = await repository.getInvoiceItemById(event.itemId);
      emit(InvoiceItemLoadSuccess(item));
    } catch (e) {
      emit(InvoiceItemsOperationFailure(e.toString()));
    }
  }

  Future<void> _onAddInvoiceItem(
    AddInvoiceItem event,
    Emitter<InvoiceItemState> emit,
  ) async {
    emit(InvoiceItemsLoadInProgress());
    try {
      await repository.createInvoiceItem(event.item);

      // Recalculate invoice totals and update status in one operation
      if (event.item.invoiceId != null) {
        await _recalculateInvoiceTotalsAndStatus(event.item.invoiceId!);
      }

      // Reload the list for the specific invoice
      if (event.item.invoiceId != null) {
        final items = await repository.getInvoiceItemsByInvoiceId(
          event.item.invoiceId!,
        );
        emit(InvoiceItemsLoadSuccess(items));
      } else {
        final items = await repository.getAllInvoiceItems();
        emit(InvoiceItemsLoadSuccess(items));
      }
    } catch (e) {
      emit(InvoiceItemsOperationFailure(e.toString()));
    }
  }

  Future<void> _onUpdateInvoiceItem(
    UpdateInvoiceItem event,
    Emitter<InvoiceItemState> emit,
  ) async {
    emit(InvoiceItemsLoadInProgress());
    try {
      await repository.updateInvoiceItem(event.item);

      // Recalculate invoice totals and update status in one operation
      if (event.item.invoiceId != null) {
        await _recalculateInvoiceTotalsAndStatus(event.item.invoiceId!);
      }

      // Reload the list
      if (event.item.invoiceId != null) {
        final items = await repository.getInvoiceItemsByInvoiceId(
          event.item.invoiceId!,
        );
        emit(InvoiceItemsLoadSuccess(items));
      } else {
        final items = await repository.getAllInvoiceItems();
        emit(InvoiceItemsLoadSuccess(items));
      }
    } catch (e) {
      emit(InvoiceItemsOperationFailure(e.toString()));
    }
  }

  Future<void> _onDeleteInvoiceItem(
    DeleteInvoiceItem event,
    Emitter<InvoiceItemState> emit,
  ) async {
    emit(InvoiceItemsLoadInProgress());
    try {
      // Get the item first to know which invoice to recalculate
      final item = await repository.getInvoiceItemById(event.itemId);
      final invoiceId = item.invoiceId;

      // Delete the item
      await repository.deleteInvoiceItem(event.itemId);

      // Recalculate invoice totals and update status in one operation
      if (invoiceId != null) {
        await _recalculateInvoiceTotalsAndStatus(invoiceId);
      }

      // Reload the list
      if (invoiceId != null) {
        final items = await repository.getInvoiceItemsByInvoiceId(invoiceId);
        emit(InvoiceItemsLoadSuccess(items));
      } else {
        final items = await repository.getAllInvoiceItems();
        emit(InvoiceItemsLoadSuccess(items));
      }
    } catch (e) {
      emit(InvoiceItemsOperationFailure(e.toString()));
    }
  }
}
