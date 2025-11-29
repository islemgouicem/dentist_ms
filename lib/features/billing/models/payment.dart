class Payment {
  final int? id;
  final int? invoiceId;
  final DateTime? paymentDate;
  final double? amount;
  final String? method;
  final String? reference;
  final String? notes;

  Payment({
    this.id,
    this.invoiceId,
    this.paymentDate,
    this.amount,
    this.method,
    this.reference,
    this.notes,
  });

  factory Payment.fromJson(Map<String, dynamic> json) {
    return Payment(
      id: json['id'] as int?,
      invoiceId: json['invoice_id'] as int?,
      paymentDate: json['payment_date'] != null
          ? DateTime.tryParse(json['payment_date'].toString())
          : null,
      amount: (json['amount'] != null)
          ? double.tryParse(json['amount'].toString())
          : null,
      method: json['method'] as String?,
      reference: json['reference'] as String?,
      notes: json['notes'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'invoice_id': invoiceId,
      'payment_date': paymentDate?.toIso8601String(),
      'amount': amount,
      'method': method,
      'reference': reference,
      'notes': notes,
    };
  }
}
