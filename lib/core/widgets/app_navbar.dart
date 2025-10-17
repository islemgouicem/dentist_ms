import 'package:dentist_ms/core/constants/app_colors.dart';
import 'package:dentist_ms/core/constants/app_text_styles.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter/material.dart';

class AppNavbar extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onItemSelected;

  const AppNavbar({
    super.key,
    required this.selectedIndex,
    required this.onItemSelected,
  });

  // List of navbar items with their titles and icon paths
  final List<Map<String, String>> navItems = const [
    {"title": "Dashboard", "icon": "assets/icons/dashboard.svg"},
    {"title": "Patients", "icon": "assets/icons/patients.svg"},
    {"title": "Appointments", "icon": "assets/icons/appointments.svg"},
    {"title": "Billing", "icon": "assets/icons/billing.svg"},
    {"title": "Settings", "icon": "assets/icons/settings.svg"},
  ];

  Widget _buildNavItem(String title, String iconPath, int index) {
    final selected = selectedIndex == index;
    return InkWell(
      onTap: () => onItemSelected(index),
      borderRadius: BorderRadius.circular(14),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
        decoration: selected ? AppColors.selectedPage : null,
        child: Row(
          children: [
            SvgPicture.asset(
              iconPath,
              width: 24,
              height: 24,
              fit: BoxFit.contain,
              color: selected
                  ? Colors.white
                  : null, // optional tint for selected
            ),
            const SizedBox(width: 10),
            Text(
              title,
              style: AppTextStyles.body1.copyWith(
                color: selected ? Colors.white : null,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 250,
      decoration: AppColors.navBarBackground,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 30),
          Center(
            child: Text(
              "Dentist",
              style: AppTextStyles.body1.copyWith(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 30),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Column(
              children: List.generate(
                navItems.length,
                (index) => _buildNavItem(
                  navItems[index]["title"]!,
                  navItems[index]["icon"]!,
                  index,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
