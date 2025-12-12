import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dentist_ms/features/billing/bloc/expense_event.dart';
import 'package:dentist_ms/features/billing/bloc/expense_state.dart';
import 'package:dentist_ms/features/billing/repositories/expense_repository.dart';

class ExpenseBloc extends Bloc<ExpenseEvent, ExpenseState> {
  final ExpenseRepository repository;

  ExpenseBloc({required this.repository}) : super(ExpensesInitial()) {
    on<LoadExpenses>(_onLoadExpenses);
    on<LoadExpenseById>(_onLoadExpenseById);
    on<AddExpense>(_onAddExpense);
    on<UpdateExpense>(_onUpdateExpense);
    on<DeleteExpense>(_onDeleteExpense);
  }

  Future<void> _onLoadExpenses(
    LoadExpenses event,
    Emitter<ExpenseState> emit,
  ) async {
    emit(ExpensesLoadInProgress());
    try {
      final expenses = await repository.getAllExpenses();
      emit(ExpensesLoadSuccess(expenses));
    } catch (e) {
      emit(ExpensesOperationFailure(e.toString()));
    }
  }

  Future<void> _onLoadExpenseById(
    LoadExpenseById event,
    Emitter<ExpenseState> emit,
  ) async {
    emit(ExpensesLoadInProgress());
    try {
      final expense = await repository.getExpenseById(event.expenseId);
      emit(ExpenseLoadSuccess(expense));
    } catch (e) {
      emit(ExpensesOperationFailure(e.toString()));
    }
  }

  Future<void> _onAddExpense(
    AddExpense event,
    Emitter<ExpenseState> emit,
  ) async {
    emit(ExpensesLoadInProgress());
    try {
      await repository.createExpense(event.expense);
      // Reload the list directly instead of dispatching another event
      final expenses = await repository.getAllExpenses();
      emit(ExpensesLoadSuccess(expenses));
    } catch (e) {
      emit(ExpensesOperationFailure(e.toString()));
    }
  }

  Future<void> _onUpdateExpense(
    UpdateExpense event,
    Emitter<ExpenseState> emit,
  ) async {
    emit(ExpensesLoadInProgress());
    try {
      await repository.updateExpense(event.expense);
      // Reload the list directly instead of dispatching another event
      final expenses = await repository.getAllExpenses();
      emit(ExpensesLoadSuccess(expenses));
    } catch (e) {
      emit(ExpensesOperationFailure(e.toString()));
    }
  }

  Future<void> _onDeleteExpense(
    DeleteExpense event,
    Emitter<ExpenseState> emit,
  ) async {
    emit(ExpensesLoadInProgress());
    try {
      await repository.deleteExpense(event.expenseId);
      // Reload the list directly instead of dispatching another event
      final expenses = await repository.getAllExpenses();
      emit(ExpensesLoadSuccess(expenses));
    } catch (e) {
      emit(ExpensesOperationFailure(e.toString()));
    }
  }
}
