import 'package:equatable/equatable.dart';
import 'package:dentist_ms/features/billing/models/invoice.dart';

abstract class InvoiceEvent extends Equatable {
  const InvoiceEvent();

  @override
  List<Object?> get props => [];
}

class LoadInvoices extends InvoiceEvent {}

class LoadInvoicesByPatient extends InvoiceEvent {
  final int patientId;
  const LoadInvoicesByPatient(this.patientId);

  @override
  List<Object?> get props => [patientId];
}

class LoadInvoiceById extends InvoiceEvent {
  final int invoiceId;
  const LoadInvoiceById(this.invoiceId);

  @override
  List<Object?> get props => [invoiceId];
}

class AddInvoice extends InvoiceEvent {
  final Invoice invoice;

  const AddInvoice(this.invoice);

  @override
  List<Object?> get props => [invoice];
}

class UpdateInvoice extends InvoiceEvent {
  final Invoice invoice;
  const UpdateInvoice(this.invoice);

  @override
  List<Object?> get props => [invoice];
}

class DeleteInvoice extends InvoiceEvent {
  final int invoiceId;
  const DeleteInvoice(this.invoiceId);

  @override
  List<Object?> get props => [invoiceId];
}
