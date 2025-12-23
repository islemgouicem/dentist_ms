import 'package:equatable/equatable.dart';
import 'package:dentist_ms/features/billing/models/expense.dart';

abstract class ExpenseState extends Equatable {
  const ExpenseState();

  @override
  List<Object?> get props => [];
}

class ExpensesInitial extends ExpenseState {}

class ExpensesLoadInProgress extends ExpenseState {}

class ExpensesLoadSuccess extends ExpenseState {
  final List<Expense> expenses;

  const ExpensesLoadSuccess(this.expenses);

  @override
  List<Object?> get props => [expenses];
}

class ExpenseLoadSuccess extends ExpenseState {
  final Expense expense;

  const ExpenseLoadSuccess(this.expense);

  @override
  List<Object?> get props => [expense];
}

class ExpensesOperationFailure extends ExpenseState {
  final String message;

  const ExpensesOperationFailure(this.message);

  @override
  List<Object?> get props => [message];
}
