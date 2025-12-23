import 'package:flutter/material.dart';
import 'package:dentist_ms/core/constants/app_colors.dart';
import '../dashboard_constants.dart';

class MetricCard extends StatelessWidget {
  const MetricCard({
    super.key,
    required this. color,
    required this.icon,
    required this.trendingIcon,
    required this. title,
    required this.value,
    required this.subNote,
  });

  final Color color;
  final IconData icon;
  final IconData trendingIcon;
  final String title;
  final String value;
  final String subNote;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minHeight: 190),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(kRadiusCard),
        boxShadow:  [
          BoxShadow(
            color: color.withOpacity(0.28),
            blurRadius: 32,
            offset: const Offset(0, 18),
          ),
        ],
      ),
      padding: const EdgeInsets.all(22),
      child: Stack(
        children: [
          Positioned(
            top: 6,
            right: 6,
            child:  Icon(trendingIcon, color: kNeutralIcon. withOpacity(0.9)),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                decoration: BoxDecoration(
                  color: Colors.white. withOpacity(0.18),
                  borderRadius: BorderRadius.circular(14),
                ),
                padding: const EdgeInsets.all(10),
                child: Icon(icon, color: Colors.white, size: 28),
              ),
              const SizedBox(height: 12),
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 15,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 6),
              FittedBox(
                fit:  BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: Text(
                  value,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 36,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              // Only show the trend badge if subNote is not empty
              if (subNote.isNotEmpty) ...[
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.18),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Row(
                    mainAxisSize:  MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.arrow_upward_rounded,
                        size: 16,
                        color: Colors. white,
                      ),
                      const SizedBox(width: 4),
                      Flexible(
                        child: Text(
                          subNote,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            fontSize: 12.5,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}