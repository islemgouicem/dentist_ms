import 'package:equatable/equatable.dart';

class Payment extends Equatable {
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
    final Map<String, dynamic> data = {
      'invoice_id': invoiceId,
      'payment_date': paymentDate?.toIso8601String().split('T').first,
      'amount': amount,
      'method': method,
      'reference': reference,
      'notes': notes,
    };

    // Only include id for updates, not for inserts
    if (id != null) {
      data['id'] = id;
    }

    return data;
  }

  Payment copyWith({
    int? id,
    int? invoiceId,
    DateTime? paymentDate,
    double? amount,
    String? method,
    String? reference,
    String? notes,
  }) {
    return Payment(
      id: id ?? this.id,
      invoiceId: invoiceId ?? this.invoiceId,
      paymentDate: paymentDate ?? this.paymentDate,
      amount: amount ?? this.amount,
      method: method ?? this.method,
      reference: reference ?? this.reference,
      notes: notes ?? this.notes,
    );
  }

  @override
  List<Object?> get props => [
    id,
    invoiceId,
    paymentDate,
    amount,
    method,
    reference,
    notes,
  ];
}
