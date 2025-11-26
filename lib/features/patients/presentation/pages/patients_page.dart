import 'package:dentist_ms/features/patients/data/models/patient_model.dart';
import 'package:dentist_ms/features/patients/data/repositories/patient_repository.dart';
import 'package:dentist_ms/features/patients/presentation/bloc/bloc.dart';
import 'package:dentist_ms/features/patients/presentation/widgets/patient_form_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

class PatientsPage extends StatelessWidget {
  const PatientsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => PatientBloc()..add(const LoadPatients()),
      child: const _PatientsPageContent(),
    );
  }
}

class _PatientsPageContent extends StatefulWidget {
  const _PatientsPageContent();

  @override
  State<_PatientsPageContent> createState() => _PatientsPageContentState();
}

class _PatientsPageContentState extends State<_PatientsPageContent> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _showAddPatientDialog() {
    showDialog(
      context: context,
      builder: (dialogContext) => PatientFormDialog(
        onSave: (patient) {
          context.read<PatientBloc>().add(AddPatient(patient));
        },
      ),
    );
  }

  void _showEditPatientDialog(Patient patient) {
    showDialog(
      context: context,
      builder: (dialogContext) => PatientFormDialog(
        patient: patient,
        onSave: (updatedPatient) {
          context.read<PatientBloc>().add(UpdatePatient(updatedPatient));
        },
      ),
    );
  }

  void _deletePatient(Patient patient) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete Patient'),
        content: Text(
            'Are you sure you want to delete ${patient.fullName}? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              Navigator.of(dialogContext).pop();
              if (patient.id != null) {
                context.read<PatientBloc>().add(DeletePatient(patient.id!));
              }
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<PatientBloc, PatientState>(
      listener: (context, state) {
        if (state is PatientOperationSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: Colors.green,
            ),
          );
        } else if (state is PatientError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
      builder: (context, state) {
        // Extract data from state
        List<Patient> patients = [];
        PatientStats? stats;
        bool isLoading = state is PatientLoading;

        if (state is PatientLoaded) {
          patients = state.patients;
          stats = state.stats;
        } else if (state is PatientOperationInProgress) {
          patients = state.patients;
          stats = state.stats;
          isLoading = true;
        } else if (state is PatientOperationSuccess) {
          patients = state.patients;
          stats = state.stats;
        } else if (state is PatientError) {
          patients = state.patients;
          stats = state.stats;
        }

        return Scaffold(
          backgroundColor: Colors.grey[50],
          body: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                // Header Section
                _buildHeader(),
                const SizedBox(height: 24),

                // Stats Cards
                _buildStatsRow(stats),
                const SizedBox(height: 24),

                // Search and Filter Row
                _buildSearchRow(),
                const SizedBox(height: 24),

                // Patients List
                Expanded(
                  child: isLoading && patients.isEmpty
                      ? const Center(child: CircularProgressIndicator())
                      : _buildPatientsTable(patients),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Patient Management",
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[800],
                ),
              ),
              const SizedBox(height: 8),
              Text(
                "Manage and view all patient records",
                style: TextStyle(fontSize: 14, color: Colors.grey[600]),
              ),
            ],
          ),
        ),
        Container(
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF2196F3), Color(0xFF00BCD4)],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
            borderRadius: BorderRadius.circular(8),
          ),
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.transparent,
              shadowColor: Colors.transparent,
              padding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 12,
              ),
            ),
            onPressed: _showAddPatientDialog,
            child: const Row(
              children: [
                Icon(Icons.add, color: Colors.white),
                SizedBox(width: 8),
                Text(
                  "Add New Patient",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatsRow(PatientStats? stats) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _buildStatCard(
          'Total Patients',
          stats?.totalPatients ?? 0,
          Icons.people_outline,
          Colors.blue,
        ),
        _buildStatCard(
          'Active Patients',
          stats?.activePatients ?? 0,
          Icons.monitor_heart_outlined,
          Colors.green,
        ),
        _buildStatCard(
          'New This Month',
          stats?.newThisMonth ?? 0,
          Icons.person_add_outlined,
          Colors.orange,
        ),
        _buildStatCard(
          'Pending Balance',
          stats?.pendingBalance.toInt() ?? 0,
          Icons.attach_money_outlined,
          Colors.purple,
          isMoney: true,
        ),
      ],
    );
  }

  Widget _buildSearchRow() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search patients by name, ID, or email...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.grey[100],
                prefixIcon: const Icon(Icons.search),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
              onChanged: (value) {
                context.read<PatientBloc>().add(SearchPatients(value));
              },
            ),
          ),
          const SizedBox(width: 16),
          OutlinedButton.icon(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              _searchController.clear();
              context.read<PatientBloc>().add(const LoadPatients());
            },
            label: const Text("Refresh"),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPatientsTable(List<Patient> patients) {
    if (patients.isEmpty) {
      return Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withValues(alpha: 0.1),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.people_outline, size: 64, color: Colors.grey[400]),
              const SizedBox(height: 16),
              Text(
                'No patients found',
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Add a new patient to get started',
                style: TextStyle(fontSize: 14, color: Colors.grey[500]),
              ),
            ],
          ),
        ),
      );
    }

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: SingleChildScrollView(
        child: DataTable(
          columnSpacing: 24,
          horizontalMargin: 16,
          headingRowColor: WidgetStateProperty.all(Colors.grey[50]),
          dataRowMaxHeight: 80,
          columns: const [
            DataColumn(
              label: Text(
                'Patient',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            DataColumn(
              label: Text(
                'Contact',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            DataColumn(
              label: Text(
                'Last Visit',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            DataColumn(
              label: Text(
                'Upcoming',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            DataColumn(
              label: Text(
                'Status',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            DataColumn(
              label: Text(
                'Balance',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            DataColumn(
              label: Text(
                'Actions',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ],
          rows: patients.map((patient) => _buildPatientRow(patient)).toList(),
        ),
      ),
    );
  }

  DataRow _buildPatientRow(Patient patient) {
    final dateFormat = DateFormat('yyyy-MM-dd');

    return DataRow(
      cells: [
        DataCell(
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: _getAvatarColor(patient.initials),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Center(
                  child: Text(
                    patient.initials,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    patient.fullName,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  Text(
                    '${patient.id?.substring(0, 8) ?? 'N/A'} • ${patient.age ?? '-'}y, ${patient.gender ?? '-'}',
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                  Text(
                    patient.email ?? '-',
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                ],
              ),
            ],
          ),
        ),
        DataCell(Text(patient.phone ?? '-')),
        DataCell(Text(
            patient.lastVisit != null ? dateFormat.format(patient.lastVisit!) : '-')),
        DataCell(Text(patient.nextAppointment != null
            ? dateFormat.format(patient.nextAppointment!)
            : '-')),
        DataCell(
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: patient.status == 'active'
                  ? Colors.green[50]
                  : Colors.grey[200],
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color:
                    patient.status == 'active' ? Colors.green : Colors.grey,
                width: 1,
              ),
            ),
            child: Text(
              patient.status.toUpperCase(),
              style: TextStyle(
                color:
                    patient.status == 'active' ? Colors.green : Colors.grey,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        DataCell(
          Text(
            patient.balance == 0
                ? '\$0'
                : '\$${patient.balance.toStringAsFixed(0)}',
            style: TextStyle(
              color: patient.balance == 0 ? Colors.grey : Colors.red,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        DataCell(
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.edit_outlined, size: 20),
                onPressed: () => _showEditPatientDialog(patient),
              ),
              IconButton(
                icon: const Icon(Icons.delete_outlined, size: 20),
                onPressed: () => _deletePatient(patient),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Color _getAvatarColor(String text) {
    final colors = [
      Colors.blue,
      Colors.green,
      Colors.orange,
      Colors.purple,
      Colors.red,
      Colors.teal,
    ];
    final index = text.codeUnits.fold(0, (a, b) => a + b) % colors.length;
    return colors[index];
  }

  Widget _buildStatCard(
    String title,
    int value,
    IconData iconData,
    Color color, {
    bool isMoney = false,
  }) {
    return Expanded(
      child: Card(
        elevation: 3.5,
        shadowColor: Colors.grey.withValues(alpha: 0.2),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      isMoney ? '\$$value' : value.toString(),
                      style: const TextStyle(
                        fontSize: 20,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(iconData, color: color, size: 24),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
