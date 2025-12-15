import 'package:flutter/material.dart';
import 'package:dentist_ms/core/constants/app_colors.dart';
import 'package:dentist_ms/core/constants/app_text_styles.dart';
import '../../models/treatment.dart';

class TreatmentDetailsDialog extends StatelessWidget {
  final Treatment treatment;

  const TreatmentDetailsDialog({
    Key? key,
    required this.treatment,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        width: MediaQuery.of(context).size.width * 0.9,
        constraints: const BoxConstraints(maxWidth: 600, maxHeight: 500),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildHeader(context),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildDetailRow(
                      icon: Icons.code,
                      label: 'Code',
                      value: treatment.code ?? 'N/A',
                      color: AppColors.primary,
                    ),
                    const SizedBox(height: 20),
                    _buildDetailRow(
                      icon: Icons.medical_services,
                      label: 'Nom du traitement',
                      value: treatment.name ?? 'N/A',
                      color: AppColors.cardGreen,
                    ),
                    const SizedBox(height: 20),
                    _buildDetailRow(
                      icon: Icons.attach_money,
                      label: 'Prix',
                      value: '\$${treatment.basePrice?.toStringAsFixed(2) ?? '0.00'}',
                      color: Colors.green,
                      isHighlighted: true,
                    ),
                    const SizedBox(height: 20),
                    _buildDescriptionSection(),
                    const SizedBox(height: 20),
                    _buildTimestamps(),
                  ],
                ),
              ),
            ),
            _buildActions(context),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
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
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.medical_information,
              color: AppColors.primary,
              size: 28,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Détails du traitement',
                  style: AppTextStyles.headline2,
                ),
                const SizedBox(height: 4),
                Text(
                  treatment.name ?? 'N/A',
                  style: AppTextStyles.body1.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => Navigator.of(context).pop(),
            color: AppColors.textSecondary,
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
    bool isHighlighted = false,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isHighlighted ? color.withOpacity(0.05) : AppColors.cardgrey,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isHighlighted ? color.withOpacity(0.3) : AppColors.border,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: AppTextStyles.body1.copyWith(
                    color: AppColors.textSecondary,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: AppTextStyles.body1.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDescriptionSection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardgrey,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.description,
                color: AppColors.textSecondary,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Description',
                style: AppTextStyles.body1.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            treatment.description?.isNotEmpty == true
                ? treatment.description!
                : 'Aucune description disponible',
            style: AppTextStyles.body1.copyWith(
              color: treatment.description?.isNotEmpty == true
                  ? AppColors.textPrimary
                  : AppColors.textSecondary,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimestamps() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardgrey.withOpacity(0.5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          if (treatment.createdAt != null) ...[
            _buildTimestampRow(
              icon: Icons.calendar_today,
              label: 'Date de création',
              value: _formatDate(treatment.createdAt!),
            ),
          ],
          if (treatment.createdAt != null && treatment.updatedAt != null)
            const SizedBox(height: 12),
          if (treatment.updatedAt != null) ...[
            _buildTimestampRow(
              icon: Icons.update,
              label: 'Dernière modification',
              value: _formatDate(treatment.updatedAt!),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildTimestampRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      children: [
        Icon(icon, color: AppColors.textSecondary, size: 16),
        const SizedBox(width: 8),
        Text(
          label,
          style: AppTextStyles.body1.copyWith(
            color: AppColors.textSecondary,
            fontSize: 13,
          ),
        ),
        const Spacer(),
        Text(
          value,
          style: AppTextStyles.body1.copyWith(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w500,
            fontSize: 13,
          ),
        ),
      ],
    );
  }

  Widget _buildActions(BuildContext context) {
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
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text(
              'Fermer',
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

  String _formatDate(DateTime date) {
    final months = [
      'Jan', 'Fév', 'Mar', 'Avr', 'Mai', 'Juin',
      'Juil', 'Août', 'Sep', 'Oct', 'Nov', 'Déc'
    ];
    
    return '${date.day} ${months[date.month - 1]} ${date.year} à ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }
}
