import 'package:equatable/equatable.dart';

class InvoiceItem extends Equatable {
  final int? id;
  final int? invoiceId;
  final int? treatmentId;
  final String? description;
  final double? quantity;
  final double? unitPrice;
  final double? totalPrice;

  InvoiceItem({
    this.id,
    this.invoiceId,
    this.treatmentId,
    this.description,
    this.quantity,
    this.unitPrice,
    this.totalPrice,
  });

  factory InvoiceItem.fromJson(Map<String, dynamic> json) {
    return InvoiceItem(
      id: json['id'] as int?,
      invoiceId: json['invoice_id'] as int?,
      treatmentId: json['treatment_id'] as int?,
      description: json['description'] as String?,
      quantity: json['quantity'] != null
          ? double.tryParse(json['quantity'].toString())
          : null,
      unitPrice: json['unit_price'] != null
          ? double.tryParse(json['unit_price'].toString())
          : null,
      totalPrice: json['total_price'] != null
          ? double.tryParse(json['total_price'].toString())
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {
      'invoice_id': invoiceId,
      'treatment_id': treatmentId,
      'description': description,
      'quantity': quantity,
      'unit_price': unitPrice,
      'total_price': totalPrice,
    };

    // Only include id for updates, not for inserts
    if (id != null) {
      data['id'] = id;
    }

    return data;
  }

  InvoiceItem copyWith({
    int? id,
    int? invoiceId,
    int? treatmentId,
    String? description,
    double? quantity,
    double? unitPrice,
    double? totalPrice,
  }) {
    return InvoiceItem(
      id: id ?? this.id,
      invoiceId: invoiceId ?? this.invoiceId,
      treatmentId: treatmentId ?? this.treatmentId,
      description: description ?? this.description,
      quantity: quantity ?? this.quantity,
      unitPrice: unitPrice ?? this.unitPrice,
      totalPrice: totalPrice ?? this.totalPrice,
    );
  }

  @override
  List<Object?> get props => [
    id,
    invoiceId,
    treatmentId,
    description,
    quantity,
    unitPrice,
    totalPrice,
  ];
}
