import 'package:equatable/equatable.dart';

class Patient extends Equatable {
  final int? id;
  final String? firstName;
  final String? lastName;
  final String? gender;
  final DateTime? dateOfBirth;
  final String? bloodType;
  final String? phone1;
  final String? phone2;
  final String? email;
  final String? address;
  final String? city;
  final String? status;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const Patient({
    this.id,
    this.firstName,
    this.lastName,
    this.gender,
    this.dateOfBirth,
    this.bloodType,
    this.phone1,
    this.phone2,
    this.email,
    this.address,
    this.city,
    this.status,
    this.createdAt,
    this.updatedAt,
  });

  /// Factory method to create a Patient from Supabase JSON
  factory Patient.fromJson(Map<String, dynamic> json) {
    return Patient(
      id: json['id'] as int?,
      firstName: json['first_name'] as String?,
      lastName: json['last_name'] as String?,
      gender: json['gender'] as String?,
      dateOfBirth: json['date_of_birth'] != null
          ? DateTime.tryParse(json['date_of_birth'].toString())
          : null,
      bloodType: json['blood_type'] as String?,
      phone1: json['phone1'] as String?,
      phone2: json['phone2'] as String?,
      email: json['email'] as String?,
      address: json['address'] as String?,
      city: json['city'] as String?,
      status: json['status'] as String?,
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
      'first_name': firstName,
      'last_name': lastName,
      'gender': gender,
      'date_of_birth': dateOfBirth?.toIso8601String().split('T').first, // Date only for SQL date types
      'blood_type': bloodType,
      'phone1': phone1,
      'phone2': phone2,
      'email': email,
      'address': address,
      'city': city,
      'status': status ?? 'active', // Default to active if null
    };
    
    // Only include ID if updating (Supabase handles ID generation on insert)
    if (id != null) {
      data['id'] = id;
    }
    
    return data;
  }

  Patient copyWith({
    int? id,
    String? firstName,
    String? lastName,
    String? gender,
    DateTime? dateOfBirth,
    String? bloodType,
    String? phone1,
    String? phone2,
    String? email,
    String? address,
    String? city,
    String? status,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Patient(
      id: id ?? this.id,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      gender: gender ?? this.gender,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      bloodType: bloodType ?? this.bloodType,
      phone1: phone1 ?? this.phone1,
      phone2: phone2 ?? this.phone2,
      email: email ?? this.email,
      address: address ?? this.address,
      city: city ?? this.city,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        firstName,
        lastName,
        gender,
        dateOfBirth,
        bloodType,
        phone1,
        phone2,
        email,
        address,
        city,
        status,
        createdAt,
        updatedAt,
      ];
}