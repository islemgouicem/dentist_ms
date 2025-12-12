import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dentist_ms/features/billing/bloc/invoice_item_event.dart';
import 'package:dentist_ms/features/billing/bloc/invoice_item_state.dart';
import 'package:dentist_ms/features/billing/repositories/invoice_item_repository.dart';

class InvoiceItemBloc extends Bloc<InvoiceItemEvent, InvoiceItemState> {
  final InvoiceItemRepository repository;

  InvoiceItemBloc({required this.repository}) : super(InvoiceItemsInitial()) {
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
      await repository.createInvoiceItem(event.item);
      // Reload the list directly instead of dispatching another event
      final items = await repository.getAllInvoiceItems();
      emit(InvoiceItemsLoadSuccess(items));
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
      // Reload the list directly instead of dispatching another event
      final items = await repository.getAllInvoiceItems();
      emit(InvoiceItemsLoadSuccess(items));
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
      await repository.deleteInvoiceItem(event.itemId);
      // Reload the list directly instead of dispatching another event
      final items = await repository.getAllInvoiceItems();
      emit(InvoiceItemsLoadSuccess(items));
    } catch (e) {
      emit(InvoiceItemsOperationFailure(e.toString()));
    }
  }
}
