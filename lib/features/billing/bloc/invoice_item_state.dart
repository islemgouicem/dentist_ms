import 'package:equatable/equatable.dart';
import 'package:dentist_ms/features/billing/models/invoice_item.dart';

abstract class InvoiceItemState extends Equatable {
  const InvoiceItemState();

  @override
  List<Object?> get props => [];
}

class InvoiceItemsInitial extends InvoiceItemState {}

class InvoiceItemsLoadInProgress extends InvoiceItemState {}

class InvoiceItemsLoadSuccess extends InvoiceItemState {
  final List<InvoiceItem> items;

  const InvoiceItemsLoadSuccess(this.items);

  @override
  List<Object?> get props => [items];
}

class InvoiceItemLoadSuccess extends InvoiceItemState {
  final InvoiceItem item;

  const InvoiceItemLoadSuccess(this.item);

  @override
  List<Object?> get props => [item];
}

class InvoiceItemsOperationFailure extends InvoiceItemState {
  final String message;

  const InvoiceItemsOperationFailure(this.message);

  @override
  List<Object?> get props => [message];
}
