class InvoiceItem {
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
    return {
      'id': id,
      'invoice_id': invoiceId,
      'treatment_id': treatmentId,
      'description': description,
      'quantity': quantity,
      'unit_price': unitPrice,
      'total_price': totalPrice,
    };
  }
}
