import 'package:flutter/material.dart';
import 'package:dentist_ms/core/constants/app_colors.dart';
import 'package:intl/intl.dart';
import '../widgets/header.dart';
import '../widgets/statistics.dart';
import '../widgets/invoices.dart';
import '../widgets/services.dart';
import '../widgets/expenses.dart';
import '../widgets/payment_history.dart';
import '../../utils/billing_responsive_helper.dart';
import '../../models/invoice.dart';
import '../../models/payment.dart';

class BillingsPage extends StatefulWidget {
  const BillingsPage({Key? key}) : super(key: key);

  @override
  State<BillingsPage> createState() => _BillingsPageState();
}

class _BillingsPageState extends State<BillingsPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _selectedStatus = 'Tous les statuts';

  double _totalRevenue = 0.0;
  double _pendingPayments = 0.0;
  double _overdue = 0.0;
  double _thisMonth = 0.0;

  final List<Invoice> _invoices = [
    Invoice(
      id: 1,
      invoiceNumber: 'FAC-001',
      patientId: 101,
      status: 'paid',
      startDate: DateTime.parse('2024-10-15'),
      dueDate: DateTime.parse('2024-10-20'),
      subtotalAmount: 1500.00,
      discountAmount: 0.0,
      totalAmount: 1500.00,
      notes: 'Traitement de canal',
      createdAt: DateTime.parse('2024-10-15'),
      updatedAt: DateTime.parse('2024-10-20'),
    ),
    Invoice(
      id: 2,
      invoiceNumber: 'FAC-002',
      patientId: 102,
      status: 'partial',
      startDate: DateTime.parse('2024-10-16'),
      dueDate: DateTime.parse('2024-10-21'),
      subtotalAmount: 800.00,
      discountAmount: 0.0,
      totalAmount: 800.00,
      notes: 'Nettoyage dentaire',
      createdAt: DateTime.parse('2024-10-16'),
      updatedAt: DateTime.parse('2024-10-21'),
    ),
    Invoice(
      id: 3,
      invoiceNumber: 'FAC-003',
      patientId: 103,
      status: 'paid',
      startDate: DateTime.parse('2024-10-17'),
      dueDate: DateTime.parse('2024-10-22'),
      subtotalAmount: 2500.00,
      discountAmount: 0.0,
      totalAmount: 2500.00,
      notes: 'Implant dentaire',
      createdAt: DateTime.parse('2024-10-17'),
      updatedAt: DateTime.parse('2024-10-22'),
    ),
  ];

  final List<Map<String, dynamic>> _expenses = [
    {
      'date': '2025-10-12',
      'description': 'Commande de fournitures dentaires',
      'category': 'Fournitures dentaires',
      'amount': 1250.00,
    },
    {
      'date': '2025-10-10',
      'description': 'Fabrication de couronne',
      'category': 'Équipement',
      'amount': 600.00,
    },
    {
      'date': '2025-10-08',
      'description': 'Entretien de l\'équipement',
      'category': 'Entretien',
      'amount': 450.00,
    },
    {
      'date': '2025-10-05',
      'description': 'Services publics mensuels',
      'category': 'Services publics',
      'amount': 320.00,
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

  final List<Payment> _payments = [
    Payment(
      id: 1,
      invoiceId: 1,
      paymentDate: DateTime.parse('2025-10-20'),
      amount: 1500.00,
      method: 'Carte',
      reference: 'REF001',
      notes: 'Terminé',
    ),
    Payment(
      id: 2,
      invoiceId: 5,
      paymentDate: DateTime.parse('2025-10-19'),
      amount: 1200.00,
      method: 'Espèces',
      reference: 'REF002',
      notes: 'Terminé',
    ),
    Payment(
      id: 3,
      invoiceId: 3,
      paymentDate: DateTime.parse('2025-10-17'),
      amount: 2500.00,
      method: 'Chèque',
      reference: 'REF003',
      notes: 'Terminé',
    ),
    Payment(
      id: 4,
      invoiceId: 2,
      paymentDate: DateTime.parse('2025-10-16'),
      amount: 400.00,
      method: 'Carte',
      reference: 'REF004',
      notes: 'Terminé',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _calculateStatistics();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _calculateStatistics() {
    double totalRevenue = 0.0;
    double pendingPayments = 0.0;
    double overdue = 0.0;
    double thisMonth = 0.0;

    final now = DateTime.now();
    final currentMonth = now.month;
    final currentYear = now.year;

    for (var invoice in _invoices) {
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

  List<Invoice> get _filteredInvoices {
    if (_selectedStatus == 'Tous les statuts') {
      return _invoices;
    }

    String statusFilter = _selectedStatus.toLowerCase();
    if (statusFilter == 'payé') statusFilter = 'paid';
    if (statusFilter == 'partiel') statusFilter = 'partial';
    if (statusFilter == 'non payé') statusFilter = 'unpaid';

    return _invoices.where((invoice) {
      return (invoice.status?.toLowerCase() ?? '') == statusFilter;
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
          InvoiceTable(invoices: _filteredInvoices, responsive: responsive),
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
            onAddService: () {},
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
          BillingExpensesControls(responsive: responsive, onAddExpense: () {}),
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
              payments: _payments.map((e) => e.toJson()).toList(),
              responsive: responsive,
            ),
          ),
        ],
      ),
    );
  }
}
