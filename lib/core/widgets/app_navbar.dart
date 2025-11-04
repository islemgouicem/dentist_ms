import 'package:dentist_ms/core/constants/app_colors.dart';
import 'package:dentist_ms/core/constants/app_text_styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class AppNavbar extends StatefulWidget {
  final int selectedIndex;
  final Function(int) onItemSelected;
  final int patientsN;
  final int appointmentsN;
  final int billingsN;

  const AppNavbar({
    super.key,
    required this.selectedIndex,
    required this.onItemSelected,
    required this.patientsN,
    required this.appointmentsN,
    required this.billingsN,
  });

  @override
  State<AppNavbar> createState() => _AppNavbarState();
}

class _AppNavbarState extends State<AppNavbar> {
  bool _isCollapsed = false;

  late final List<Map<String, String>> navItems = [
    {"title": "Dashboard", "icon": "assets/icons/dashboard.svg"},
    {
      "title": "Patients",
      "icon": "assets/icons/patients.svg",
      "counter": widget.patientsN.toString(),
    },
    {
      "title": "Appointments",
      "icon": "assets/icons/appointments.svg",
      "counter": widget.appointmentsN.toString(),
    },
    {
      "title": "Billing",
      "icon": "assets/icons/billing.svg",
      "counter": widget.billingsN.toString(),
    },
  ];

  Widget _buildNavItem(
    String title,
    String iconPath,
    int index, {
    String counter = "0",
  }) {
    final selected = widget.selectedIndex == index;

    return InkWell(
      onTap: () => widget.onItemSelected(index),
      borderRadius: BorderRadius.circular(14),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: selected ? AppColors.selectedPage : null,
        child: Row(
          mainAxisAlignment: _isCollapsed
              ? MainAxisAlignment.center
              : MainAxisAlignment.start,
          children: [
            SvgPicture.asset(
              iconPath,
              width: 24,
              height: 24,
              color: selected ? Colors.white : null,
            ),
            if (!_isCollapsed) ...[
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  title,
                  style: AppTextStyles.body1.copyWith(
                    color: selected ? Colors.white : null,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (counter != "0")
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: selected ? Colors.white : AppColors.azure,
                    ),
                    borderRadius: BorderRadius.circular(50),
                  ),
                  child: Text(
                    counter,
                    style: AppTextStyles.body1.copyWith(
                      color: selected ? Colors.white : AppColors.azure_2,
                      fontSize: 12,
                    ),
                  ),
                ),
            ],
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    double expandedWidth;
    if (screenWidth >= 1400) {
      expandedWidth = 260;
    } else if (screenWidth >= 1200) {
      expandedWidth = 230;
    } else if (screenWidth >= 1000) {
      expandedWidth = 200;
    } else if (screenWidth >= 800) {
      expandedWidth = 180;
    } else {
      expandedWidth = 150;
    }

    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      width: _isCollapsed ? 80 : expandedWidth,
      decoration: AppColors.navBarBackground,
      child: Column(
        crossAxisAlignment: _isCollapsed
            ? CrossAxisAlignment.center
            : CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.symmetric(vertical: 10),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(width: 1, color: AppColors.azure_2),
              ),
            ),
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (!_isCollapsed) ...[
                      Container(
                        decoration: AppColors.selectedPage.copyWith(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        padding: EdgeInsets.all(8),
                        child: SvgPicture.asset(
                          "assets/icons/pfp.svg",
                          width: 25,
                          height: 25,
                        ),
                      ),
                      SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: const [
                            Text(
                              'Dental clinic',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              'Clinic Management',
                              style: TextStyle(
                                color: Colors.grey,
                                fontSize: 12,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ],

                    Container(
                      decoration: _isCollapsed
                          ? BoxDecoration(
                              border: Border.all(color: AppColors.azure),
                              borderRadius: BorderRadius.circular(10),
                            )
                          : null,
                      child: IconButton(
                        icon: AnimatedRotation(
                          duration: const Duration(milliseconds: 200),
                          turns: _isCollapsed ? 0.5 : 0,
                          child: const Icon(
                            Icons.chevron_left,
                            size: 28,
                            color: Colors.white,
                          ),
                        ),
                        onPressed: () {
                          setState(() {
                            _isCollapsed = !_isCollapsed;
                          });
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Column(
                children: [
                  SizedBox(height: 40),
                  ...List.generate(
                    navItems.length,
                    (index) => _buildNavItem(
                      navItems[index]["title"]!,
                      navItems[index]["icon"]!,
                      index,
                      counter: navItems[index]["counter"] ?? "0",
                    ),
                  ),
                  const Spacer(),
                  // Settings at bottom
                  _buildNavItem("Settings", "assets/icons/settings.svg", 4),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
