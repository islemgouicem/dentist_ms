import 'package:flutter/material.dart';
import 'package:dentist_ms/core/constants/app_colors.dart';
import 'package:dentist_ms/core/constants/app_text_styles.dart';
import 'package:dentist_ms/features/billing/models/treatment.dart';
import 'package:dentist_ms/features/billing/data/treatment_remote.dart';

class AddInvoiceItemDialog extends StatefulWidget {
  final int invoiceId;

  const AddInvoiceItemDialog({Key? key, required this.invoiceId})
    : super(key: key);

  @override
  State<AddInvoiceItemDialog> createState() => _AddInvoiceItemDialogState();
}

class _AddInvoiceItemDialogState extends State<AddInvoiceItemDialog> {
  final _formKey = GlobalKey<FormState>();
  final _descriptionController = TextEditingController();
  final _quantityController = TextEditingController(text: '1');
  final _unitPriceController = TextEditingController();

  int? _selectedTreatmentId;
  List<Treatment> _treatments = [];
  bool _isLoadingTreatments = true;
  double _totalPrice = 0.0;

  @override
  void initState() {
    super.initState();
    _loadTreatments();
    _quantityController.addListener(_calculateTotal);
    _unitPriceController.addListener(_calculateTotal);
  }

  Future<void> _loadTreatments() async {
    try {
      final dataSource = TreatmentRemoteDataSource();
      final treatments = await dataSource.getTreatments();
      setState(() {
        _treatments = treatments;
        _isLoadingTreatments = false;
      });
    } catch (e) {
      setState(() {
        _isLoadingTreatments = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur de chargement des traitements: $e')),
        );
      }
    }
  }

  void _calculateTotal() {
    final quantity = double.tryParse(_quantityController.text) ?? 0.0;
    final unitPrice = double.tryParse(_unitPriceController.text) ?? 0.0;
    setState(() {
      _totalPrice = quantity * unitPrice;
    });
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    _quantityController.dispose();
    _unitPriceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        width: MediaQuery.of(context).size.width * 0.9,
        constraints: const BoxConstraints(maxWidth: 500, maxHeight: 600),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildHeader(),
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
                        _buildTreatmentDropdown(),
                        const SizedBox(height: 16),
                        _buildDescriptionField(),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(child: _buildQuantityField()),
                            const SizedBox(width: 16),
                            Expanded(child: _buildUnitPriceField()),
                          ],
                        ),
                        const SizedBox(height: 16),
                        _buildTotalDisplay(),
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
          Text('Ajouter un article', style: AppTextStyles.headline2),
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

  Widget _buildTreatmentDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Traitement',
          style: AppTextStyles.body1.copyWith(
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        _isLoadingTreatments
            ? const Center(child: CircularProgressIndicator())
            : DropdownButtonFormField<int>(
                value: _selectedTreatmentId,
                decoration: _inputDecoration('Sélectionner un traitement'),
                items: _treatments.map((treatment) {
                  return DropdownMenuItem(
                    value: treatment.id,
                    child: Text(treatment.name ?? ''),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() => _selectedTreatmentId = value);
                  if (value != null) {
                    final treatment = _treatments.firstWhere(
                      (t) => t.id == value,
                    );
                    _descriptionController.text = treatment.name ?? '';
                    if (treatment.basePrice != null) {
                      _unitPriceController.text = treatment.basePrice!
                          .toStringAsFixed(2);
                    }
                  }
                },
                validator: (value) {
                  if (value == null) {
                    return 'Veuillez sélectionner un traitement';
                  }
                  return null;
                },
              ),
      ],
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
          decoration: _inputDecoration('Description de l\'article'),
          maxLines: 2,
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

  Widget _buildQuantityField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quantité',
          style: AppTextStyles.body1.copyWith(
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _quantityController,
          decoration: _inputDecoration('1'),
          keyboardType: TextInputType.number,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Requis';
            }
            if (double.tryParse(value) == null || double.parse(value) <= 0) {
              return 'Invalide';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildUnitPriceField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Prix unitaire',
          style: AppTextStyles.body1.copyWith(
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _unitPriceController,
          decoration: _inputDecoration(
            '0.00',
          ).copyWith(suffixText: '\DA ', suffixStyle: AppTextStyles.body1),
          keyboardType: TextInputType.number,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Requis';
            }
            if (double.tryParse(value) == null) {
              return 'Invalide';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildTotalDisplay() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.05),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.primary.withOpacity(0.2)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Total:',
            style: AppTextStyles.body1.copyWith(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          Text(
            '${_totalPrice.toStringAsFixed(2)} DA',
            style: AppTextStyles.body1.copyWith(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
            ),
          ),
        ],
      ),
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
              'Ajouter l\'article',
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
      final treatment = _treatments.firstWhere(
        (t) => t.id == _selectedTreatmentId,
      );
      final itemData = {
        'treatmentId': _selectedTreatmentId,
        'treatmentName': treatment.name, // For display
        'description': _descriptionController.text, // For database
        'quantity': double.parse(_quantityController.text),
        'unitPrice': double.parse(_unitPriceController.text),
        'totalPrice': _totalPrice,
      };

      Navigator.of(context).pop(itemData);
    }
  }
}
