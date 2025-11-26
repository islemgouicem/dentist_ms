import 'package:equatable/equatable.dart';

/// Patient model representing a patient in the dental clinic.
class Patient extends Equatable {
  final String? id;
  final String firstName;
  final String lastName;
  final String? email;
  final String? phone;
  final DateTime? dateOfBirth;
  final String? gender;
  final String? address;
  final String? notes;
  final String status;
  final double balance;
  final DateTime? lastVisit;
  final DateTime? nextAppointment;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const Patient({
    this.id,
    required this.firstName,
    required this.lastName,
    this.email,
    this.phone,
    this.dateOfBirth,
    this.gender,
    this.address,
    this.notes,
    this.status = 'active',
    this.balance = 0,
    this.lastVisit,
    this.nextAppointment,
    this.createdAt,
    this.updatedAt,
  });

  /// Full name of the patient
  String get fullName => '$firstName $lastName';

  /// Age of the patient calculated from date of birth
  int? get age {
    if (dateOfBirth == null) return null;
    final now = DateTime.now();
    int age = now.year - dateOfBirth!.year;
    if (now.month < dateOfBirth!.month ||
        (now.month == dateOfBirth!.month && now.day < dateOfBirth!.day)) {
      age--;
    }
    return age;
  }

  /// Initials for avatar display
  String get initials {
    final first = firstName.isNotEmpty ? firstName[0].toUpperCase() : '';
    final last = lastName.isNotEmpty ? lastName[0].toUpperCase() : '';
    return '$first$last';
  }

  /// Create a Patient from JSON (Supabase response)
  factory Patient.fromJson(Map<String, dynamic> json) {
    return Patient(
      id: json['id'] as String?,
      firstName: json['first_name'] as String? ?? '',
      lastName: json['last_name'] as String? ?? '',
      email: json['email'] as String?,
      phone: json['phone'] as String?,
      dateOfBirth: json['date_of_birth'] != null
          ? DateTime.tryParse(json['date_of_birth'] as String)
          : null,
      gender: json['gender'] as String?,
      address: json['address'] as String?,
      notes: json['notes'] as String?,
      status: json['status'] as String? ?? 'active',
      balance: (json['balance'] as num?)?.toDouble() ?? 0,
      lastVisit: json['last_visit'] != null
          ? DateTime.tryParse(json['last_visit'] as String)
          : null,
      nextAppointment: json['next_appointment'] != null
          ? DateTime.tryParse(json['next_appointment'] as String)
          : null,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'] as String)
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.tryParse(json['updated_at'] as String)
          : null,
    );
  }

  /// Convert Patient to JSON for Supabase
  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'first_name': firstName,
      'last_name': lastName,
      'email': email,
      'phone': phone,
      'date_of_birth': dateOfBirth?.toIso8601String().split('T').first,
      'gender': gender,
      'address': address,
      'notes': notes,
      'status': status,
      'balance': balance,
      'last_visit': lastVisit?.toIso8601String(),
      'next_appointment': nextAppointment?.toIso8601String(),
    };
  }

  /// Create a copy with updated fields
  Patient copyWith({
    String? id,
    String? firstName,
    String? lastName,
    String? email,
    String? phone,
    DateTime? dateOfBirth,
    String? gender,
    String? address,
    String? notes,
    String? status,
    double? balance,
    DateTime? lastVisit,
    DateTime? nextAppointment,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Patient(
      id: id ?? this.id,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      gender: gender ?? this.gender,
      address: address ?? this.address,
      notes: notes ?? this.notes,
      status: status ?? this.status,
      balance: balance ?? this.balance,
      lastVisit: lastVisit ?? this.lastVisit,
      nextAppointment: nextAppointment ?? this.nextAppointment,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        firstName,
        lastName,
        email,
        phone,
        dateOfBirth,
        gender,
        address,
        notes,
        status,
        balance,
        lastVisit,
        nextAppointment,
        createdAt,
        updatedAt,
      ];
}
