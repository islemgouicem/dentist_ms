import 'package:flutter/material.dart';
import 'package:dentist_ms/core/constants/app_colors.dart';
import '../widgets/header.dart';
import '../widgets/statistics.dart';

import '../widgets/invoices.dart';
import '../widgets/table_controls.dart';
import '../widgets/services.dart';
import '../widgets/expenses.dart';
import '../widgets/payment_history.dart';

import '../../utils/billing_responsive_helper.dart';

class BillingsPage extends StatefulWidget {
  const BillingsPage({Key? key}) : super(key: key);

  @override
  State<BillingsPage> createState() => _BillingsPageState();
}

class _BillingsPageState extends State<BillingsPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _selectedStatus = 'Tous les statuts';

  // Statistics data - will be fetched from backend
  double _totalRevenue = 0.0;
  double _pendingPayments = 0.0;
  double _overdue = 0.0;
  double _thisMonth = 0.0;

  // Placeholder data - will be replaced with backend data
  final List<Map<String, dynamic>> _invoices = [
    {
      'id': 'FAC-001',
      'patient': 'Jean Dupont',
      'date': '2024-10-15',
      'amount': 1500.00,
      'paid': 1500.00,
      'status': 'paid',
      'treatment': 'Traitement de canal',
    },
    {
      'id': 'FAC-002',
      'patient': 'Marie Martin',
      'date': '2024-10-16',
      'amount': 800.00,
      'paid': 400.00,
      'status': 'partial',
      'treatment': 'Nettoyage dentaire',
    },
    {
      'id': 'FAC-003',
      'patient': 'Pierre Bernard',
      'date': '2024-10-17',
      'amount': 2500.00,
      'paid': 2500.00,
      'status': 'paid',
      'treatment': 'Implant dentaire',
    },
    {
      'id': 'FAC-004',
      'patient': 'Sophie Dubois',
      'date': '2024-10-18',
      'amount': 600.00,
      'paid': 0.00,
      'status': 'unpaid',
      'treatment': 'Plombage',
    },
    {
      'id': 'FAC-005',
      'patient': 'Luc Moreau',
      'date': '2024-10-19',
      'amount': 1200.00,
      'paid': 1200.00,
      'status': 'paid',
      'treatment': 'Couronne',
    },
  ];

  final List<Map<String, dynamic>> _services = [
    {'name': 'Nettoyage dentaire', 'price': 150.00},
    {'name': 'Plombage dentaire', 'price': 280.00},
    {'name': 'Traitement de canal', 'price': 1200.00},
    {'name': 'Couronne', 'price': 1800.00},
    {'name': 'Extraction dentaire', 'price': 350.00},
    {'name': 'Blanchiment des dents', 'price': 500.00},
  ];

  final List<Map<String, dynamic>> _expenses = [
    {
      'date': '2025-10-12',
      'description': 'Commande de fournitures dentaires',
      'amount': 1250.00,
    },
    {
      'date': '2025-10-10',
      'description': 'Fabrication de couronne',
      'amount': 600.00,
    },
    {
      'date': '2025-10-08',
      'description': 'Entretien de l\'équipement',
      'amount': 450.00,
    },
    {
      'date': '2025-10-05',
      'description': 'Services publics mensuels',
      'amount': 320.00,
    },
  ];

  final List<Map<String, dynamic>> _payments = [
    {
      'date': '2025-10-20',
      'invoiceId': 'FAC-001',
      'patient': 'Jean Dupont',
      'amount': 1500.00,

      'status': 'Terminé',
    },
    {
      'date': '2025-10-19',
      'invoiceId': 'FAC-005',
      'patient': 'Luc Moreau',
      'amount': 1200.00,

      'status': 'Terminé',
    },
    {
      'date': '2025-10-17',
      'invoiceId': 'FAC-003',
      'patient': 'Pierre Bernard',
      'amount': 2500.00,

      'status': 'Terminé',
    },
    {
      'date': '2025-10-16',
      'invoiceId': 'FAC-002',
      'patient': 'Marie Martin',
      'amount': 400.00,

      'status': 'Terminé',
    },
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _calculateStatistics();
    // TODO: Fetch statistics from backend
    // _fetchStatisticsFromBackend();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // Calculate statistics from invoice data
  void _calculateStatistics() {
    double totalRevenue = 0.0;
    double pendingPayments = 0.0;
    double overdue = 0.0;
    double thisMonth = 0.0;

    final now = DateTime.now();
    final currentMonth = now.month;
    final currentYear = now.year;

    for (var invoice in _invoices) {
      final amount = invoice['amount'] as double;
      final paid = invoice['paid'] as double;
      final balance = amount - paid;
      final status = invoice['status'] as String;
      final invoiceDate = DateTime.parse(invoice['date']);

      // Total revenue (all paid amounts)
      totalRevenue += paid;

      // Pending payments (partial and unpaid)
      if (status == 'partial' || status == 'unpaid') {
        pendingPayments += balance;
      }

      // Overdue (unpaid invoices)
      if (status == 'unpaid') {
        overdue += balance;
      }

      // This month revenue
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

  List<Map<String, dynamic>> get _filteredInvoices {
    if (_selectedStatus == 'Tous les statuts') {
      return _invoices;
    }

    String statusFilter = _selectedStatus.toLowerCase();
    if (statusFilter == 'payé') statusFilter = 'paid';
    if (statusFilter == 'partiel') statusFilter = 'partial';
    if (statusFilter == 'non payé') statusFilter = 'unpaid';

    return _invoices.where((invoice) {
      return invoice['status'].toLowerCase() == statusFilter;
    }).toList();
  }

  void _onStatusChanged(String newStatus) {
    setState(() {
      _selectedStatus = newStatus;
    });
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
                _buildServiceCatalogTab(responsive),
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
          Tab(text: 'Catalogue de services'),
          Tab(text: 'Dépenses'),
          Tab(text: 'Historique des paiements'),
        ],
      ),
    );
  }

  Widget _buildInvoicesTab(BillingResponsiveHelper responsive) {
    return SingleChildScrollView(
      child: Column(
        children: [
          BillingTableControls(
            responsive: responsive,
            selectedStatus: _selectedStatus,
            onStatusChanged: _onStatusChanged,
          ),
          BillingDataTable(invoices: _filteredInvoices, responsive: responsive),
        ],
      ),
    );
  }

  Widget _buildServiceCatalogTab(BillingResponsiveHelper responsive) {
    return SingleChildScrollView(
      child: Column(
        children: [
          BillingServiceCatalogControls(
            responsive: responsive,
            onAddService: () {
              // TODO: Show add service dialog
            },
          ),
          SizedBox(
            height: 500,
            child: BillingServiceCatalogTable(
              services: _services,
              responsive: responsive,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExpensesTab(BillingResponsiveHelper responsive) {
    return SingleChildScrollView(
      child: Column(
        children: [
          BillingExpensesControls(
            responsive: responsive,
            onAddExpense: () {
              // TODO: Show add expense dialog
            },
          ),
          SizedBox(
            height: 500,
            child: BillingExpensesTable(
              expenses: _expenses,
              responsive: responsive,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentHistoryTab(BillingResponsiveHelper responsive) {
    return SingleChildScrollView(
      child: Column(
        children: [
          BillingPaymentHistoryControls(responsive: responsive),
          SizedBox(
            height: 500,
            child: BillingPaymentHistoryTable(
              payments: _payments,
              responsive: responsive,
            ),
          ),
        ],
      ),
    );
  }
}
