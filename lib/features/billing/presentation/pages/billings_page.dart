import 'package:dentist_ms/features/billing/bloc/payment_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dentist_ms/core/constants/app_colors.dart';
import '../widgets/header.dart';
import '../widgets/statistics.dart';
import '../widgets/invoices.dart';
import '../widgets/treatments.dart';
import '../widgets/expenses.dart';
import '../widgets/payment_history.dart';
import '../../utils/billing_responsive_helper.dart';
import '../../models/invoice.dart';
import '../../models/payment.dart';
import '../../bloc/invoice_bloc.dart';
import '../../bloc/invoice_event.dart';
import '../../bloc/invoice_state.dart';
import '../../bloc/invoice_item_bloc.dart';
import '../../bloc/invoice_item_event.dart';
import '../../bloc/invoice_item_state.dart';
import '../../bloc/expense_bloc.dart';
import '../../bloc/expense_event.dart';
import '../../bloc/expense_state.dart';
import '../../bloc/payment_bloc.dart';
import '../../bloc/payment_event.dart';
import '../../bloc/payment_state.dart';
import '../../bloc/treatment_bloc.dart';
import '../../bloc/treatment_event.dart';
import '../../bloc/treatment_state.dart';
import '../../repositories/payment_repository.dart';
import '../../repositories/invoice_repository.dart';
import '../../repositories/invoice_item_repository.dart';
import '../../repositories/expense_repository.dart';
import '../../repositories/treatment_repository.dart';
import '../../data/invoice_remote.dart';
import '../../data/invoice_item_remote.dart';
import '../../data/expense_remote.dart';
import '../../data/treatment_remote.dart';
import '../../data/payment_remote.dart';
import '../../models/invoice_item.dart';
import '../../models/expense.dart';
import '../../models/treatment.dart';

class BillingsPage extends StatefulWidget {
  const BillingsPage({Key? key}) : super(key: key);

  @override
  State<BillingsPage> createState() => _BillingsPageState();
}

class BillingsPageWrapper extends StatelessWidget {
  const BillingsPageWrapper({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => InvoiceBloc(
            repository: SupabaseInvoiceRepository(
              remote: InvoiceRemoteDataSource(),
            ),
          )..add(LoadInvoices()),
        ),
        BlocProvider(
          create: (context) => InvoiceItemBloc(
            repository: SupabaseInvoiceItemRepository(
              remote: InvoiceItemRemoteDataSource(),
            ),
            paymentRepository: SupabasePaymentRepository(
              remote: PaymentRemoteDataSource(),
            ),
          )..add(LoadInvoiceItems()),
        ),
        BlocProvider(
          create: (context) => ExpenseBloc(
            repository: SupabaseExpenseRepository(
              remote: ExpenseRemoteDataSource(),
            ),
          )..add(LoadExpenses()),
        ),
        BlocProvider(
          create: (context) => TreatmentBloc(
            repository: SupabaseTreatmentRepository(
              remote: TreatmentRemoteDataSource(),
            ),
          )..add(LoadTreatments()),
        ),
        BlocProvider(
          create: (context) => PaymentBloc(
            repository: SupabasePaymentRepository(
              remote: PaymentRemoteDataSource(),
            ),
          )..add(LoadPayments()),
        ),
      ],
      child: const BillingsPage(),
    );
  }
}

