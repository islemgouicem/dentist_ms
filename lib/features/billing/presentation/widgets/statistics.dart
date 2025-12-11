import 'package:flutter/material.dart';
import 'package:dentist_ms/core/constants/app_colors.dart';
import 'package:dentist_ms/core/constants/app_text_styles.dart';
import '../../utils/billing_responsive_helper.dart';

class BillingStatCard extends StatefulWidget {
  final String title;
  final String value;
  final Color color;
  final IconData icon;

  const BillingStatCard({
    Key? key,
    required this.title,
    required this.value,
    required this.color,
    required this.icon,
  }) : super(key: key);

  @override
  State<BillingStatCard> createState() => _BillingStatCardState();
}

class _BillingStatCardState extends State<BillingStatCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: MouseRegion(
        onEnter: (_) => setState(() => _isHovered = true),
        onExit: (_) => setState(() => _isHovered = false),
        cursor: SystemMouseCursors.click,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: _isHovered
                  ? widget.color.withOpacity(0.5)
                  : const Color(0xFFE5E7EB),
              width: _isHovered ? 2 : 1,
            ),
            boxShadow: [
              if (_isHovered)
                BoxShadow(
                  color: widget.color.withOpacity(0.2),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: widget.color,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      widget.title,
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                  ),
                  Icon(widget.icon, color: widget.color, size: 20),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                widget.value,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
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
        color: AppColors.cardGreen,
        icon: Icons.attach_money,
      ),
      BillingStatCard(
        title: 'Paiements en attente',
        value: '\$${_formatCurrency(pendingPayments)}',
        color: AppColors.cardOrange,
        icon: Icons.pending_actions,
      ),
      BillingStatCard(
        title: 'En retard',
        value: '\$${_formatCurrency(overdue)}',
        color: AppColors.statusCancelled,
        icon: Icons.warning_amber,
      ),
      BillingStatCard(
        title: 'Ce mois-ci',
        value: '\$${_formatCurrency(thisMonth)}',
        color: AppColors.cardBlue,
        icon: Icons.calendar_today,
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
