import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dentist_ms/features/patients/bloc/patient_bloc.dart';
import 'package:dentist_ms/features/patients/bloc/patient_event.dart';
import 'package:dentist_ms/features/patients/bloc/patient_state.dart';
import 'package:dentist_ms/features/patients/models/patient.dart';

// ============ COLORS (LIGHT THEME) ============
class AppColors {
  static const background = Color(0xFFF8F9FC);
  static const cardBackground = Color(0xFFFFFFFF);
  static const cardBackgroundHover = Color(0xFFF1F5F9);
  static const borderColor = Color(0xFFE2E8F0);
  static const textPrimary = Color(0xFF1E293B);
  static const textSecondary = Color(0xFF64748B);
  static const textInverse = Color(0xFFFFFFFF);
  static const accentCyan = Color(0xFF0EA5E9);
  static const accentGreen = Color(0xFF10B981);
  static const accentPurple = Color(0xFF8B5CF6);
  static const badgeFemale = Color(0xFF7C3AED);
  static const badgeAge = Color(0xFF475569);
  static const buttonBlue = Color(0xFF3B82F6);
  static const doctorBadge = Color(0xFFEFF6FF);
  static const doctorBadgeText = Color(0xFF1E40AF);
}

// ============ TEXT STYLES ============
class AppTextStyles {
  static const patientName = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimary,
    letterSpacing: -0.5,
  );
  static const sectionTitle = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
  );
  static const bodyText = TextStyle(
    fontSize: 15,
    fontWeight: FontWeight.normal,
    color: AppColors.textPrimary,
    height: 1.5,
  );
  static const bodyTextSecondary = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.normal,
    color: AppColors.textSecondary,
    height: 1.4,
  );
  static const smallText = TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w500,
    color: AppColors.textSecondary,
  );
  static const badge = TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w600,
    color: AppColors.textInverse,
  );
  static const buttonText = TextStyle(
    fontSize: 15,
    fontWeight: FontWeight.w600,
    color: AppColors.textInverse,
  );
}

// ============ CONSTANTS ============
class AppSizes {
  static const double radiusSmall = 8.0;
  static const double radiusMedium = 12.0;
  static const double radiusLarge = 16.0;
  static const double avatarSize = 110.0;
  static const double iconSizeSmall = 20.0;
  static const double iconSizeMedium = 24.0;
}

// ============ MAIN SCREEN ============
class PatientDetailScreen extends StatefulWidget {
  const PatientDetailScreen({
    super.key,
    required this.patient,
    required this.onBack,
  });

  // Expecting a Map structure similar to this for DB integration:
  // {
  //   'name': 'Sarah Mitchell',
  //   'gender': 'Female',
  //   'age': 34,
  //   'dob': 'March 15, 1990',
  //   'id': 'MED-789456123',
  //   'phone': '+1 (555) 123-4567',
  //   'email': 'sarah@email.com',
  //   'address': '...',
  //   'stats': {'visits': 12, 'lastVisit': 'Oct 28, 2024', 'dentist': 'Dr. Cooper'},
  //   'dentalHistory': [
  //      {'title': 'Checkup', 'date': '...', 'desc': '...', 'doctor': '...'},
  //   ]
  // }
  final Map<String, dynamic> patient;
  final VoidCallback onBack;

  @override
  State<PatientDetailScreen> createState() => _PatientDetailScreenState();
}

