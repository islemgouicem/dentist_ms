import 'package:flutter/material.dart';
import 'package:dentist_ms/core/constants/app_colors.dart';
import 'package:dentist_ms/core/constants/app_text_styles.dart';
import 'package:dentist_ms/features/patients/models/patient.dart';
import 'package:dentist_ms/features/patients/data/patient_remote.dart';

class AddInvoiceDialog extends StatefulWidget {
  const AddInvoiceDialog({Key? key}) : super(key: key);

  @override
  State<AddInvoiceDialog> createState() => _AddInvoiceDialogState();
}

class _AddInvoiceDialogState extends State<AddInvoiceDialog> {
  final _formKey = GlobalKey<FormState>();
  final _invoiceNumberController = TextEditingController();
  final _discountController = TextEditingController(text: '0.00');
  final _notesController = TextEditingController();

  int? _selectedPatientId;
  DateTime _selectedDate = DateTime.now();

  List<Patient> _patients = [];
  bool _isLoadingPatients = true;

  @override
  void initState() {
    super.initState();
    _loadPatients();
  }

  Future<void> _loadPatients() async {
    try {
      final dataSource = PatientRemoteDataSource();
      final patients = await dataSource.getPatients();
      setState(() {
        _patients = patients.where((p) => p.status == 'active').toList();
        _isLoadingPatients = false;
      });
    } catch (e) {
      setState(() {
        _isLoadingPatients = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur de chargement des patients: $e')),
        );
      }
    }
  }

  @override
  void dispose() {
    _invoiceNumberController.dispose();
    _discountController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        width: MediaQuery.of(context).size.width * 0.9,
        constraints: const BoxConstraints(maxWidth: 600, maxHeight: 700),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildHeader(),
            Expanded(
              child: Container(
                color: Colors.white, // Added white background
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildInvoiceNumberField(),
                        const SizedBox(height: 16),
                        _buildPatientDropdown(),
                        const SizedBox(height: 16),
                        _buildDatePicker(),
                        const SizedBox(height: 16),
                        _buildDiscountField(),
                        const SizedBox(height: 16),
                        _buildNotesField(),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            _buildActions(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
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
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(Icons.receipt_long, color: AppColors.primary, size: 24),
          ),
          const SizedBox(width: 12),
          Text('Nouvelle facture', style: AppTextStyles.headline2),
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

  Widget _buildInvoiceNumberField() {
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
        TextFormField(
          controller: _invoiceNumberController,
          decoration: _inputDecoration('Ex: FAC-006'),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Le numéro de facture est requis';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildPatientDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Patient',
          style: AppTextStyles.body1.copyWith(
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        _isLoadingPatients
            ? const Center(child: CircularProgressIndicator())
            : DropdownButtonFormField<int>(
                value: _selectedPatientId,
                decoration: _inputDecoration('Sélectionner un patient'),
                items: _patients.map((patient) {
                  final fullName =
                      '${patient.firstName ?? ''} ${patient.lastName ?? ''}'
                          .trim();
                  return DropdownMenuItem(
                    value: patient.id,
                    child: Text(
                      fullName.isNotEmpty ? fullName : 'Patient ${patient.id}',
                    ),
                  );
                }).toList(),
                onChanged: (value) =>
                    setState(() => _selectedPatientId = value),
                validator: (value) {
                  if (value == null) {
                    return 'Veuillez sélectionner un patient';
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
          'Date de début',
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
              lastDate: DateTime(2030),
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

  Widget _buildDiscountField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Remise (optionnel)',
          style: AppTextStyles.body1.copyWith(
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _discountController,
          decoration: _inputDecoration(
            '0.00',
          ).copyWith(prefixText: '\$ ', prefixStyle: AppTextStyles.body1),
          keyboardType: TextInputType.number,
          validator: (value) {
            if (value != null && value.isNotEmpty) {
              if (double.tryParse(value) == null) {
                return 'Veuillez entrer un montant valide';
              }
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

  Widget _buildActions() {
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
              backgroundColor: AppColors.primary,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text(
              'Créer la facture',
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
      // Parse discount amount, default to 0 if empty
      final discountText = _discountController.text.trim();
      final discount = discountText.isEmpty ? 0.0 : double.parse(discountText);

      // Create invoice object with default status 'unpaid'
      final invoice = {
        'invoiceNumber': _invoiceNumberController.text,
        'patientId': _selectedPatientId,
        'startDate': _selectedDate.toString().split(' ')[0],
        'discount': discount,
        'status': 'unpaid',
        'notes': _notesController.text,
      };

      // Return the invoice data to the calling page
      Navigator.of(context).pop(invoice);
    }
  }
}
