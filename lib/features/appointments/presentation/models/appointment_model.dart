import 'package:flutter/material.dart';

class AppointmentFile {
  final String id;
  final String fileName;
  final String fileType;
  final DateTime uploadedAt;
  final String uploadedBy;
  final double fileSizeInMB;

  AppointmentFile({
    required this.id,
    required this.fileName,
    required this.fileType,
    required this.uploadedAt,
    required this.uploadedBy,
    required this.fileSizeInMB,
  });
}

class Remark {
  final String id;
  final String content;
  final DateTime createdAt;
  final String createdBy;

  Remark({
    required this.id,
    required this.content,
    required this.createdAt,
    required this.createdBy,
  });
}

class PaymentRecord {
  final String id;
  final double amount;
  final DateTime paymentDate;
  final String paymentMethod;
  final String status;
  final String receiptNumber;

  PaymentRecord({
    required this.id,
    required this.amount,
    required this.paymentDate,
    required this.paymentMethod,
    required this.status,
    required this.receiptNumber,
  });
}

class Appointment {
  final String id;
  final String patientName;
  final String procedure;
  final String time;
  final int duration;
  String status;
  final Color cardColor;
  final DateTime appointmentDate;
  String notes;
  List<AppointmentFile> files;
  List<Remark> remarks;
  List<PaymentRecord> payments;
  double totalCost;

  Appointment({
    required this.id,
    required this.patientName,
    required this.procedure,
    required this.time,
    required this.duration,
    required this.status,
    required this.cardColor,
    required this.appointmentDate,
    this.notes = '',
    this.files = const [],
    this.remarks = const [],
    this.payments = const [],
    this.totalCost = 0.0,
  });
}