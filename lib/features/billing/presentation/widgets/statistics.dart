import 'package:flutter/material.dart';
import 'package:dentist_ms/core/constants/app_colors.dart';
import 'package:dentist_ms/core/constants/app_text_styles.dart';
import '../../utils/billing_responsive_helper.dart';

class BillingStatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color iconColor;
  final Color backgroundColor;

  const BillingStatCard({
    Key? key,
    required this.title,
    required this.value,
    required this.icon,
    required this.iconColor,
    required this.backgroundColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(20),
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
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: backgroundColor,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: iconColor, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    title,
                    style: AppTextStyles.smallLabel,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    value,
                    style: AppTextStyles.numberHighlight.copyWith(
                      color: AppColors.textPrimary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class BillingStatisticsSection extends StatelessWidget {
  final BillingResponsiveHelper responsive;
  final double totalRevenue;
  final double pendingPayments;
  final double overdue;
  final double thisMonth;

  const BillingStatisticsSection({
    Key? key,
    required this.responsive,
    required this.totalRevenue,
    required this.pendingPayments,
    required this.overdue,
    required this.thisMonth,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final cards = _buildCards();

    if (responsive.isMobile) {
      return Column(
        children: cards
            .map(
              (card) => Padding(
                padding: const EdgeInsets.only(bottom: 12.0),
                child: card,
              ),
            )
            .toList(),
      );
    } else if (responsive.isTablet) {
      return Column(
        children: [
          Row(children: [cards[0], const SizedBox(width: 12), cards[1]]),
          const SizedBox(height: 12),
          Row(children: [cards[2], const SizedBox(width: 12), cards[3]]),
        ],
      );
    } else {
      return Row(
        children: [
          cards[0],
          const SizedBox(width: 16),
          cards[1],
          const SizedBox(width: 16),
          cards[2],
          const SizedBox(width: 16),
          cards[3],
        ],
      );
    }
  }

  List<Widget> _buildCards() {
    return [
      BillingStatCard(
        title: 'Revenu total',
        value: '\$${_formatCurrency(totalRevenue)}',
        icon: Icons.attach_money,
        iconColor: AppColors.cardGreen,
        backgroundColor: AppColors.cardGreen.withOpacity(0.1),
      ),
      BillingStatCard(
        title: 'Paiements en attente',
        value: '\$${_formatCurrency(pendingPayments)}',
        icon: Icons.pending_actions,
        iconColor: AppColors.cardOrange,
        backgroundColor: AppColors.cardOrange.withOpacity(0.1),
      ),
      BillingStatCard(
        title: 'En retard',
        value: '\$${_formatCurrency(overdue)}',
        icon: Icons.warning_amber,
        iconColor: AppColors.statusCancelled,
        backgroundColor: AppColors.statusCancelled.withOpacity(0.1),
      ),
      BillingStatCard(
        title: 'Ce mois-ci',
        value: '\$${_formatCurrency(thisMonth)}',
        icon: Icons.calendar_today,
        iconColor: AppColors.cardBlue,
        backgroundColor: AppColors.cardBlue.withOpacity(0.1),
      ),
    ];
  }

  String _formatCurrency(double amount) {
    if (amount >= 1000) {
      return '${(amount / 1000).toStringAsFixed(amount % 1000 == 0 ? 0 : 1)}k';
    }
    return amount.toStringAsFixed(amount % 1 == 0 ? 0 : 2);
  }
}
