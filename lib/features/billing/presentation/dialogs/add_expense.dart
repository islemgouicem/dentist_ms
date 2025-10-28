import 'package:flutter/material.dart';
import 'package:dentist_ms/core/constants/app_colors.dart';
import 'package:dentist_ms/core/constants/app_text_styles.dart';

class AddExpenseDialog extends StatefulWidget {
  final Map<String, dynamic>? expense; // For editing existing expense

  const AddExpenseDialog({Key? key, this.expense}) : super(key: key);

  @override
  State<AddExpenseDialog> createState() => _AddExpenseDialogState();
}

class _AddExpenseDialogState extends State<AddExpenseDialog> {
  final _formKey = GlobalKey<FormState>();
  final _descriptionController = TextEditingController();
  final _amountController = TextEditingController();
  final _notesController = TextEditingController();

  DateTime _selectedDate = DateTime.now();
  String? _selectedCategory;
  String? _selectedPaymentMethod;

  final List<String> _categories = [
    'Fournitures dentaires',
    'Équipement',
    'Salaires',
    'Loyer',
    'Services publics',
    'Marketing',
    'Formation',
    'Entretien',
    'Autre',
  ];

  final List<String> _paymentMethods = [
    'Espèces',
    'Carte de crédit',
    'Carte de débit',
    'Virement bancaire',
    'Chèque',
  ];

  @override
  void initState() {
    super.initState();
    if (widget.expense != null) {
      _descriptionController.text = widget.expense!['description'] ?? '';
      _amountController.text = widget.expense!['amount']?.toString() ?? '';
      _notesController.text = widget.expense!['notes'] ?? '';
      _selectedCategory = widget.expense!['category'];
      _selectedPaymentMethod = widget.expense!['paymentMethod'];
      if (widget.expense!['date'] != null) {
        _selectedDate = DateTime.parse(widget.expense!['date']);
      }
    }
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    _amountController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.expense != null;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        width: MediaQuery.of(context).size.width * 0.9,
        constraints: const BoxConstraints(maxWidth: 500, maxHeight: 650),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildHeader(isEditing),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildDescriptionField(),
                      const SizedBox(height: 16),
                      _buildCategoryDropdown(),
                      const SizedBox(height: 16),
                      _buildAmountField(),
                      const SizedBox(height: 16),
                      _buildDatePicker(),
                      const SizedBox(height: 16),
                      _buildPaymentMethodDropdown(),
                      const SizedBox(height: 16),
                      _buildNotesField(),
                    ],
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
              color: Colors.red.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.payments,
              color: Colors.red,
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          Text(
            isEditing ? 'Modifier la dépense' : 'Ajouter une dépense',
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

  Widget _buildDescriptionField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Description',
          style: AppTextStyles.body1.copyWith(
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _descriptionController,
          decoration: _inputDecoration('Ex: Commande de fournitures dentaires'),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'La description est requise';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildCategoryDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Catégorie',
          style: AppTextStyles.body1.copyWith(
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: _selectedCategory,
          decoration: _inputDecoration('Sélectionner une catégorie'),
          items: _categories.map((category) {
            return DropdownMenuItem(value: category, child: Text(category));
          }).toList(),
          onChanged: (value) => setState(() => _selectedCategory = value),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Veuillez sélectionner une catégorie';
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
          decoration: _inputDecoration('0.00').copyWith(
            prefixText: '\$ ',
            prefixStyle: AppTextStyles.body1,
          ),
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
          'Date',
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

  Widget _buildPaymentMethodDropdown() {
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
          value: _selectedPaymentMethod,
          decoration: _inputDecoration('Sélectionner une méthode'),
          items: _paymentMethods.map((method) {
            return DropdownMenuItem(value: method, child: Text(method));
          }).toList(),
          onChanged: (value) => setState(() => _selectedPaymentMethod = value),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Veuillez sélectionner une méthode de paiement';
            }
            return null;
          },
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
              backgroundColor: Colors.red,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text(
              isEditing ? 'Modifier' : 'Ajouter',
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
      final expense = {
        'description': _descriptionController.text,
        'category': _selectedCategory,
        'amount': double.parse(_amountController.text),
        'date': _selectedDate.toString().split(' ')[0],
        'paymentMethod': _selectedPaymentMethod,
        'notes': _notesController.text,
      };

      Navigator.of(context).pop(expense);

      // TODO: Send data to backend
    }
  }
}