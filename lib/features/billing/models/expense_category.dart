import 'package:equatable/equatable.dart';

class ExpenseCategory extends Equatable {
  final int? id;
  final String? name;

  const ExpenseCategory({this.id, this.name});

  factory ExpenseCategory.fromJson(Map<String, dynamic> json) {
    return ExpenseCategory(
      id: json['id'] as int?,
      name: json['name'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {'name': name};

    if (id != null) {
      data['id'] = id;
    }

    return data;
  }

  @override
  List<Object?> get props => [id, name];
}
