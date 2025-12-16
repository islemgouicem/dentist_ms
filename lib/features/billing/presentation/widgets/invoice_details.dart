import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dentist_ms/core/constants/app_colors.dart';
import 'package:dentist_ms/core/constants/app_text_styles.dart';
import 'package:dentist_ms/features/billing/models/invoice.dart';
import 'package:dentist_ms/features/billing/models/invoice_item.dart';
import 'package:dentist_ms/features/billing/bloc/invoice_bloc.dart';
import 'package:dentist_ms/features/billing/bloc/invoice_event.dart';
import 'package:dentist_ms/features/billing/bloc/invoice_state.dart';
import 'package:dentist_ms/features/billing/bloc/invoice_item_bloc.dart';
import 'package:dentist_ms/features/billing/bloc/invoice_item_event.dart';
import 'package:dentist_ms/features/billing/bloc/invoice_item_state.dart';
import 'package:dentist_ms/features/billing/repositories/invoice_item_repository.dart';
import 'package:dentist_ms/features/billing/repositories/invoice_repository.dart';
import 'package:dentist_ms/features/billing/repositories/payment_repository.dart';
import 'package:intl/intl.dart';
import '../dialogs/add_invoice_item.dart';
import 'package:dentist_ms/features/billing/data/invoice_remote.dart';
import 'package:dentist_ms/features/billing/data/invoice_item_remote.dart';
import 'package:dentist_ms/features/billing/data/payment_remote.dart';

class InvoiceDetailScreenWrapper extends StatelessWidget {
  final int invoiceId;
  const InvoiceDetailScreenWrapper({Key? key, required this.invoiceId})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<InvoiceBloc>(
          create: (context) => InvoiceBloc(
            repository: SupabaseInvoiceRepository(
              remote: InvoiceRemoteDataSource(),
            ),
          ),
        ),
        BlocProvider<InvoiceItemBloc>(
          create: (context) => InvoiceItemBloc(
            repository: SupabaseInvoiceItemRepository(
              remote: InvoiceItemRemoteDataSource(),
            ),
            invoiceDataSource: InvoiceRemoteDataSource(),
            paymentRepository: SupabasePaymentRepository(
              remote: PaymentRemoteDataSource(),
            ),
          ),
        ),
      ],
      child: InvoiceDetailScreen(invoiceId: invoiceId),
    );
  }
}

class InvoiceDetailScreen extends StatefulWidget {
  final int invoiceId;

  const InvoiceDetailScreen({Key? key, required this.invoiceId})
    : super(key: key);

  @override
  State<InvoiceDetailScreen> createState() => _InvoiceDetailScreenState();
}

