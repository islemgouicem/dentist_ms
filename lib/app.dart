import 'package:dentist_ms/features/patients/bloc/patient_bloc.dart';
import 'package:dentist_ms/features/patients/bloc/patient_event.dart';
import 'package:flutter/material.dart';
import 'package:dentist_ms/routes.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'core/theme/app_theme.dart';
import 'core/constants/app_routes.dart';

class DentistApp extends StatelessWidget {
  const DentistApp({super.key});

  @override
  Widget build(BuildContext context) {
    context.read<PatientBloc>().add(LoadPatients());
    return MaterialApp(
      title: 'Système de gestion des dentistes',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      initialRoute: AppRoutes.login,
      onGenerateRoute: AppRouter.generateRoute,
    );
  }
}
