import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dentist_ms/features/billing/bloc/invoice_event.dart';
import 'package:dentist_ms/features/billing/bloc/invoice_state.dart';
import 'package:dentist_ms/features/billing/repositories/invoice_repository.dart';

class InvoiceBloc extends Bloc<InvoiceEvent, InvoiceState> {
  final InvoiceRepository repository;

  InvoiceBloc({required this.repository}) : super(InvoicesInitial()) {
    on<LoadInvoices>(_onLoadInvoices);
    on<LoadInvoicesByPatient>(_onLoadInvoicesByPatient);
    on<LoadInvoiceById>(_onLoadInvoiceById);
    on<AddInvoice>(_onAddInvoice);
    on<UpdateInvoice>(_onUpdateInvoice);
    on<DeleteInvoice>(_onDeleteInvoice);
  }

  Future<void> _onLoadInvoices(
    LoadInvoices event,
    Emitter<InvoiceState> emit,
  ) async {
    emit(InvoicesLoadInProgress());
    try {
      final invoices = await repository.getAllInvoices();
      emit(InvoicesLoadSuccess(invoices));
    } catch (e) {
      emit(InvoicesOperationFailure(e.toString()));
    }
  }

  Future<void> _onLoadInvoicesByPatient(
    LoadInvoicesByPatient event,
    Emitter<InvoiceState> emit,
  ) async {
    emit(InvoicesLoadInProgress());
    try {
      final invoices = await repository.getInvoicesByPatientId(event.patientId);
      emit(InvoicesLoadSuccess(invoices));
    } catch (e) {
      emit(InvoicesOperationFailure(e.toString()));
    }
  }

  Future<void> _onLoadInvoiceById(
    LoadInvoiceById event,
    Emitter<InvoiceState> emit,
  ) async {
    emit(InvoicesLoadInProgress());
    try {
      final invoice = await repository.getInvoiceById(event.invoiceId);
      emit(InvoiceLoadSuccess(invoice));
    } catch (e) {
      emit(InvoicesOperationFailure(e.toString()));
    }
  }

  Future<void> _onAddInvoice(
    AddInvoice event,
    Emitter<InvoiceState> emit,
  ) async {
    emit(InvoicesLoadInProgress());
    try {
      await repository.createInvoice(event.invoice);
      // Reload the list directly instead of dispatching another event
      final invoices = await repository.getAllInvoices();
      emit(InvoicesLoadSuccess(invoices));
    } catch (e) {
      emit(InvoicesOperationFailure(e.toString()));
    }
  }

  Future<void> _onUpdateInvoice(
    UpdateInvoice event,
    Emitter<InvoiceState> emit,
  ) async {
    emit(InvoicesLoadInProgress());
    try {
      await repository.updateInvoice(event.invoice);
      // Reload the list directly instead of dispatching another event
      final invoices = await repository.getAllInvoices();
      emit(InvoicesLoadSuccess(invoices));
    } catch (e) {
      emit(InvoicesOperationFailure(e.toString()));
    }
  }

  Future<void> _onDeleteInvoice(
    DeleteInvoice event,
    Emitter<InvoiceState> emit,
  ) async {
    emit(InvoicesLoadInProgress());
    try {
      await repository.deleteInvoice(event.invoiceId);
      // Reload the list directly instead of dispatching another event
      final invoices = await repository.getAllInvoices();
      emit(InvoicesLoadSuccess(invoices));
    } catch (e) {
      emit(InvoicesOperationFailure(e.toString()));
    }
  }
}
