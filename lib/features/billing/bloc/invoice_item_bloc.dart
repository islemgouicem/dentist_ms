import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dentist_ms/features/billing/bloc/invoice_item_event.dart';
import 'package:dentist_ms/features/billing/bloc/invoice_item_state.dart';
import 'package:dentist_ms/features/billing/repositories/invoice_item_repository.dart';
import 'package:dentist_ms/features/billing/data/invoice_remote.dart';

class InvoiceItemBloc extends Bloc<InvoiceItemEvent, InvoiceItemState> {
  final InvoiceItemRepository repository;
  final InvoiceRemoteDataSource invoiceDataSource;

  InvoiceItemBloc({
    required this.repository,
    InvoiceRemoteDataSource? invoiceDataSource,
  }) : invoiceDataSource = invoiceDataSource ?? InvoiceRemoteDataSource(),
       super(InvoiceItemsInitial()) {
    on<LoadInvoiceItems>(_onLoadInvoiceItems);
    on<LoadInvoiceItemsByInvoice>(_onLoadInvoiceItemsByInvoice);
    on<LoadInvoiceItemById>(_onLoadInvoiceItemById);
    on<AddInvoiceItem>(_onAddInvoiceItem);
    on<UpdateInvoiceItem>(_onUpdateInvoiceItem);
    on<DeleteInvoiceItem>(_onDeleteInvoiceItem);
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
      final createdItem = await repository.createInvoiceItem(event.item);

      // Trigger automatic recalculation via database trigger
      // The trigger will handle this, but we can also call it explicitly
      if (event.item.invoiceId != null) {
        await invoiceDataSource.recalculateInvoiceTotals(event.item.invoiceId!);
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

      // Trigger recalculation
      if (event.item.invoiceId != null) {
        await invoiceDataSource.recalculateInvoiceTotals(event.item.invoiceId!);
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

      // Trigger recalculation
      if (invoiceId != null) {
        await invoiceDataSource.recalculateInvoiceTotals(invoiceId);
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
