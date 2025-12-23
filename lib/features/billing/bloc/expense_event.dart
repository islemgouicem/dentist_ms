import 'package:equatable/equatable.dart';
import 'package:dentist_ms/features/billing/models/expense.dart';

abstract class ExpenseEvent extends Equatable {
  const ExpenseEvent();

  @override
  List<Object?> get props => [];
}

class LoadExpenses extends ExpenseEvent {}

class LoadExpenseById extends ExpenseEvent {
  final int expenseId;
  const LoadExpenseById(this.expenseId);

  @override
  List<Object?> get props => [expenseId];
}

class AddExpense extends ExpenseEvent {
  final Expense expense;
  const AddExpense(this.expense);

  @override
  List<Object?> get props => [expense];
}

class UpdateExpense extends ExpenseEvent {
  final Expense expense;
  const UpdateExpense(this.expense);

  @override
  List<Object?> get props => [expense];
}

class DeleteExpense extends ExpenseEvent {
  final int expenseId;
  const DeleteExpense(this.expenseId);

  @override
  List<Object?> get props => [expenseId];
}
