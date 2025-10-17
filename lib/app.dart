import 'package:flutter/material.dart';
import 'package:dentist_ms/routes.dart';
import 'core/theme/app_theme.dart';
import 'core/constants/app_routes.dart';

class DentistApp extends StatelessWidget {
  const DentistApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Dentist Management System',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      initialRoute: AppRoutes.login,
      onGenerateRoute: AppRouter.generateRoute,
    );
  }
}