class _BillingsPageState extends State<BillingsPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _selectedStatus = 'Tous les statuts';
  String _invoiceSearchQuery = '';
  String _treatmentSearchQuery = '';
  String _selectedCategory = 'Toutes les catégories';
  String _selectedPatient = 'Tous les patients';

  double _totalRevenue = 0.0;
  double _pendingPayments = 0.0;
  double _overdue = 0.0;
  double _thisMonth = 0.0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    // Load invoices on init
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<InvoiceBloc>().add(LoadInvoices());
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _calculateStatistics(List<Invoice> invoices) {
    double totalRevenue = 0.0;
    double pendingPayments = 0.0;
    double overdue = 0.0;
    double thisMonth = 0.0;

    final now = DateTime.now();
    final currentMonth = now.month;
    final currentYear = now.year;

    for (var invoice in invoices) {
      final amount = invoice.totalAmount ?? 0.0;
      final paid = invoice.status == 'paid'
          ? (invoice.totalAmount ?? 0.0)
          : (invoice.status == 'partial'
                ? ((invoice.totalAmount ?? 0.0) / 2)
                : 0.0);
      final balance = amount - paid;
      final status = invoice.status ?? '';
      final invoiceDate = invoice.startDate ?? DateTime.now();

      totalRevenue += paid;
      if (status == 'partial' || status == 'unpaid') {
        pendingPayments += balance;
      }
      if (status == 'unpaid') {
        overdue += balance;
      }
      if (invoiceDate.month == currentMonth &&
          invoiceDate.year == currentYear) {
        thisMonth += paid;
      }
    }

    setState(() {
      _totalRevenue = totalRevenue;
      _pendingPayments = pendingPayments;
      _overdue = overdue;
      _thisMonth = thisMonth;
    });
  }

  List<Invoice> _filterInvoices(List<Invoice> invoices) {
    return invoices.where((invoice) {
      // Filter by status
      bool statusMatch = true;
      if (_selectedStatus != 'Tous les statuts') {
        String statusFilter = _selectedStatus.toLowerCase();
        if (statusFilter == 'payé') statusFilter = 'paid';
        if (statusFilter == 'partiel') statusFilter = 'partial';
        if (statusFilter == 'non payé') statusFilter = 'unpaid';
        statusMatch = (invoice.status?.toLowerCase() ?? '') == statusFilter;
      }

      // Filter by patient search
      bool searchMatch = true;
      if (_invoiceSearchQuery.isNotEmpty) {
        searchMatch = (invoice.patientName?.toLowerCase() ?? '').contains(
          _invoiceSearchQuery.toLowerCase(),
        );
      }

      return statusMatch && searchMatch;
    }).toList();
  }

  void _onStatusChanged(String newStatus) {
    setState(() {
      _selectedStatus = newStatus;
    });
  }

  List<Treatment> _filterTreatments(List<Treatment> treatments) {
    if (_treatmentSearchQuery.isEmpty) {
      return treatments;
    }
    return treatments.where((treatment) {
      return (treatment.name?.toLowerCase() ?? '').contains(
        _treatmentSearchQuery.toLowerCase(),
      );
    }).toList();
  }

  List<Expense> _filterExpenses(List<Expense> expenses) {
    if (_selectedCategory == 'Toutes les catégories') {
      return expenses;
    }
    return expenses.where((expense) {
      return (expense.categoryName ?? '-') == _selectedCategory;
    }).toList();
  }

  List<Payment> _filterPayments(List<Payment> payments) {
    if (_selectedPatient == 'Tous les patients') {
      return payments;
    }
    return payments.where((payment) {
      return (payment.patientName ?? '-') == _selectedPatient;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: LayoutBuilder(
        builder: (context, constraints) {
          final responsive = BillingResponsiveHelper(constraints.maxWidth);

          return SingleChildScrollView(
            child: Padding(
              padding: responsive.pagePadding,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  BillingHeader(responsive: responsive),
                  SizedBox(height: responsive.sectionSpacing),
                  BillingStatisticsSection(
                    responsive: responsive,
                    totalRevenue: _totalRevenue,
                    pendingPayments: _pendingPayments,
                    overdue: _overdue,
                    thisMonth: _thisMonth,
                  ),
                  SizedBox(height: responsive.sectionSpacing),
                  _buildTabSection(responsive),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildTabSection(BillingResponsiveHelper responsive) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildTabBar(),
          SizedBox(
            height: 600,
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildInvoicesTab(responsive),
                _buildTreatmentCatalogTab(responsive),
                _buildExpensesTab(responsive),
                _buildPaymentHistoryTab(responsive),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: AppColors.border, width: 1)),
      ),
      child: TabBar(
        controller: _tabController,
        labelColor: AppColors.textPrimary,
        unselectedLabelColor: AppColors.textSecondary,
        indicatorColor: AppColors.primary,
        indicatorWeight: 3,
        labelStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
        unselectedLabelStyle: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w500,
        ),
        tabs: const [
          Tab(text: 'Factures'),
          Tab(text: 'Catalogue de Traitements'),
          Tab(text: 'Dépenses'),
          Tab(text: 'Historique des paiements'),
        ],
      ),
    );
  }

  Widget _buildInvoicesTab(BillingResponsiveHelper responsive) {
    return BlocBuilder<InvoiceBloc, InvoiceState>(
      builder: (context, state) {
        List<Invoice> invoices = [];

        if (state is InvoicesLoadSuccess) {
          invoices = state.invoices;
          // Update statistics when invoices load
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) {
              _calculateStatistics(invoices);
            }
          });
        } else if (state is InvoicesLoadInProgress) {
          return const Center(child: CircularProgressIndicator());
        } else if (state is InvoicesOperationFailure) {
          return Center(
            child: Text(
              'Erreur: ${state.message}',
              style: const TextStyle(color: Colors.red),
            ),
          );
        }

        final filteredInvoices = _filterInvoices(invoices);

        return SingleChildScrollView(
          child: Column(
            children: [
              BillingTableControls(
                responsive: responsive,
                selectedStatus: _selectedStatus,
                onStatusChanged: _onStatusChanged,
                onSearchChanged: (query) {
                  setState(() {
                    _invoiceSearchQuery = query;
                  });
                },
              ),
              InvoiceTable(invoices: filteredInvoices, responsive: responsive),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTreatmentCatalogTab(BillingResponsiveHelper responsive) {
    return BlocBuilder<TreatmentBloc, TreatmentState>(
      builder: (context, state) {
        List<Treatment> treatments = [];

        if (state is TreatmentsLoadSuccess) {
          treatments = state.treatments;
        } else if (state is TreatmentsLoadInProgress) {
          return const Center(child: CircularProgressIndicator());
        } else if (state is TreatmentsOperationFailure) {
          return Center(
            child: Text(
              'Erreur: ${state.message}',
              style: const TextStyle(color: Colors.red),
            ),
          );
        }

        final filteredTreatments = _filterTreatments(treatments);

        return SingleChildScrollView(
          child: Column(
            children: [
              BillingTreatmentCatalogControls(
                responsive: responsive,
                onAddTreatment: () {
                  // Refresh is handled by BLoC
                },
                onSearchChanged: (query) {
                  setState(() {
                    _treatmentSearchQuery = query;
                  });
                },
              ),
              Container(
                height: 500,
                child: BillingTreatmentCatalogTable(
                  treatments: filteredTreatments,
                  responsive: responsive,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildExpensesTab(BillingResponsiveHelper responsive) {
    return BlocBuilder<ExpenseBloc, ExpenseState>(
      builder: (context, state) {
        List<Expense> expenses = [];

        if (state is ExpensesLoadSuccess) {
          expenses = state.expenses;
        } else if (state is ExpensesLoadInProgress) {
          return const Center(child: CircularProgressIndicator());
        } else if (state is ExpensesOperationFailure) {
          return Center(
            child: Text(
              'Erreur: ${state.message}',
              style: const TextStyle(color: Colors.red),
            ),
          );
        }

        // Get unique categories
        final categories =
            expenses.map((e) => e.categoryName ?? '-').toSet().toList()..sort();

        // Filter expenses
        final filteredExpenses = _filterExpenses(expenses);

        // Convert Expenses to the expected format for the table
        final expensesData = filteredExpenses
            .map(
              (expense) => {
                'id': expense.id,
                'date':
                    expense.expenseDate?.toIso8601String().split('T').first ??
                    '',
                'description': expense.description ?? '',
                'category': expense.categoryName ?? '-',
                'amount': expense.amount ?? 0.0,
              },
            )
            .toList();

        return SingleChildScrollView(
          child: Column(
            children: [
              BillingExpensesControls(
                responsive: responsive,
                onAddExpense: () {
                  // Refresh is handled by BLoC
                },
                selectedCategory: _selectedCategory,
                onCategoryChanged: (category) {
                  setState(() {
                    _selectedCategory = category;
                  });
                },
                categories: categories,
              ),
              Container(
                height: 500,
                child: BillingExpensesTable(
                  expenses: expensesData,
                  responsive: responsive,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildPaymentHistoryTab(BillingResponsiveHelper responsive) {
    return BlocBuilder<PaymentBloc, PaymentState>(
      builder: (context, state) {
        List<Payment> payments = [];

        if (state is PaymentsLoadSuccess) {
          payments = state.payments;
        } else if (state is PaymentsLoadInProgress) {
          return const Center(child: CircularProgressIndicator());
        } else if (state is PaymentsOperationFailure) {
          return Center(
            child: Text(
              'Erreur: ${state.message}',
              style: const TextStyle(color: Colors.red),
            ),
          );
        }

        // Get unique patients
        final patients =
            payments.map((p) => p.patientName ?? '-').toSet().toList()..sort();

        // Filter payments
        final filteredPayments = _filterPayments(payments);

        // Convert Payments to the expected format for the table
        final paymentsData = filteredPayments
            .map(
              (payment) => {
                'id': payment.id,
                'invoice_id':
                    payment.invoiceNumber ??
                    payment.invoiceId?.toString() ??
                    '-',
                'payment_date': payment.paymentDate
                    ?.toIso8601String()
                    .split('T')
                    .first,
                'amount': payment.amount,
                'method': payment.method,
                'reference': payment.reference,
                'notes': payment.notes,
                'patient': payment.patientName ?? '-',
                'status': 'Payé',
              },
            )
            .toList();
        return SingleChildScrollView(
          child: Column(
            children: [
              BillingPaymentHistoryControls(
                responsive: responsive,
                onAddPayment: () =>
                    context.read<PaymentBloc>().add(LoadPayments()),
                selectedPatient: _selectedPatient,
                onPatientChanged: (patient) {
                  setState(() {
                    _selectedPatient = patient;
                  });
                },
                patients: patients,
              ),
              Container(
                height: 500,
                child: BillingPaymentHistoryTable(
                  payments: paymentsData,
                  responsive: responsive,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
