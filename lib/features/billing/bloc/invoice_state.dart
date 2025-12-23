import 'package:equatable/equatable.dart';
import 'package:dentist_ms/features/billing/models/invoice.dart';

abstract class InvoiceState extends Equatable {
  const InvoiceState();

  @override
  List<Object?> get props => [];
}

class InvoicesInitial extends InvoiceState {}

class InvoicesLoadInProgress extends InvoiceState {}

class InvoicesLoadSuccess extends InvoiceState {
  final List<Invoice> invoices;

  const InvoicesLoadSuccess(this.invoices);

  @override
  List<Object?> get props => [invoices];
}

class InvoiceLoadSuccess extends InvoiceState {
  final Invoice invoice;

  const InvoiceLoadSuccess(this.invoice);

  @override
  List<Object?> get props => [invoice];
}

class InvoicesOperationFailure extends InvoiceState {
  final String message;

  const InvoicesOperationFailure(this.message);

  @override
  List<Object?> get props => [message];
}
