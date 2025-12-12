import 'package:flutter/material.dart';
import 'package:dentist_ms/core/constants/app_colors.dart';
import 'package:dentist_ms/core/constants/app_text_styles.dart';
import '../../models/invoice.dart';

class AddPaymentDialog extends StatefulWidget {
  final Map<String, dynamic>? payment;
  final List<Invoice> invoices;

  const AddPaymentDialog({Key? key, this.payment, this.invoices = const []})
    : super(key: key);

  @override
  State<AddPaymentDialog> createState() => _AddPaymentDialogState();
}

class _AddPaymentDialogState extends State<AddPaymentDialog> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _referenceController = TextEditingController();
  final _notesController = TextEditingController();

  DateTime _selectedDate = DateTime.now();
  String? _selectedMethod = 'cash';
  int? _selectedInvoiceId;

  final List<String> _paymentMethods = [
    'cash',
    'credit_card',
    'debit_card',
    'bank_transfer',
    'check',
  ];

  @override
  void initState() {
    super.initState();
    if (widget.payment != null) {
      _amountController.text = widget.payment!['amount']?.toString() ?? '';
      _referenceController.text = widget.payment!['reference'] ?? '';
      _notesController.text = widget.payment!['notes'] ?? '';
      _selectedMethod = widget.payment!['method'];
      _selectedInvoiceId = widget.payment!['invoiceId'];
      if (widget.payment!['paymentDate'] != null) {
        _selectedDate = DateTime.parse(widget.payment!['paymentDate']);
      }
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    _referenceController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.payment != null;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        width: MediaQuery.of(context).size.width * 0.9,
        constraints: const BoxConstraints(maxWidth: 500, maxHeight: 700),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildHeader(isEditing),
            Expanded(
              child: Container(
                color: Colors.white,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildInvoiceDropdown(),
                        const SizedBox(height: 16),
                        _buildAmountField(),
                        const SizedBox(height: 16),
                        _buildDatePicker(),
                        const SizedBox(height: 16),
                        _buildMethodDropdown(),
                        const SizedBox(height: 16),
                        _buildReferenceField(),
                        const SizedBox(height: 16),
                        _buildNotesField(),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            _buildActions(isEditing),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(bool isEditing) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.white,
        border: Border(bottom: BorderSide(color: AppColors.border)),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.green.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.payment, color: Colors.green, size: 24),
          ),
          const SizedBox(width: 12),
          Text(
            isEditing ? 'Modifier le paiement' : 'Ajouter un paiement',
            style: AppTextStyles.headline2,
          ),
          const Spacer(),
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => Navigator.of(context).pop(),
            color: AppColors.textSecondary,
          ),
        ],
      ),
    );
  }

  Widget _buildInvoiceDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'N° Facture',
          style: AppTextStyles.body1.copyWith(
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<int>(
          value: _selectedInvoiceId,
          decoration: _inputDecoration('Sélectionner une facture'),
          items: widget.invoices.map((invoice) {
            return DropdownMenuItem<int>(
              value: invoice.id,
              child: Text(
                '${invoice.invoiceNumber} - ${invoice.patientName ?? "Patient inconnu"}',
              ),
            );
          }).toList(),
          onChanged: (value) => setState(() => _selectedInvoiceId = value),
          validator: (value) {
            if (value == null) {
              return 'Veuillez sélectionner une facture';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildAmountField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Montant',
          style: AppTextStyles.body1.copyWith(
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _amountController,
          decoration: _inputDecoration(
            '0.00',
          ).copyWith(prefixText: '\$ ', prefixStyle: AppTextStyles.body1),
          keyboardType: TextInputType.number,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Le montant est requis';
            }
            if (double.tryParse(value) == null) {
              return 'Veuillez entrer un montant valide';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildDatePicker() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Date de paiement',
          style: AppTextStyles.body1.copyWith(
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: () async {
            final date = await showDatePicker(
              context: context,
              initialDate: _selectedDate,
              firstDate: DateTime(2020),
              lastDate: DateTime.now(),
            );
            if (date != null) {
              setState(() => _selectedDate = date);
            }
          },
          child: InputDecorator(
            decoration: _inputDecoration('Sélectionner une date'),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
                  style: AppTextStyles.body1,
                ),
                Icon(Icons.calendar_today, size: 20, color: AppColors.primary),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMethodDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Méthode de paiement',
          style: AppTextStyles.body1.copyWith(
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: _selectedMethod,
          decoration: _inputDecoration('Sélectionner une méthode'),
          items: _paymentMethods.map((method) {
            return DropdownMenuItem(
              value: method,
              child: Text(_getMethodLabel(method)),
            );
          }).toList(),
          onChanged: (value) => setState(() => _selectedMethod = value),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Veuillez sélectionner une méthode';
            }
            return null;
          },
        ),
      ],
    );
  }

  String _getMethodLabel(String method) {
    switch (method) {
      case 'cash':
        return 'Espèces';
      case 'credit_card':
        return 'Carte de crédit';
      case 'debit_card':
        return 'Carte de débit';
      case 'bank_transfer':
        return 'Virement bancaire';
      case 'check':
        return 'Chèque';
      default:
        return method;
    }
  }

  Widget _buildReferenceField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Référence (optionnel)',
          style: AppTextStyles.body1.copyWith(
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _referenceController,
          decoration: _inputDecoration('Ex: REF-12345'),
        ),
      ],
    );
  }

  Widget _buildNotesField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Notes (optionnel)',
          style: AppTextStyles.body1.copyWith(
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _notesController,
          decoration: _inputDecoration('Ajouter des notes...'),
          maxLines: 3,
        ),
      ],
    );
  }

  Widget _buildActions(bool isEditing) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.white,
        border: Border(top: BorderSide(color: AppColors.border)),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(16),
          bottomRight: Radius.circular(16),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          OutlinedButton(
            onPressed: () => Navigator.of(context).pop(),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              side: BorderSide(color: AppColors.border),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text(
              'Annuler',
              style: AppTextStyles.body1.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(width: 12),
          ElevatedButton(
            onPressed: _handleSubmit,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text(
              isEditing ? 'Enregistrer' : 'Ajouter',
              style: AppTextStyles.body1.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: AppTextStyles.body1.copyWith(color: AppColors.textSecondary),
      filled: true,
      fillColor: AppColors.cardgrey,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: AppColors.border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: AppColors.border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: AppColors.primary, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Colors.red),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    );
  }

  void _handleSubmit() {
    if (_formKey.currentState!.validate()) {
      final payment = {
        'invoiceId': _selectedInvoiceId,
        'amount': double.tryParse(_amountController.text) ?? 0.0,
        'paymentDate': _selectedDate.toString().split(' ')[0],
        'method': _selectedMethod,
        'reference': _referenceController.text,
        'notes': _notesController.text,
      };

      Navigator.of(context).pop(payment);
    }
  }
}
