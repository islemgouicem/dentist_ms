import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dentist_ms/features/billing/bloc/payment_event.dart';
import 'package:dentist_ms/features/billing/bloc/payment_state.dart';
import 'package:dentist_ms/features/billing/repositories/payment_repository.dart';
import 'package:dentist_ms/features/billing/data/invoice_remote.dart';

class PaymentBloc extends Bloc<PaymentEvent, PaymentState> {
  final PaymentRepository repository;
  final InvoiceRemoteDataSource invoiceDataSource;

  PaymentBloc({
    required this.repository,
    InvoiceRemoteDataSource? invoiceDataSource,
  }) : invoiceDataSource = invoiceDataSource ?? InvoiceRemoteDataSource(),
       super(PaymentsInitial()) {
    on<LoadPayments>(_onLoadPayments);
    on<LoadPaymentsByInvoice>(_onLoadPaymentsByInvoice);
    on<LoadPaymentById>(_onLoadPaymentById);
    on<AddPayment>(_onAddPayment);
    on<UpdatePayment>(_onUpdatePayment);
    on<DeletePayment>(_onDeletePayment);
  }

  /// Update invoice status based on total payments vs total amount
  Future<void> _updateInvoiceStatus(int invoiceId) async {
    try {
      // Get all payments for this invoice
      final payments = await repository.getPaymentsByInvoiceId(invoiceId);
      final totalPaid = payments.fold<double>(
        0.0,
        (sum, payment) => sum + (payment.amount ?? 0.0),
      );

      // Get invoice to compare with total amount
      final invoice = await invoiceDataSource.getInvoiceById(invoiceId);
      final totalAmount = invoice.totalAmount ?? 0.0;

      // Determine new status
      String newStatus;
      if (totalPaid <= 0) {
        newStatus = 'unpaid';
      } else if (totalPaid >= totalAmount) {
        newStatus = 'paid';
      } else {
        newStatus = 'partial';
      }

      // Update invoice status if changed
      if (invoice.status != newStatus) {
        final updatedInvoice = invoice.copyWith(status: newStatus);
        await invoiceDataSource.updateInvoice(updatedInvoice);
      }
    } catch (e) {
      print('Warning: Failed to update invoice status: $e');
    }
  }

  Future<void> _onLoadPayments(
    LoadPayments event,
    Emitter<PaymentState> emit,
  ) async {
    emit(PaymentsLoadInProgress());
    try {
      final payments = await repository.getAllPayments();
      emit(PaymentsLoadSuccess(payments));
    } catch (e) {
      emit(PaymentsOperationFailure(e.toString()));
    }
  }

  Future<void> _onLoadPaymentsByInvoice(
    LoadPaymentsByInvoice event,
    Emitter<PaymentState> emit,
  ) async {
    emit(PaymentsLoadInProgress());
    try {
      final payments = await repository.getPaymentsByInvoiceId(event.invoiceId);
      emit(PaymentsLoadSuccess(payments));
    } catch (e) {
      emit(PaymentsOperationFailure(e.toString()));
    }
  }

  Future<void> _onLoadPaymentById(
    LoadPaymentById event,
    Emitter<PaymentState> emit,
  ) async {
    emit(PaymentsLoadInProgress());
    try {
      final payment = await repository.getPaymentById(event.paymentId);
      emit(PaymentLoadSuccess(payment));
    } catch (e) {
      emit(PaymentsOperationFailure(e.toString()));
    }
  }

  Future<void> _onAddPayment(
    AddPayment event,
    Emitter<PaymentState> emit,
  ) async {
    emit(PaymentsLoadInProgress());
    try {
      await repository.createPayment(event.payment);

      // Update invoice status based on payments
      if (event.payment.invoiceId != null) {
        await _updateInvoiceStatus(event.payment.invoiceId!);
      }

      // Reload the list directly instead of dispatching another event
      final payments = await repository.getAllPayments();
      emit(PaymentsLoadSuccess(payments));
    } catch (e) {
      emit(PaymentsOperationFailure(e.toString()));
    }
  }

  Future<void> _onUpdatePayment(
    UpdatePayment event,
    Emitter<PaymentState> emit,
  ) async {
    emit(PaymentsLoadInProgress());
    try {
      await repository.updatePayment(event.payment);

      // Update invoice status based on payments
      if (event.payment.invoiceId != null) {
        await _updateInvoiceStatus(event.payment.invoiceId!);
      }

      // Reload the list directly instead of dispatching another event
      final payments = await repository.getAllPayments();
      emit(PaymentsLoadSuccess(payments));
    } catch (e) {
      emit(PaymentsOperationFailure(e.toString()));
    }
  }

  Future<void> _onDeletePayment(
    DeletePayment event,
    Emitter<PaymentState> emit,
  ) async {
    emit(PaymentsLoadInProgress());
    try {
      // Get the payment first to know which invoice to update
      final payment = await repository.getPaymentById(event.paymentId);
      final invoiceId = payment.invoiceId;

      await repository.deletePayment(event.paymentId);

      // Update invoice status based on remaining payments
      if (invoiceId != null) {
        await _updateInvoiceStatus(invoiceId);
      }

      // Reload the list directly instead of dispatching another event
      final payments = await repository.getAllPayments();
      emit(PaymentsLoadSuccess(payments));
    } catch (e) {
      emit(PaymentsOperationFailure(e.toString()));
    }
  }
}
