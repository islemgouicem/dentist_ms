import 'package:equatable/equatable.dart';
import 'package:dentist_ms/features/billing/models/payment.dart';

abstract class PaymentEvent extends Equatable {
  const PaymentEvent();

  @override
  List<Object?> get props => [];
}

class LoadPayments extends PaymentEvent {}

class LoadPaymentsByInvoice extends PaymentEvent {
  final int invoiceId;
  const LoadPaymentsByInvoice(this.invoiceId);

  @override
  List<Object?> get props => [invoiceId];
}

class LoadPaymentById extends PaymentEvent {
  final int paymentId;
  const LoadPaymentById(this.paymentId);

  @override
  List<Object?> get props => [paymentId];
}

class AddPayment extends PaymentEvent {
  final Payment payment;
  const AddPayment(this.payment);

  @override
  List<Object?> get props => [payment];
}

class UpdatePayment extends PaymentEvent {
  final Payment payment;
  const UpdatePayment(this.payment);

  @override
  List<Object?> get props => [payment];
}

class DeletePayment extends PaymentEvent {
  final int paymentId;
  const DeletePayment(this.paymentId);

  @override
  List<Object?> get props => [paymentId];
}