class _InvoiceDetailScreenState extends State<InvoiceDetailScreen> {
  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    context.read<InvoiceBloc>().add(LoadInvoiceById(widget.invoiceId));
    context.read<InvoiceItemBloc>().add(
      LoadInvoiceItemsByInvoice(widget.invoiceId),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Détails de la facture',
          style: AppTextStyles.headline2.copyWith(color: AppColors.textPrimary),
        ),
      ),
      body: MultiBlocListener(
        listeners: [
          BlocListener<InvoiceItemBloc, InvoiceItemState>(
            listener: (context, state) {
              // Reload invoice whenever invoice items change to get updated totals
              if (state is InvoiceItemsLoadSuccess) {
                context.read<InvoiceBloc>().add(
                  LoadInvoiceById(widget.invoiceId),
                );
              }
            },
          ),
          BlocListener<InvoiceBloc, InvoiceState>(
            listener: (context, state) {
              if (state is InvoicesLoadSuccess) {
                // After update, reload the specific invoice
                context.read<InvoiceBloc>().add(
                  LoadInvoiceById(widget.invoiceId),
                );
              }
            },
          ),
        ],
        child: BlocBuilder<InvoiceBloc, InvoiceState>(
          builder: (context, invoiceState) {
            if (invoiceState is InvoicesLoadInProgress) {
              return const Center(child: CircularProgressIndicator());
            }

            if (invoiceState is InvoicesOperationFailure) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.error_outline,
                      size: 48,
                      color: AppColors.statusCancelled,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Erreur: ${invoiceState.message}',
                      style: AppTextStyles.body1.copyWith(
                        color: AppColors.statusCancelled,
                      ),
                    ),
                  ],
                ),
              );
            }

            if (invoiceState is InvoiceLoadSuccess) {
              return _buildContent(invoiceState.invoice);
            }

            return const Center(child: Text('Aucune donnée'));
          },
        ),
      ),
    );
  }

  Widget _buildContent(Invoice invoice) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildInvoiceHeader(invoice),
          const SizedBox(height: 24),
          _buildInvoiceInfo(invoice),
          const SizedBox(height: 24),
          _buildInvoiceItems(invoice),
          const SizedBox(height: 24),
          _buildInvoiceSummary(invoice),
        ],
      ),
    );
  }

  Widget _buildInvoiceHeader(Invoice invoice) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Facture ${invoice.invoiceNumber ?? ''}',
                  style: AppTextStyles.headline1.copyWith(
                    fontSize: 24,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Patient: ${invoice.patientName ?? '-'}',
                  style: AppTextStyles.body1.copyWith(
                    fontSize: 16,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          _buildStatusBadge(invoice.status ?? ''),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    final statusColor = _getStatusColor(status);
    final statusText = _getStatusText(status);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: statusColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        statusText,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: statusColor,
        ),
      ),
    );
  }

  Widget _buildInvoiceInfo(Invoice invoice) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Informations',
            style: AppTextStyles.headline2.copyWith(fontSize: 18),
          ),
          const SizedBox(height: 16),
          _buildInfoRow('Date de début', _formatDate(invoice.startDate)),
          _buildEditableInfoRow(
            'Date d\'échéance',
            invoice.dueDate != null
                ? _formatDate(invoice.dueDate)
                : 'Non défini',
            () => _editDueDate(invoice),
          ),
          if (invoice.notes != null && invoice.notes!.isNotEmpty)
            _buildInfoRow('Notes', invoice.notes ?? '-'),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140,
            child: Text(
              label,
              style: AppTextStyles.body1.copyWith(
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: AppTextStyles.body1.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEditableInfoRow(
    String label,
    String value,
    VoidCallback onEdit,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140,
            child: Text(
              label,
              style: AppTextStyles.body1.copyWith(
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: AppTextStyles.body1.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          InkWell(
            onTap: onEdit,
            child: Padding(
              padding: const EdgeInsets.all(4),
              child: Icon(Icons.edit, size: 18, color: AppColors.primary),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInvoiceItems(Invoice invoice) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(24),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Articles de la facture',
                  style: AppTextStyles.headline2.copyWith(fontSize: 18),
                ),
                ElevatedButton.icon(
                  onPressed: () => _showAddItemDialog(invoice),
                  icon: const Icon(Icons.add, size: 18),
                  label: const Text('Ajouter'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 10,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ],
            ),
          ),
          BlocBuilder<InvoiceItemBloc, InvoiceItemState>(
            builder: (context, state) {
              if (state is InvoiceItemsLoadInProgress) {
                return const Padding(
                  padding: EdgeInsets.all(24),
                  child: Center(child: CircularProgressIndicator()),
                );
              }

              if (state is InvoiceItemsOperationFailure) {
                return Padding(
                  padding: const EdgeInsets.all(24),
                  child: Text(
                    'Erreur: ${state.message}',
                    style: AppTextStyles.body1.copyWith(
                      color: AppColors.statusCancelled,
                    ),
                  ),
                );
              }

              if (state is InvoiceItemsLoadSuccess) {
                if (state.items.isEmpty) {
                  return Padding(
                    padding: const EdgeInsets.all(24),
                    child: Center(
                      child: Column(
                        children: [
                          Icon(
                            Icons.inbox_outlined,
                            size: 48,
                            color: AppColors.textSecondary,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Aucun article',
                            style: AppTextStyles.body1.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                return Column(
                  children: [
                    _buildItemsTable(state.items),
                    const SizedBox(height: 16),
                  ],
                );
              }

              return const SizedBox.shrink();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildItemsTable(List<InvoiceItem> items) {
    return Table(
      columnWidths: const {
        0: FlexColumnWidth(3),
        1: FlexColumnWidth(1),
        2: FlexColumnWidth(1.5),
        3: FlexColumnWidth(1.5),
        4: FlexColumnWidth(0.8),
      },
      children: [
        // Header
        TableRow(
          decoration: BoxDecoration(
            color: AppColors.cardgrey,
            border: Border(bottom: BorderSide(color: AppColors.border)),
          ),
          children: [
            _buildTableHeader('Traitement'),
            _buildTableHeader('Qté'),
            _buildTableHeader('Prix unitaire'),
            _buildTableHeader('Total'),
            _buildTableHeader(''),
          ],
        ),
        // Data rows
        ...items.map((item) => _buildItemRow(item)),
      ],
    );
  }

  Widget _buildTableHeader(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Text(
        text,
        style: AppTextStyles.body1.copyWith(
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
      ),
    );
  }

  TableRow _buildItemRow(InvoiceItem item) {
    return TableRow(
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: AppColors.border.withOpacity(0.5)),
        ),
      ),
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          child: Text(
            item.treatmentName ?? '-',
            style: AppTextStyles.body1.copyWith(color: AppColors.textPrimary),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          child: Text(
            item.quantity?.toStringAsFixed(0) ?? '0',
            style: AppTextStyles.body1.copyWith(color: AppColors.textPrimary),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          child: Text(
            '\$${item.unitPrice?.toStringAsFixed(2) ?? '0.00'}',
            style: AppTextStyles.body1.copyWith(color: AppColors.textPrimary),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          child: Text(
            '\$${item.totalPrice?.toStringAsFixed(2) ?? '0.00'}',
            style: AppTextStyles.body1.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
          child: IconButton(
            icon: Icon(
              Icons.delete_outline,
              size: 20,
              color: AppColors.statusCancelled,
            ),
            onPressed: () => _deleteItem(item),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
        ),
      ],
    );
  }

  Widget _buildInvoiceSummary(Invoice invoice) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          _buildSummaryRow(
            'Sous-total',
            '\$${invoice.subtotalAmount?.toStringAsFixed(2) ?? '0.00'}',
            false,
          ),
          if (invoice.discountAmount != null && invoice.discountAmount! > 0)
            _buildSummaryRow(
              'Remise',
              '-\$${invoice.discountAmount?.toStringAsFixed(2) ?? '0.00'}',
              false,
            ),
          const Divider(height: 24),
          _buildSummaryRow(
            'Total',
            '\$${invoice.totalAmount?.toStringAsFixed(2) ?? '0.00'}',
            true,
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value, bool isBold) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: AppTextStyles.body1.copyWith(
              fontSize: isBold ? 18 : 16,
              fontWeight: isBold ? FontWeight.bold : FontWeight.w500,
              color: AppColors.textPrimary,
            ),
          ),
          Text(
            value,
            style: AppTextStyles.body1.copyWith(
              fontSize: isBold ? 20 : 16,
              fontWeight: FontWeight.bold,
              color: isBold ? AppColors.primary : AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  void _showAddItemDialog(Invoice invoice) async {
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => AddInvoiceItemDialog(invoiceId: invoice.id!),
    );

    if (result != null && mounted) {
      final item = InvoiceItem(
        invoiceId: invoice.id,
        treatmentId: result['treatmentId'],
        treatmentName: result['treatmentName'], // For display only
        description: result['description'], // Store in database
        quantity: result['quantity'],
        unitPrice: result['unitPrice'],
        totalPrice: result['totalPrice'],
      );

      context.read<InvoiceItemBloc>().add(AddInvoiceItem(item));
      // Invoice will be automatically reloaded via BlocListener when item is added
    }
  }

  void _deleteItem(InvoiceItem item) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmer la suppression'),
        content: const Text('Voulez-vous vraiment supprimer cet article?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.statusCancelled,
            ),
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );

    if (confirm == true && mounted) {
      context.read<InvoiceItemBloc>().add(DeleteInvoiceItem(item.id!));
      // Invoice will be automatically reloaded via BlocListener when item is deleted
    }
  }

  void _editDueDate(Invoice invoice) async {
    final DateTime initialDate =
        invoice.dueDate ??
        (invoice.startDate != null && invoice.startDate!.isAfter(DateTime.now())
            ? invoice.startDate!
            : DateTime.now());

    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: invoice.startDate ?? DateTime(2020),
      lastDate: DateTime(2100),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: AppColors.primary,
              onPrimary: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );

    if (pickedDate != null && mounted) {
      // Update the invoice with the new due date
      final updatedInvoice = invoice.copyWith(dueDate: pickedDate);
      context.read<InvoiceBloc>().add(UpdateInvoice(updatedInvoice));
    }
  }

  String _formatDate(DateTime? date) {
    if (date == null) return '-';
    return DateFormat('dd/MM/yyyy').format(date);
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'paid':
        return const Color(0xFF10B981);
      case 'partial':
        return const Color(0xFFF59E0B);
      case 'unpaid':
        return const Color(0xFFEF4444);
      default:
        return AppColors.textSecondary;
    }
  }

  String _getStatusText(String status) {
    switch (status.toLowerCase()) {
      case 'paid':
        return 'Payé';
      case 'partial':
        return 'Partiel';
      case 'unpaid':
        return 'Non payé';
      default:
        return status;
    }
  }
}
