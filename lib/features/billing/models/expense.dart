import 'package:equatable/equatable.dart';

class Expense extends Equatable {
  final int? id;
  final DateTime? expenseDate;
  final String? description;
  final int? categoryId;
  final String? categoryName;
  final double? amount;
  final int? createdByUserId;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const Expense({
    this.id,
    this.expenseDate,
    this.description,
    this.categoryId,
    this.categoryName,
    this.amount,
    this.createdByUserId,
    this.createdAt,
    this.updatedAt,
  });

  factory Expense.fromJson(Map<String, dynamic> json) {
    // Parse category name from nested expense_categories object
    String? categoryName;
    if (json['expense_categories'] != null) {
      final category = json['expense_categories'] as Map<String, dynamic>;
      categoryName = category['name'] as String?;
    }

    return Expense(
      id: json['id'] as int?,
      expenseDate: json['expense_date'] != null
          ? DateTime.tryParse(json['expense_date'].toString())
          : null,
      description: json['description'] as String?,
      categoryId: json['category_id'] as int?,
      categoryName: categoryName,
      amount: (json['amount'] != null)
          ? double.tryParse(json['amount'].toString())
          : null,
      createdByUserId: json['created_by_user_id'] as int?,
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
      'expense_date': expenseDate?.toIso8601String().split('T').first,
      'description': description,
      'category_id': categoryId,
      'amount': amount,
      'created_by_user_id': createdByUserId,
    };

    if (id != null) {
      data['id'] = id;
    }

    return data;
  }

  Expense copyWith({
    int? id,
    DateTime? expenseDate,
    String? description,
    int? categoryId,
    String? categoryName,
    double? amount,
    int? createdByUserId,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Expense(
      id: id ?? this.id,
      expenseDate: expenseDate ?? this.expenseDate,
      description: description ?? this.description,
      categoryId: categoryId ?? this.categoryId,
      categoryName: categoryName ?? this.categoryName,
      amount: amount ?? this.amount,
      createdByUserId: createdByUserId ?? this.createdByUserId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
    id,
    expenseDate,
    description,
    categoryId,
    categoryName,
    amount,
    createdByUserId,
    createdAt,
    updatedAt,
  ];
}
