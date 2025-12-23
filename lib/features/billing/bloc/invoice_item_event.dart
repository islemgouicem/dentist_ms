import 'package:equatable/equatable.dart';
import 'package:dentist_ms/features/billing/models/invoice_item.dart';

abstract class InvoiceItemEvent extends Equatable {
  const InvoiceItemEvent();

  @override
  List<Object?> get props => [];
}

class LoadInvoiceItems extends InvoiceItemEvent {}

class LoadInvoiceItemsByInvoice extends InvoiceItemEvent {
  final int invoiceId;
  const LoadInvoiceItemsByInvoice(this.invoiceId);

  @override
  List<Object?> get props => [invoiceId];
}

class LoadInvoiceItemById extends InvoiceItemEvent {
  final int itemId;
  const LoadInvoiceItemById(this.itemId);

  @override
  List<Object?> get props => [itemId];
}

class AddInvoiceItem extends InvoiceItemEvent {
  final InvoiceItem item;
  const AddInvoiceItem(this.item);

  @override
  List<Object?> get props => [item];
}

class UpdateInvoiceItem extends InvoiceItemEvent {
  final InvoiceItem item;
  const UpdateInvoiceItem(this.item);

  @override
  List<Object?> get props => [item];
}

class DeleteInvoiceItem extends InvoiceItemEvent {
  final int itemId;
  const DeleteInvoiceItem(this.itemId);

  @override
  List<Object?> get props => [itemId];
}