class _PatientDetailScreenState extends State<PatientDetailScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _awaitingSave = false; // to track save operation
  bool _awaitingDelete = false; // to track delete operation

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _handleQuickAction(String actionName) {
    if (actionName == 'Edit Profile') {
      _showEditProfileDialog();
      return;
    }

    if (actionName == 'Delete Patient') {
      _confirmDelete();
      return;
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.cardBackground,
        title: Text(actionName, style: AppTextStyles.sectionTitle),
        content: Text(
          "Functionality for '$actionName' would open here.",
          style: AppTextStyles.bodyTextSecondary,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Close"),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text("$actionName action executed!")),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.buttonBlue,
              foregroundColor: Colors.white,
            ),
            child: const Text("Proceed"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Extracting variables from the passed Map for cleaner usage below
    // Use '??' to provide fallbacks if DB returns null
    final String name = widget.patient['name'] ?? 'Unknown Patient';
    final String gender = widget.patient['gender'] ?? 'N/A';
    final String age = widget.patient['age']?.toString() ?? '0';
    final String dob = widget.patient['dob'] ?? 'N/A';
    final String patientId = widget.patient['id']?.toString() ?? 'N/A';

    final Map<String, dynamic> stats = widget.patient['stats'] ?? {};
    final String totalVisits = stats['visits']?.toString() ?? '0';
    final String lastVisit = stats['lastVisit'] ?? 'Never';
    final String primaryDentist = stats['dentist'] ?? 'Unassigned';

    final String phone = widget.patient['phone'] ?? 'No phone';
    final String email = widget.patient['email'] ?? 'No email';
    final String address = widget.patient['address'] ?? 'No address';

    // List of history records
    final List<dynamic> dentalHistory = widget.patient['dentalHistory'] ?? [];

    return BlocListener<PatientBloc, PatientState>(
      listener: (context, state) {
        if (state is PatientsLoadSuccess && _awaitingSave) {
          setState(() => _awaitingSave = false);
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('Profile saved')));
        } else if (state is PatientsOperationFailure && _awaitingSave) {
          setState(() => _awaitingSave = false);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Save failed: ${state.message}')),
          );

        }

        if (state is PatientsLoadSuccess && _awaitingDelete) {
          setState(() => _awaitingDelete = false);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Patient deleted')),
          );
        } else if (state is PatientsOperationFailure && _awaitingDelete) {
          setState(() => _awaitingDelete = false);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Delete failed: ${state.message}')),
          );
        }
      },
      child: Scaffold(
        body: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              double horizontalPadding = constraints.maxWidth < 1366
                  ? 24
                  : (constraints.maxWidth < 1920 ? 32 : 48);
              double verticalPadding = constraints.maxWidth < 1366 ? 24 : 32;

              return SingleChildScrollView(
                padding: EdgeInsets.symmetric(
                  horizontal: horizontalPadding,
                  vertical: verticalPadding,
                ),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 1600),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildHeader(name, gender, age, dob, patientId),
                        SizedBox(height: constraints.maxWidth < 1366 ? 24 : 32),
                        _buildStatsCards(
                          totalVisits,
                          lastVisit,
                          primaryDentist,
                          constraints,
                        ),
                        SizedBox(height: constraints.maxWidth < 1366 ? 24 : 32),
                        _buildMainContent(
                          phone,
                          email,
                          address,
                          dentalHistory,
                          constraints,
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(
    String name,
    String gender,
    String age,
    String dob,
    String id,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: AppSizes.avatarSize,
          height: AppSizes.avatarSize,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.accentPurple,
            border: Border.all(color: Colors.white, width: 4),
            boxShadow: [
              BoxShadow(
                color: AppColors.accentPurple.withOpacity(0.3),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: const Icon(Icons.person, size: 50, color: Colors.white),
        ),
        const SizedBox(width: 24),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(name, style: AppTextStyles.patientName),
                  const SizedBox(width: 12),
                  _buildBadge(gender, AppColors.accentCyan),
                  const SizedBox(width: 8),
                  _buildBadge('$age years', AppColors.accentPurple),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  SvgPicture.asset(
                    "assets/icons/appointments.svg",
                    width: 16,
                    height: 16,
                    color: AppColors.textSecondary,
                  ),
                  const SizedBox(width: 8),
                  Text('DOB: $dob', style: AppTextStyles.bodyTextSecondary),
                  const SizedBox(width: 16),
                  Text("|", style: AppTextStyles.bodyTextSecondary),
                  const SizedBox(width: 16),
                  SvgPicture.asset(
                    "assets/icons/file.svg",
                    width: 16,
                    height: 16,
                    color: AppColors.textSecondary,
                  ),
                  const SizedBox(width: 8),
                  Text('ID: $id', style: AppTextStyles.bodyTextSecondary),
                ],
              ),
            ],
          ),
        ),
        _buildBackButton(widget.onBack),
      ],
    );
  }

  Widget _buildBadge(String text, Color bgColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: ShapeDecoration(
        color: bgColor.withValues(alpha: 0.2),
        shape: RoundedRectangleBorder(
          side: BorderSide(width: 1, color: bgColor),
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      child: Text(text, style: TextStyle(color: bgColor)),
    );
  }

  Widget _buildBackButton(VoidCallback onBack) {
    return Material(
      color: AppColors.cardBackground,
      borderRadius: BorderRadius.circular(24),
      child: InkWell(
        onTap: onBack,
        borderRadius: BorderRadius.circular(24),
        hoverColor: AppColors.cardBackgroundHover,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: AppColors.borderColor),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: const [
              Icon(Icons.arrow_back, size: 18, color: AppColors.textPrimary),
              SizedBox(width: 8),
              Text(
                'Back to Patients',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatsCards(
    String visits,
    String lastVisit,
    String dentist,
    BoxConstraints constraints,
  ) {
    bool isCompact = constraints.maxWidth < 1366;
    double spacing = isCompact ? 16 : 24;
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            'Total Visits',
            visits,
            "assets/icons/calendar.svg",
            LinearGradient(
              begin: Alignment(-0.00, 0.00),
              end: Alignment(1.00, 1.00),
              colors: [const Color(0xFF2B7FFF), const Color(0xFF00B8DA)],
            ),
          ),
        ),
        SizedBox(width: spacing),
        Expanded(
          child: _buildStatCard(
            'Last Visit',
            lastVisit,
            "assets/icons/watch.svg",
            LinearGradient(
              begin: Alignment(-0.00, 0.00),
              end: Alignment(1.00, 1.00),
              colors: [const Color(0xFF00BC7C), const Color(0xFF00BBA6)],
            ),
          ),
        ),
        SizedBox(width: spacing),
        Expanded(
          child: _buildStatCard(
            'Primary Dentist',
            dentist,
            "assets/icons/doctor.svg",
            LinearGradient(
              begin: Alignment(-0.00, 0.00),
              end: Alignment(1.00, 1.00),
              colors: [const Color(0xFF8D51FF), const Color(0xFFAC46FF)],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(
    String label,
    String value,
    String icon,
    LinearGradient bgcolor,
  ) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(AppSizes.radiusLarge),
        border: Border.all(color: AppColors.borderColor),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 15,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: AppTextStyles.bodyTextSecondary),
              Text(
                value,
                style: AppTextStyles.bodyText.copyWith(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              gradient: bgcolor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: SvgPicture.asset(
              icon,
              width: AppSizes.iconSizeMedium,
              height: AppSizes.iconSizeMedium,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMainContent(
    String phone,
    String email,
    String address,
    List<dynamic> history,
    BoxConstraints constraints,
  ) {
    bool isCompact = constraints.maxWidth < 1366;
    double spacing = isCompact ? 20 : 24;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: constraints.maxWidth < 1366
              ? constraints.maxWidth * 0.32
              : constraints.maxWidth * 0.35,
          child: Column(
            children: [
              _buildContactInformation(phone, email, address),
              SizedBox(height: spacing),
              _buildQuickActions(),
            ],
          ),
        ),
        SizedBox(width: spacing),
        Expanded(child: _buildMedicalRecords(history)),
      ],
    );
  }

  Widget _buildContactInformation(String phone, String email, String address) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(AppSizes.radiusLarge),
        border: Border.all(color: AppColors.borderColor),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 15,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              SvgPicture.asset(
                "assets/icons/person.svg",
                width: AppSizes.iconSizeMedium,
                height: AppSizes.iconSizeMedium,
                color: AppColors.accentCyan,
              ),
              SizedBox(width: 8),
              Text(
                'Contact Information',
                style: AppTextStyles.sectionTitle.copyWith(
                  fontWeight: FontWeight.normal,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _buildContactItem(
            "assets/icons/phone.svg",
            'Phone',
            phone,
            AppColors.accentCyan,
          ),
          const SizedBox(height: 12),
          _buildContactItem(
            "assets/icons/email.svg",
            'Email',
            email,
            AppColors.accentPurple,
          ),
          const SizedBox(height: 12),
          _buildContactItem(
            "assets/icons/location.svg",
            'Address',
            address,
            AppColors.accentGreen,
          ),
        ],
      ),
    );
  }

  Widget _buildContactItem(
    String icon,
    String label,
    String value,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
        border: Border.all(color: AppColors.borderColor),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SvgPicture.asset(
            icon,
            width: AppSizes.iconSizeSmall,
            height: AppSizes.iconSizeSmall,
            color: color,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: AppTextStyles.smallText),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: AppTextStyles.bodyText.copyWith(fontSize: 14),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.white, AppColors.accentPurple.withOpacity(0.05)],
        ),
        borderRadius: BorderRadius.circular(AppSizes.radiusLarge),
        border: Border.all(color: AppColors.accentPurple.withOpacity(0.2)),
        boxShadow: [
          BoxShadow(
            color: AppColors.accentPurple.withOpacity(0.05),
            blurRadius: 15,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              Icon(
                Icons.flash_on,
                size: AppSizes.iconSizeMedium,
                color: AppColors.textPrimary,
              ),
              SizedBox(width: 8),
              Text('Quick Actions', style: AppTextStyles.sectionTitle),
            ],
          ),
          const SizedBox(height: 16),
          _buildActionButton(
            'Add Appointment',
            Icons.calendar_month,
            true,
            () => _handleQuickAction('Add Appointment'),
          ),
          const SizedBox(height: 10),
          _buildActionButton(
            'Add Medical Record',
            Icons.note_add,
            false,
            () => _handleQuickAction('Add Medical Record'),
          ),
          const SizedBox(height: 10),
          _buildActionButton(
            'Edit Profile',
            Icons.edit_outlined,
            false,
            () => _handleQuickAction('Edit Profile'),
          ),
          const SizedBox(height: 10),
          _buildActionButton(
            'Delete Patient',
            Icons.delete_forever,
            false,
            () => _handleQuickAction('Delete Patient'),
          ),
        ],
      ),
    );
  }

  void _confirmDelete() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.cardBackground,
        title: const Text('Delete Patient', style: AppTextStyles.sectionTitle),
        content: const Text('Are you sure you want to delete this patient? This action cannot be undone.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              Navigator.pop(context);

              // Validate numeric id
              final idValue = widget.patient['id'];
              int? idInt;
              if (idValue == null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Cannot delete: patient has no id')),
                );
                return;
              }
              if (idValue is int) idInt = idValue;
              else idInt = int.tryParse(idValue.toString());

              if (idInt == null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Cannot delete: invalid patient id')),
                );
                return;
              }

              setState(() => _awaitingDelete = true);
              context.read<PatientBloc>().add(DeletePatient(idInt));

              // navigate back to list immediately; BlocListener will show result
              widget.onBack();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Deleting patient...')),
              );
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _showEditProfileDialog() {
    final _formKey = GlobalKey<FormState>();
    final nameController = TextEditingController(
      text: widget.patient['name'] ?? '',
    );
    final phoneController = TextEditingController(
      text: widget.patient['phone'] ?? '',
    );
    final emailController = TextEditingController(
      text: widget.patient['email'] ?? '',
    );
    final addressController = TextEditingController(
      text: widget.patient['address'] ?? '',
    );
    final List<String> _genders = ['Female', 'Male', 'Other'];
    final rawGender = (widget.patient['gender'] ?? '').toString();
    String genderValue = _genders.firstWhere(
      (g) => g.toLowerCase() == rawGender.toLowerCase(),
      orElse: () => _genders.first,
    );
    final dobController = TextEditingController(
      text: widget.patient['dob'] ?? '',
    );

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) => AlertDialog(
            backgroundColor: AppColors.cardBackground,
            title: const Text(
              'Edit Profile',
              style: AppTextStyles.sectionTitle,
            ),
            content: SizedBox(
              width: 560,
              child: SingleChildScrollView(
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextFormField(
                        controller: nameController,
                        decoration: const InputDecoration(
                          labelText: 'Full name',
                        ),
                        validator: (v) {
                          if (v == null || v.trim().isEmpty)
                            return 'Name is required';
                          return null;
                        },
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: DropdownButtonFormField<String>(
                              value: genderValue,
                              decoration: const InputDecoration(
                                labelText: 'Gender',
                              ),
                              items: const [
                                DropdownMenuItem(
                                  value: 'Female',
                                  child: Text('Female'),
                                ),
                                DropdownMenuItem(
                                  value: 'Male',
                                  child: Text('Male'),
                                ),
                              ],
                              onChanged: (v) {
                                if (v != null) setState(() => genderValue = v);
                              },
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: TextFormField(
                              controller: dobController,
                              decoration: InputDecoration(
                                labelText: 'Date of Birth (YYYY-MM-DD)',
                                hintText: 'YYYY-MM-DD or pick from calendar',
                                suffixIcon: IconButton(
                                  icon: const Icon(Icons.calendar_today),
                                  onPressed: () async {
                                    final today = DateTime.now();
                                    final initial =
                                        DateTime.tryParse(dobController.text) ??
                                        DateTime(today.year - 25);
                                    final picked = await showDatePicker(
                                      context: context,
                                      initialDate: initial,
                                      firstDate: DateTime(1900),
                                      lastDate: today,
                                    );
                                    if (picked != null) {
                                      dobController.text = picked
                                          .toIso8601String()
                                          .split('T')
                                          .first;
                                      setState(() {});
                                    }
                                  },
                                ),
                              ),
                              validator: (value) {
                                if (value == null || value.trim().isEmpty)
                                  return 'Date of Birth is required';
                                final v = value.trim();
                                final ok =
                                    RegExp(
                                      r'^\d{4}-\d{2}-\d{2}$',
                                    ).hasMatch(v) &&
                                    DateTime.tryParse(v) != null;
                                if (!ok)
                                  return 'Enter a valid date as YYYY-MM-DD';
                                return null;
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: phoneController,
                        decoration: const InputDecoration(labelText: 'Phone'),
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: emailController,
                        decoration: const InputDecoration(labelText: 'Email'),
                        validator: (v) {
                          if (v == null || v.trim().isEmpty) return null;
                          final emailRegex = RegExp(
                            r'^[^@\s]+@[^@\s]+\.[^@\s]+$',
                          );
                          if (!emailRegex.hasMatch(v.trim()))
                            return 'Enter a valid email';
                          return null;
                        },
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: addressController,
                        decoration: const InputDecoration(labelText: 'Address'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState?.validate() ?? false) {
                    final name = nameController.text.trim();
                    final dobText = dobController.text.trim();
                    DateTime? parsedDob;
                    if (dobText.isNotEmpty &&
                        DateTime.tryParse(dobText) != null) {
                      parsedDob = DateTime.tryParse(dobText)!;
                    }

                    // Update in-memory map for immediate UI feedback
                    widget.patient['name'] = name;
                    widget.patient['gender'] = genderValue;
                    widget.patient['phone'] = phoneController.text.trim();
                    widget.patient['email'] = emailController.text.trim();
                    widget.patient['address'] = addressController.text.trim();
                    if (parsedDob != null) {
                      widget.patient['dob'] = parsedDob
                          .toIso8601String()
                          .split('T')
                          .first;
                      final today = DateTime.now();
                      int age = today.year - parsedDob.year;
                      if (today.month < parsedDob.month ||
                          (today.month == parsedDob.month &&
                              today.day < parsedDob.day))
                        age--;
                      widget.patient['age'] = age;
                    }

                    setState(() {});

                    // Build Patient model and dispatch UpdatePatient to persist to Supabase
                    final idValue = widget.patient['id'];
                    int? idInt;
                    if (idValue != null) {
                      if (idValue is int)
                        idInt = idValue;
                      else
                        idInt = int.tryParse(idValue.toString());
                    }

                    final parts = name.split(RegExp('\\s+'));
                    final firstName = parts.isNotEmpty ? parts.first : '';
                    final lastName = parts.length > 1
                        ? parts.sublist(1).join(' ')
                        : '';

                    final updatedPatient = Patient(
                      id: idInt,
                      firstName: firstName,
                      lastName: lastName,
                      gender: genderValue,
                      dateOfBirth: parsedDob,
                      phone1: phoneController.text.trim(),
                      email: emailController.text.trim(),
                      address: addressController.text.trim(),
                      status: widget.patient['status']?.toString() ?? 'active',
                    );

                    // Dispatch and let PatientBloc handle persistence and reload
                    setState(() => _awaitingSave = true);
                    context.read<PatientBloc>().add(
                      UpdatePatient(updatedPatient),
                    );

                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Saving profile...')),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.buttonBlue,
                ),
                child: const Text('Save'),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildActionButton(
    String text,
    IconData icon,
    bool isPrimary,
    VoidCallback onTap,
  ) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: isPrimary ? AppColors.buttonBlue : Colors.white,
            borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
            border: isPrimary ? null : Border.all(color: AppColors.borderColor),
            boxShadow: isPrimary
                ? [
                    BoxShadow(
                      color: AppColors.buttonBlue.withOpacity(0.25),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : null,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 18,
                color: isPrimary
                    ? AppColors.textInverse
                    : AppColors.textPrimary,
              ),
              const SizedBox(width: 8),
              Text(
                text,
                style: AppTextStyles.buttonText.copyWith(
                  fontSize: 14,
                  color: isPrimary
                      ? AppColors.textInverse
                      : AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMedicalRecords(List<dynamic> history) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(AppSizes.radiusLarge),
        border: Border.all(color: AppColors.borderColor),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 15,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              Icon(
                Icons.description_outlined,
                size: AppSizes.iconSizeMedium,
                color: AppColors.textPrimary,
              ),
              SizedBox(width: 8),
              Text('Medical Records', style: AppTextStyles.sectionTitle),
            ],
          ),
          const SizedBox(height: 20),

          Container(
            height: 45,
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
            ),
            child: TabBar(
              controller: _tabController,
              indicatorSize: TabBarIndicatorSize.tab,
              dividerColor: Colors.transparent,
              indicator: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  colors: [Color(0xFF2B7FFF), Color(0xFF00B8DB)],
                ),
                borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              labelColor: Colors.white,
              unselectedLabelColor: AppColors.textSecondary,
              labelStyle: AppTextStyles.bodyText.copyWith(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
              unselectedLabelStyle: AppTextStyles.bodyText.copyWith(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
              tabs: const [
                Tab(text: 'Dental History'),
                Tab(text: 'Prescriptions'),
                Tab(text: 'Allergies'),
                Tab(text: 'Upcoming'),
              ],
            ),
          ),

          const SizedBox(height: 24),

          SizedBox(
            height: 400,
            child: TabBarView(
              controller: _tabController,
              physics: const BouncingScrollPhysics(),
              children: [
                DentalHistoryTab(records: history),
                const PrescriptionsTab(),
                const AllergiesTab(),
                const UpcomingTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ============ TAB CONTENT (MODULAR) ============

class DentalHistoryTab extends StatelessWidget {
  final List<dynamic> records;
  const DentalHistoryTab({super.key, required this.records});

  @override
  Widget build(BuildContext context) {
    if (records.isEmpty) {
      return const Center(
        child: Text("No records found", style: AppTextStyles.bodyTextSecondary),
      );
    }

    // Using ListView.separated for modular data rendering
    return ListView.separated(
      itemCount: records.length,
      separatorBuilder: (context, index) => const SizedBox(height: 16),
      itemBuilder: (context, index) {
        final record = records[index];
        return _buildRecordCard(
          record['title'] ?? 'Unknown Procedure',
          record['date'] ?? 'N/A',
          record['desc'] ?? 'No description provided',
          record['doctor'] ?? 'Unknown Doctor',
        );
      },
    );
  }

  Widget _buildRecordCard(
    String title,
    String date,
    String description,
    String doctor,
  ) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
        border: Border.all(color: AppColors.borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  title,
                  style: AppTextStyles.bodyText.copyWith(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: AppColors.doctorBadge,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  doctor,
                  style: AppTextStyles.badge.copyWith(
                    fontSize: 12,
                    color: AppColors.doctorBadgeText,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(date, style: AppTextStyles.smallText),
          const SizedBox(height: 12),
          Text(description, style: AppTextStyles.bodyTextSecondary),
        ],
      ),
    );
  }
}

class PrescriptionsTab extends StatelessWidget {
  const PrescriptionsTab({super.key});
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
        border: Border.all(
          color: AppColors.borderColor,
          style: BorderStyle.solid,
        ),
      ),
      child: const Center(
        child: Text(
          "Prescriptions Content Goes Here",
          style: AppTextStyles.bodyTextSecondary,
        ),
      ),
    );
  }
}

class AllergiesTab extends StatelessWidget {
  const AllergiesTab({super.key});
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
        border: Border.all(
          color: AppColors.borderColor,
          style: BorderStyle.solid,
        ),
      ),
      child: const Center(
        child: Text(
          "Allergies Content Goes Here",
          style: AppTextStyles.bodyTextSecondary,
        ),
      ),
    );
  }
}

class UpcomingTab extends StatelessWidget {
  const UpcomingTab({super.key});
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
        border: Border.all(
          color: AppColors.borderColor,
          style: BorderStyle.solid,
        ),
      ),
      child: const Center(
        child: Text(
          "Upcoming Appointments Content Goes Here",
          style: AppTextStyles.bodyTextSecondary,
        ),
      ),
    );
  }
}
