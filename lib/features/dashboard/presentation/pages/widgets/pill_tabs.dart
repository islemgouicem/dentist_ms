import 'package:flutter/material.dart';
import 'package:dentist_ms/core/constants/app_colors.dart';
import '../dashboard_constants.dart';

class PillTabs extends StatelessWidget {
  const PillTabs({
    super.key,
    required this.items,
    required this.currentIndex,
    required this.onChanged,
  });

  final List<String> items;
  final int currentIndex;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: kSurface,
        borderRadius: BorderRadius.circular(kRadiusCard),
        border: Border.all(color: kBorder),
      ),
      padding: const EdgeInsets.all(8),
      child: Row(
        children: [
          for (int i = 0; i < items.length; i++)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 6),
              child: InkWell(
                onTap: () => onChanged(i),
                borderRadius: BorderRadius.circular(kRadiusPill),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: currentIndex == i ? kBg : Colors.transparent,
                    borderRadius: BorderRadius.circular(kRadiusPill),
                  ),
                  child: Text(
                    items[i],
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      color: currentIndex == i ? kTextPrimary : kTextSecondary,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
