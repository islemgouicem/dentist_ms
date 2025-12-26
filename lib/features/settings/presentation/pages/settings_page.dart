import 'package:dentist_ms/core/constants/app_colors.dart';
import 'package:dentist_ms/core/constants/app_text_styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../widgets/profil_widget.dart';
import '../widgets/clinic_widget.dart';
import '../widgets/security_widget.dart';
import 'package:dentist_ms/features/settings/bloc/setting_bloc.dart';
import 'package:dentist_ms/features/settings/repositories/setting_repository.dart';
import 'package:dentist_ms/features/settings/data/setting_remote.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  late double width;
  late double height;
  int current_page = 1;

  final ProfilControllers profilControllers = ProfilControllers();
  final SecurityControllers securityControllers = SecurityControllers();

  @override
  void dispose() {
    profilControllers.dispose();
    securityControllers.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => SettingBloc(
        repository: SupabaseSettingRepository(
          remote: SettingRemoteDataSource(),
        ),
      ),
      child: _buildSettingsContent(),
    );
  }

  Widget _buildSettingsContent() {
    width = MediaQuery.of(context).size.width;
    height = MediaQuery.of(context).size.height;

    Widget currentWidget;
    if (current_page == 1) {
      currentWidget = clinic(context, width, height); 
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
            padding: EdgeInsets.symmetric(vertical: height * 0.026, horizontal: width * 0.02),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header Section
                Text("Paramètres", style: Theme.of(context).textTheme.titleLarge),
                SizedBox(height: height * 0.005),
                Text("Gérer les préférences et les configurations de la clinique", style: AppTextStyles.subtitle1),
                SizedBox(height: height * 0.015),
                
                // Navigation Tabs
                Container(
                  decoration: BoxDecoration(color: AppColors.textFieldBackground, borderRadius: BorderRadius.circular(30)),
                  child: Padding(
                    padding: const EdgeInsets.all(4.0),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _buildNavigationTab(
                          index: 1,
                          icon: Icons.local_hospital_outlined,
                          label: 'Clinic Info',
                          activeIcon: Icons.local_hospital,
                        ),
                        SizedBox(width: width * 0.005),
                        _buildNavigationTab(
                          index: 2,
                          icon: Icons.person_outline,
                          label: 'Profil',
                          activeIcon: Icons.person,
                        ),
                        SizedBox(width: width * 0.005),
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
                
                SizedBox(height: height * 0.018),
                currentWidget
              ],
            ),
          ),
        ),
      ),
    );
  }
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
            offset: const Offset(0, 2),
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

  void swap_widget(int i) {
    setState(() {current_page = i;});
  }
}