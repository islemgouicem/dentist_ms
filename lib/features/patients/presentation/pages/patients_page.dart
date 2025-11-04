import 'package:dentist_ms/core/constants/app_colors.dart';
import 'package:flutter/material.dart';

class PatientsPage extends StatefulWidget {
  const PatientsPage({super.key});

  @override
  State<PatientsPage> createState() => _PatientsPageState();
}

class _PatientsPageState extends State<PatientsPage> {
  var totalPatients = 2847;
  var activePatients = 2145;
  var newPatients = 127;
  var balance = 12340;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Header Section
            Row(
              children: [
                // Text Section
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

                // Add Patient Button
                LayoutBuilder(
                  builder: (context, constraints) {
                    if (constraints.maxWidth < 600) {
                      // Small screen - button goes below
                      return Container(
                        width: double.infinity,
                        margin: const EdgeInsets.only(top: 16),
                        child: Container(
                          decoration: AppColors.selectedPage,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.transparent,
                              shadowColor: Colors.transparent,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                            onPressed: () {},
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
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
                      );
                    } else {
                      // Normal screen
                      return Container(
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
                          onPressed: () {},
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
                      );
                    }
                  },
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Stats Cards
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildStatCard(
                  'Total Patients',
                  totalPatients,
                  Icons.people_outline,
                  Colors.blue,
                ),
                _buildStatCard(
                  'Active Patients',
                  activePatients,
                  Icons.monitor_heart_outlined,
                  Colors.green,
                ),
                _buildStatCard(
                  'New This Month',
                  newPatients,
                  Icons.person_add_outlined,
                  Colors.orange,
                ),
                _buildStatCard(
                  'Pending Balance',
                  balance,
                  Icons.attach_money_outlined,
                  Colors.purple,
                  isMoney: true,
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Search and Filter Row
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
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
                        // TODO: Add filtering logic
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  OutlinedButton.icon(
                    icon: const Icon(Icons.filter_alt_outlined),
                    onPressed: () {},
                    label: const Text("Filters"),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  OutlinedButton.icon(
                    icon: const Icon(Icons.arrow_upward),
                    onPressed: () {},
                    label: const Text("Export"),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Patients List
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: SingleChildScrollView(
                  child: DataTable(
                    columnSpacing: 24,
                    horizontalMargin: 16,
                    headingRowColor: MaterialStateProperty.all(Colors.grey[50]),
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
                    rows: [
                      _buildPatientRow(
                        avatarText: 'JS',
                        name: 'John Smith',
                        id: 'P001 • 42y, Male',
                        email: 'john.smith@email.com',
                        contact: '+1 (555) 123-4567',
                        lastVisit: '2025-10-08',
                        upcoming: '2025-10-15',
                        status: 'active',
                        balance: 0,
                      ),
                      _buildPatientRow(
                        avatarText: 'EW',
                        name: 'Emma Wilson',
                        id: 'P002 • 28y, Female',
                        email: 'emma.w@email.com',
                        contact: '+1 (555) 234-5678',
                        lastVisit: '2025-10-10',
                        upcoming: '2025-10-14',
                        status: 'active',
                        balance: 450,
                      ),
                      _buildPatientRow(
                        avatarText: 'MB',
                        name: 'Michael Brown',
                        id: 'P003 • 35y, Male',
                        email: 'mbrown@email.com',
                        contact: '+1 (555) 345-6789',
                        lastVisit: '2025-09-25',
                        upcoming: '-',
                        status: 'active',
                        balance: 0,
                      ),
                      _buildPatientRow(
                        avatarText: 'SD',
                        name: 'Sarah Davis',
                        id: 'P004 • 51y, Female',
                        email: 'sdavis@email.com',
                        contact: '+1 (555) 456-7890',
                        lastVisit: '2025-10-05',
                        upcoming: '2025-11-02',
                        status: 'active',
                        balance: 280,
                      ),
                      _buildPatientRow(
                        avatarText: 'JT',
                        name: 'James Taylor',
                        id: 'P005 • 19y, Male',
                        email: 'jtaylor@email.com',
                        contact: '+1 (555) 567-8901',
                        lastVisit: '2025-10-11',
                        upcoming: '2025-10-20',
                        status: 'active',
                        balance: 0,
                      ),
                      _buildPatientRow(
                        avatarText: 'LG',
                        name: 'Linda Garcia',
                        id: 'P006 • 63y, Female',
                        email: 'lgarcia@email.com',
                        contact: '+1 (555) 678-9012',
                        lastVisit: '2025-08-15',
                        upcoming: '-',
                        status: 'inactive',
                        balance: 1200,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  DataRow _buildPatientRow({
    required String avatarText,
    required String name,
    required String id,
    required String email,
    required String contact,
    required String lastVisit,
    required String upcoming,
    required String status,
    required int balance,
  }) {
    return DataRow(
      cells: [
        DataCell(
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: _getAvatarColor(avatarText),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Center(
                  child: Text(
                    avatarText,
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
                    name,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  Text(
                    id,
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                  Text(
                    email,
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                ],
              ),
            ],
          ),
        ),
        DataCell(Text(contact)),
        DataCell(Text(lastVisit)),
        DataCell(Text(upcoming)),
        DataCell(
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: status == 'active' ? Colors.green[50] : Colors.grey[200],
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: status == 'active' ? Colors.green : Colors.grey,
                width: 1,
              ),
            ),
            child: Text(
              status.toUpperCase(),
              style: TextStyle(
                color: status == 'active' ? Colors.green : Colors.grey,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        DataCell(
          Text(
            balance == 0 ? '\$0' : '\$$balance',
            style: TextStyle(
              color: balance == 0 ? Colors.grey : Colors.red,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        DataCell(
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.edit_outlined, size: 20),
                onPressed: () {},
              ),
              IconButton(
                icon: const Icon(Icons.delete_outlined, size: 20),
                onPressed: () {},
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
        shadowColor: Colors.grey.withOpacity(0.2),
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
                  color: color.withOpacity(0.1),
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
