import 'package:equatable/equatable.dart';

class Treatment extends Equatable {
  final int? id;
  final String? code;
  final String? name;
  final String? description;
  final double? basePrice;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const Treatment({
    this.id,
    this.code,
    this.name,
    this.description,
    this.basePrice,
    this.createdAt,
    this.updatedAt,
  });

  factory Treatment.fromJson(Map<String, dynamic> json) {
    return Treatment(
      id: json['id'] as int?,
      code: json['code'] as String?,
      name: json['name'] as String?,
      description: json['description'] as String?,
      basePrice: json['base_price'] != null
          ? double.tryParse(json['base_price'].toString())
          : null,
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
      'code': code,
      'name': name,
      'description': description,
      'base_price': basePrice,
    };

    if (id != null) {
      data['id'] = id;
    }

    return data;
  }

  @override
  List<Object?> get props => [
    id,
    code,
    name,
    description,
    basePrice,
    createdAt,
    updatedAt,
  ];
}
