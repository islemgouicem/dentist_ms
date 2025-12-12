import 'package:equatable/equatable.dart';
import 'package:dentist_ms/features/billing/models/payment.dart';

abstract class PaymentState extends Equatable {
  const PaymentState();

  @override
  List<Object?> get props => [];
}

class PaymentsInitial extends PaymentState {}

class PaymentsLoadInProgress extends PaymentState {}

class PaymentsLoadSuccess extends PaymentState {
  final List<Payment> payments;

  const PaymentsLoadSuccess(this.payments);

  @override
  List<Object?> get props => [payments];
}

class PaymentLoadSuccess extends PaymentState {
  final Payment payment;

  const PaymentLoadSuccess(this.payment);

  @override
  List<Object?> get props => [payment];
}

class PaymentsOperationFailure extends PaymentState {
  final String message;

  const PaymentsOperationFailure(this.message);

  @override
  List<Object?> get props => [message];
}
