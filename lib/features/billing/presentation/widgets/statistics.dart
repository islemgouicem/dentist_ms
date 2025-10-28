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
  final String? trendPercentage;
  final bool? isPositiveTrend;

  const BillingStatCard({
    Key? key,
    required this.title,
    required this.value,
    required this.icon,
    required this.iconColor,
    required this.backgroundColor,
    this.trendPercentage,
    this.isPositiveTrend,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: AppColors.shadow.withOpacity(0.08),
              blurRadius: 20,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: backgroundColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: iconColor, size: 24),
                ),
                if (trendPercentage != null && isPositiveTrend != null)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: isPositiveTrend!
                          ? AppColors.statusCompleted.withOpacity(0.1)
                          : AppColors.statusCancelled.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          isPositiveTrend!
                              ? Icons.arrow_upward
                              : Icons.arrow_downward,
                          size: 14,
                          color: isPositiveTrend!
                              ? AppColors.statusCompleted
                              : AppColors.statusCancelled,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          trendPercentage!,
                          style: AppTextStyles.smallLabel.copyWith(
                            color: isPositiveTrend!
                                ? AppColors.statusCompleted
                                : AppColors.statusCancelled,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: AppTextStyles.smallLabel.copyWith(
                color: AppColors.textSecondary,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: AppTextStyles.numberHighlight.copyWith(
                color: AppColors.textPrimary,
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
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

    if (responsive.isTablet) {
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
        trendPercentage: '+20%',
        isPositiveTrend: true,
      ),
      BillingStatCard(
        title: 'Paiements en attente',
        value: '\$${_formatCurrency(pendingPayments)}',
        icon: Icons.pending_actions,
        iconColor: AppColors.cardOrange,
        backgroundColor: AppColors.cardOrange.withOpacity(0.1),
        trendPercentage: '-15%',
        isPositiveTrend: false,
      ),
      BillingStatCard(
        title: 'En retard',
        value: '\$${_formatCurrency(overdue)}',
        icon: Icons.warning_amber,
        iconColor: AppColors.statusCancelled,
        backgroundColor: AppColors.statusCancelled.withOpacity(0.1),
        trendPercentage: '+18%',
        isPositiveTrend: false,
      ),
      BillingStatCard(
        title: 'Ce mois-ci',
        value: '\$${_formatCurrency(thisMonth)}',
        icon: Icons.calendar_today,
        iconColor: AppColors.cardBlue,
        backgroundColor: AppColors.cardBlue.withOpacity(0.1),
        trendPercentage: '+12%',
        isPositiveTrend: true,
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
