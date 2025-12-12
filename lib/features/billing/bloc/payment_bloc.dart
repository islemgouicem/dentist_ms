import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dentist_ms/features/billing/bloc/payment_event.dart';
import 'package:dentist_ms/features/billing/bloc/payment_state.dart';
import 'package:dentist_ms/features/billing/repositories/payment_repository.dart';

class PaymentBloc extends Bloc<PaymentEvent, PaymentState> {
  final PaymentRepository repository;

  PaymentBloc({required this.repository}) : super(PaymentsInitial()) {
    on<LoadPayments>(_onLoadPayments);
    on<LoadPaymentsByInvoice>(_onLoadPaymentsByInvoice);
    on<LoadPaymentById>(_onLoadPaymentById);
    on<AddPayment>(_onAddPayment);
    on<UpdatePayment>(_onUpdatePayment);
    on<DeletePayment>(_onDeletePayment);
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
      await repository.deletePayment(event.paymentId);
      // Reload the list directly instead of dispatching another event
      final payments = await repository.getAllPayments();
      emit(PaymentsLoadSuccess(payments));
    } catch (e) {
      emit(PaymentsOperationFailure(e.toString()));
    }
  }
}
