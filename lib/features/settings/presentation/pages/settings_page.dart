import 'package:dentist_ms/core/constants/app_colors.dart';
import 'package:dentist_ms/core/constants/app_text_styles.dart';
import 'package:flutter/material.dart';
import '../widgets/profil_widget.dart';
import '../widgets/clinic_widget.dart';
import '../widgets/security_widget.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  // define needed variable to controll the width, height, current_widget
  late double width;
  late double height;

  int current_page = 1;

  final ClinicControllers clinicControllers = ClinicControllers();
  final ProfilControllers profilControllers = ProfilControllers();
  final SecurityControllers securityControllers = SecurityControllers();

  @override
  void dispose() {
    clinicControllers.dispose(); // Important: dispose controllers
    profilControllers.dispose();
    securityControllers.dispose();
    super.dispose();
  }

  // helper function
  void swap_widget(int i){
    setState(() {current_page = i;});
  }

  @override
  Widget build(BuildContext context) {

    width = MediaQuery.of(context).size.width;
    height = MediaQuery.of(context).size.height;

    // Choose which widget to show
    Widget currentWidget;
    if (current_page == 1) {
      currentWidget = clinic(context, width, height, clinicControllers); 
    } else if (current_page == 2) {
      currentWidget = profil(context, width, height, profilControllers);
    } else {
      currentWidget = security(context, width, height, securityControllers);
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SingleChildScrollView(
        child: Center(
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: height * 0.026, horizontal: width * 0.02 ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header Section
                Text("Paramètres", style: Theme.of(context).textTheme.titleLarge),
                SizedBox(height: height * 0.005),
                Text("Gérer les préférences et les configurations de la clinique", style: AppTextStyles.subtitle1),
                SizedBox(height: height * 0.03),
                
                // Navigation Tabs
                Container(
                  decoration: BoxDecoration(color: AppColors.textFieldBackground, borderRadius: BorderRadius.circular(30)),
                  child: Padding(
                    padding: const EdgeInsets.all(4.0),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Clinic Info Tab
                        _buildNavigationTab(
                          index: 1,
                          icon: Icons.local_hospital_outlined,
                          label: 'Clinic Info',
                          activeIcon: Icons.local_hospital,
                        ),
                        SizedBox(width: width * 0.005),
                        
                        // Profile Tab
                        _buildNavigationTab(
                          index: 2,
                          icon: Icons.person_outline,
                          label: 'Profil',
                          activeIcon: Icons.person,
                        ),
                        SizedBox(width: width * 0.005),
                        
                        // Security Tab
                        _buildNavigationTab(
                          index: 3,
                          icon: Icons.lock_outline,
                          label: 'Sécurité',
                          activeIcon: Icons.lock,
                        ),
                      ],
                    ),
                  ),
                ),
                
                SizedBox(height: height * 0.04),
                currentWidget
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Helper method to build navigation tabs
  Widget _buildNavigationTab({
    required int index,
    required IconData icon,
    required IconData activeIcon,
    required String label,
  }) {
    final isActive = current_page == index;
    
    return Container(
      decoration: BoxDecoration(
        color: isActive ? AppColors.white : Colors.transparent,
        borderRadius: BorderRadius.circular(25),
        boxShadow: isActive ? [
          BoxShadow(
            color: AppColors.shadow.withOpacity(0.1),
            blurRadius: 8,
            offset: Offset(0, 2),
          )
        ] : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(25),
          onTap: () => swap_widget(index),
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: width * 0.025, vertical: height * 0.012),
            constraints: BoxConstraints(minWidth: width * 0.09),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  isActive ? activeIcon : icon,
                  size: 18,
                  color: isActive ? AppColors.primary : AppColors.textSecondary,
                ),
                SizedBox(width: width * 0.01),
                Text(
                  label,
                  style: isActive ? AppTextStyles.focused_label : AppTextStyles.unfocused_label 
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
 
}