import 'package:equatable/equatable.dart';

class Invoice {
  final int? id;
  final String? invoiceNumber;
  final int? patientId;
  final String? status;
  final DateTime? startDate;
  final DateTime? dueDate;
  final double? subtotalAmount;
  final double? discountAmount;
  final double? totalAmount;
  final String? notes;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Invoice({
    this.id,
    this.invoiceNumber,
    this.patientId,
    this.status,
    this.startDate,
    this.dueDate,
    this.subtotalAmount,
    this.discountAmount,
    this.totalAmount,
    this.notes,
    this.createdAt,
    this.updatedAt,
  });

  /// Factory method to create a Patient from Supabase JSON
  factory Invoice.fromJson(Map<String, dynamic> json) {
    return Invoice(
      id: json['id'] as int?,
      invoiceNumber: json['invoice_number'] as String?,
      patientId: json['patient_id'] as int?,
      status: json['status'] as String?,
      startDate: json['start_date'] != null
          ? DateTime.tryParse(json['start_date'].toString())
          : null,
      dueDate: json['due_date'] != null
          ? DateTime.tryParse(json['due_date'].toString())
          : null,
      subtotalAmount: (json['subtotal_amount'] != null)
          ? double.tryParse(json['subtotal_amount'].toString())
          : null,
      discountAmount: (json['discount_amount'] != null)
          ? double.tryParse(json['discount_amount'].toString())
          : null,
      totalAmount: (json['total_amount'] != null)
          ? double.tryParse(json['total_amount'].toString())
          : null,
      notes: json['notes'] as String?,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString())
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.tryParse(json['updated_at'].toString())
          : null,
    );
  }

  /// Convert Patient to JSON for Supabase
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {
      'id': id,
      'invoice_number': invoiceNumber,
      'patient_id': patientId,
      'status': status,
      'start_date': startDate?.toIso8601String(),
      'due_date': dueDate?.toIso8601String(),
      'subtotal_amount': subtotalAmount,
      'discount_amount': discountAmount,
      'total_amount': totalAmount,
      'notes': notes,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
    if (id != null) {
      data['id'] = id;
    }

    return data;
  }
}
