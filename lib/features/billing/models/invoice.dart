import 'package:equatable/equatable.dart';

class Invoice extends Equatable {
  final int? id;
  final String? invoiceNumber;
  final int? patientId;
  final String? patientName;
  final String? treatmentName;
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
    this.patientName,
    this.treatmentName,
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
    // Parse patient name from nested patients object
    String? patientName;
    if (json['patients'] != null) {
      final patient = json['patients'] as Map<String, dynamic>;
      final firstName = patient['first_name'] as String? ?? '';
      final lastName = patient['last_name'] as String? ?? '';
      patientName = '$firstName $lastName'.trim();
      if (patientName.isEmpty) patientName = null;
    }

    // Parse treatment name from nested invoice_items and treatments
    String? treatmentName;
    if (json['invoice_items'] != null) {
      final items = json['invoice_items'];
      if (items is List && items.isNotEmpty) {
        final firstItem = items[0] as Map<String, dynamic>;
        if (firstItem['treatments'] != null) {
          final treatment = firstItem['treatments'] as Map<String, dynamic>;
          treatmentName = treatment['name'] as String?;
        }
      }
    }

    return Invoice(
      id: json['id'] as int?,
      invoiceNumber: json['invoice_number'] as String?,
      patientId: json['patient_id'] as int?,
      patientName: patientName,
      treatmentName: treatmentName,
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
      'invoice_number': invoiceNumber,
      'patient_id': patientId,
      'status': status,
      'start_date': startDate?.toIso8601String().split('T').first,
      'due_date': dueDate?.toIso8601String().split('T').first,
      'subtotal_amount': subtotalAmount,
      'discount_amount': discountAmount,
      'total_amount': totalAmount,
      'notes': notes,
    };

    // Only include id for updates, not for inserts
    if (id != null) {
      data['id'] = id;
    }

    return data;
  }

  Invoice copyWith({
    int? id,
    String? invoiceNumber,
    int? patientId,
    String? patientName,
    String? status,
    DateTime? startDate,
    DateTime? dueDate,
    double? subtotalAmount,
    double? discountAmount,
    double? totalAmount,
    String? notes,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Invoice(
      id: id ?? this.id,
      invoiceNumber: invoiceNumber ?? this.invoiceNumber,
      patientId: patientId ?? this.patientId,
      patientName: patientName ?? this.patientName,
      status: status ?? this.status,
      startDate: startDate ?? this.startDate,
      dueDate: dueDate ?? this.dueDate,
      subtotalAmount: subtotalAmount ?? this.subtotalAmount,
      discountAmount: discountAmount ?? this.discountAmount,
      totalAmount: totalAmount ?? this.totalAmount,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
    id,
    invoiceNumber,
    patientId,
    patientName,
    status,
    startDate,
    dueDate,
    subtotalAmount,
    discountAmount,
    totalAmount,
    notes,
    createdAt,
    updatedAt,
  ];
}
