import 'package:dentist_ms/features/patients/presentation/pages/patient_profile.dart';
import 'package:dentist_ms/features/patients/presentation/pages/patients_dashboard.dart';
import 'package:flutter/material.dart';

class PatientsPage extends StatefulWidget {
  const PatientsPage({super.key});

  @override
  State<PatientsPage> createState() => _PatientsPageState();
}

class _PatientsPageState extends State<PatientsPage> {
  Map<String, dynamic>? selectedPatient;

  void selectPatient(Map<String, dynamic> patient) {
    setState(() {
      selectedPatient = patient;
    });
  }

  void backToTable() {
    setState(() {
      selectedPatient = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return selectedPatient == null
        ? PatientsDashboard(onPatientSelected: selectPatient)
        : PatientDetailScreen(patient: selectedPatient!, onBack: backToTable);
  }
}
