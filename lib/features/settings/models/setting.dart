import 'package:equatable/equatable.dart';

class Setting extends Equatable {
  final int? id;
  final String? firstName;
  final String? lastName;
  final String? phone;
  final String? email;
  final String? role;
  final String? specialization;
  final String? bio;
  final String? identificationNumber;
  final String? profilePhotoPath;
  final String? passwordHash;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const Setting({
    this.id,
    this.firstName,
    this.lastName,
    this.phone,
    this.email,
    this.role,
    this.specialization,
    this.bio,
    this.identificationNumber,
    this.profilePhotoPath,
    this.passwordHash,
    this.createdAt,
    this.updatedAt,
  });

  factory Setting.fromJson(Map<String, dynamic> json) {
    return Setting(
      id: json['id'] as int?,
      firstName: json['first_name'] as String?,
      lastName: json['last_name'] as String?,
      phone: json['phone'] as String?,
      email: json['email'] as String?,
      role: json['role'] as String?,
      specialization: json['specialization'] as String?,
      bio: json['bio'] as String?,
      identificationNumber: json['identification_number'] as String?,
      profilePhotoPath: json['profile_photo_path'] as String?,
      passwordHash: json['password_hash'] as String?,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString())
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.tryParse(json['updated_at'].toString())
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {
      'first_name': firstName,
      'last_name': lastName,
      'phone': phone,
      'email': email,
      'role': role,
      'specialization': specialization,
      'bio': bio,
      'identification_number': identificationNumber,
      'profile_photo_path': profilePhotoPath,
    };
    
    if (id != null) {
      data['id'] = id;
    }
    
    return data;
  }

  Setting copyWith({
    int? id,
    String? firstName,
    String? lastName,
    String? phone,
    String? email,
    String? address,
    String? role,
    String? specialization,
    String? bio,
    String? identificationNumber,
    String? profilePhotoPath,
    String? passwordHash,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Setting(
      id: id ?? this.id,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      role: role ?? this.role,
      specialization: specialization ?? this.specialization,
      bio: bio ?? this.bio,
      identificationNumber: identificationNumber ?? this.identificationNumber,
      profilePhotoPath: profilePhotoPath ?? this.profilePhotoPath,
      passwordHash: passwordHash ?? this.passwordHash,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        firstName,
        lastName,
        phone,
        email,
        role,
        specialization,
        bio,
        identificationNumber,
        profilePhotoPath,
        passwordHash,
        createdAt,
        updatedAt,
      ];
}
