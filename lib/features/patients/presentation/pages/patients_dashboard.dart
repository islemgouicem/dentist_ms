import 'package:dentist_ms/core/constants/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class PatientsDashboard extends StatefulWidget {
  const PatientsDashboard({super.key, required this.onPatientSelected});
  final Function(Map<String, dynamic>) onPatientSelected;

  @override
  State<PatientsDashboard> createState() => _PatientsDashboardState();
}

class _PatientsDashboardState extends State<PatientsDashboard> {
  var totalPatients = 2847;
  var activePatients = 2145;
  var newPatients = 127;
  var balance = 12340;
  final List<Map<String, dynamic>> mockPatients = [
    {
      "name": "John Smith",
      "id": "MED-789456123",
      "email": "john.smith@email.com",
      "contact": "+1 (555) 123-4567",
      "lastVisit": "2025-10-08",
      "upcoming": "2025-10-15",
      "status": "active",
      "balance": 0,
    },
    {
      "name": "Emma Wilson",
      "id": "P002 • 28y, Female",
      "email": "emma.w@email.com",
      "contact": "+1 (555) 234-5678",
      "lastVisit": "2025-10-10",
      "upcoming": "2025-10-14",
      "status": "active",
      "balance": 450,
    },
    {
      "name": "Michael Brown",
      "id": "P003 • 35y, Male",
      "email": "mbrown@email.com",
      "contact": "+1 (555) 345-6789",
      "lastVisit": "2025-09-25",
      "upcoming": "-",
      "status": "active",
      "balance": 0,
    },
    {
      "name": "Sarah Davis",
      "id": "P004 • 51y, Female",
      "email": "sdavis@email.com",
      "contact": "+1 (555) 456-7890",
      "lastVisit": "2025-10-05",
      "upcoming": "2025-11-02",
      "status": "active",
      "balance": 280,
    },
    {
      "name": "James Taylor",
      "id": "P005 • 19y, Male",
      "email": "jtaylor@email.com",
      "contact": "+1 (555) 567-8901",
      "lastVisit": "2025-10-11",
      "upcoming": "2025-10-20",
      "status": "active",
      "balance": 0,
    },
    {
      "name": "Linda Garcia",
      "id": "P006 • 63y, Female",
      "email": "lgarcia@email.com",
      "contact": "+1 (555) 678-9012",
      "lastVisit": "2025-08-15",
      "upcoming": "-",
      "status": "inactive",
      "balance": 1200,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
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
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
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
                                padding: const EdgeInsets.symmetric(
                                  vertical: 12,
                                ),
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
                    "assets/icons/person.svg",
                    AppColors.cardBlue,
                  ),
                  _buildStatCard(
                    'Active Patients',
                    activePatients,
                    "assets/icons/pfp.svg",
                    AppColors.cardGreen,
                  ),
                  _buildStatCard(
                    'New This Month',
                    newPatients,
                    "assets/icons/plus.svg",
                    AppColors.cardPurple,
                  ),
                  _buildStatCard(
                    'Pending Balance',
                    balance,
                    "assets/icons/dollar.svg",
                    AppColors.cardOrange,
                    isMoney: true,
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Search and Filter Row
              IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment
                      .stretch, // This stretches the buttons vertically
                  children: [
                    // Search Field
                    Expanded(
                      child: TextField(
                        textAlignVertical: TextAlignVertical.center,
                        style: const TextStyle(fontSize: 14), // Base text size
                        decoration: InputDecoration(
                          hintText: 'Search patients by name, ID, or email...',
                          hintStyle: TextStyle(
                            color: Colors.grey[500],
                            fontSize: 14,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                          filled: true,
                          fillColor: Colors.grey[100],
                          prefixIcon: Icon(
                            Icons.search,
                            color: Colors.grey[500],
                            size: 22,
                          ),
                          // Using padding to define the natural height rather than fixed pixels
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 14,
                          ),
                          isDense: true,
                        ),
                        onChanged: (value) {
                          // TODO: Add filtering logic
                        },
                      ),
                    ),

                    const SizedBox(width: 12),

                    // Filters Button
                    ElevatedButton.icon(
                      onPressed: () {},
                      icon: const Icon(Icons.filter_alt_outlined, size: 18),
                      label: const Text("Filters"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: const Color(0xFF1A2332),
                        elevation: 0,
                        side: BorderSide.none,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        // Horizontal padding only; vertical is handled by the stretch
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                      ),
                    ),

                    const SizedBox(width: 12),

                    // Export Button
                    ElevatedButton.icon(
                      onPressed: () {},
                      icon: const Icon(Icons.arrow_upward, size: 18),
                      label: const Text("Export"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: const Color(0xFF1A2332),
                        elevation: 0,
                        side: BorderSide.none,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Patients List
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 10,
                  ),
                  child: DataTable(
                    showCheckboxColumn: false,
                    columnSpacing: 24,
                    horizontalMargin: 16,
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
                    ],
                    rows: mockPatients.map((patient) {
                      return _buildPatientRow(
                        name: patient["name"],
                        id: patient["id"],
                        email: patient["email"],
                        contact: patient["contact"],
                        lastVisit: patient["lastVisit"],
                        upcoming: patient["upcoming"],
                        status: patient["status"],
                        balance: patient["balance"],
                        onRowTap: widget.onPatientSelected,
                      );
                    }).toList(),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  DataRow _buildPatientRow({
    required String name,
    required String id,
    required String email,
    required String contact,
    required String lastVisit,
    required String upcoming,
    required String status,
    required int balance,
    required void Function(Map<String, dynamic>) onRowTap, // callback
  }) {
    return DataRow(
      onSelectChanged: (_) {
        // Trigger the callback when the row is clicked
        onRowTap({
          'name': name,
          'id': id,
          'gender': 'Female',
          'dob': 'March 15, 1990',
          'phone': '+1 (555) 123-4567',
          'email': email,
          'contact': contact,
          'lastVisit': lastVisit,
          'upcoming': upcoming,
          'status': status,
          'balance': balance,
        });
      },
      cells: [
        DataCell(
          Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment(-0.00, -0.00),
                    end: Alignment(1.00, 1.00),
                    colors: [
                      const Color(0xFF50A2FF),
                      const Color(0xFFC17AFF)
                    ],
                  ),
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Center(
                  child: Text(
                    getAvatarText(name),
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
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                  Text(
                    id,
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                ],
              ),
            ],
          ),
        ),
        DataCell(
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SvgPicture.asset(
                    "assets/icons/phone.svg",
                    color: Colors.grey[600],
                    width: 12,
                    height: 12,
                  ),
                  SizedBox(width: 4),
                  Text(contact),
                ],
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SvgPicture.asset(
                    "assets/icons/email.svg",
                    color: Colors.grey[600],
                    width: 12,
                    height: 12,
                  ),
                  SizedBox(width: 4),
                  Text(
                    email,
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                ],
              ),
            ],
          ),
        ),
        DataCell(Text(lastVisit)),
        DataCell(Text(upcoming)),
        DataCell(
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: status == 'active' ? Color(0xff00BC7D) : AppColors.primary,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(
              status.toUpperCase(),
              style: TextStyle(
                color: AppColors.white,
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
      ],
    );
  }

  String getAvatarText(String fullName) {
    final trimmed = fullName.trim();
    if (trimmed.isEmpty) return '';
    final nameParts = trimmed
        .split(' ')
        .where((part) => part.isNotEmpty)
        .toList();
    final f = nameParts.isNotEmpty ? nameParts.first[0] : '';
    final l = nameParts.length > 1 ? nameParts.last[0] : '';
    return (f + l).toUpperCase();
  }

  Widget _buildStatCard(
    String title,
    int value,
    String icon,
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
                child: SvgPicture.asset(
                  icon,
                  colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
                  width: 24,
                  height: 24,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
