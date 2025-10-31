import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/appointment_model.dart';
import '../services/appointment_service.dart';
import '../utils/appointment_utils.dart';

class TotalAppointmentsDialog extends StatefulWidget {
  final AppointmentService service;

  const TotalAppointmentsDialog({
    super.key,
    required this.service,
  });

  @override
  State<TotalAppointmentsDialog> createState() => _TotalAppointmentsDialogState();
}

class _TotalAppointmentsDialogState extends State<TotalAppointmentsDialog> {
  late List<AppointmentWithStatus> allAppointments;
  String searchQuery = '';
  String sortBy = 'Plus récent';
  int currentPage = 1;
  final int itemsPerPage = 10;

  @override
  void initState() {
    super.initState();
    _initializeAppointments();
  }

  void _initializeAppointments() {
    allAppointments = widget.service.getAllAppointments().map((app) {
      return AppointmentWithStatus(
        appointment: app,
        status: _getAppointmentStatus(app),
      );
    }).toList();
    _sortAppointments();
  }

  void _sortAppointments() {
    if (sortBy == 'Plus récent') {
      allAppointments.sort((a, b) => b.appointment.appointmentDate.compareTo(a.appointment.appointmentDate));
    } else if (sortBy == 'Plus ancien') {
      allAppointments.sort((a, b) => a.appointment.appointmentDate.compareTo(b.appointment.appointmentDate));
    }
  }

  String _getAppointmentStatus(Appointment app) {
    final now = DateTime(2025, 10, 31, 16, 10, 22);
    final appointmentTime = AppointmentUtils.getAppointmentDateTime(app);
    final endTime = appointmentTime.add(Duration(minutes: app.duration));

    if (endTime.isBefore(now)) {
      return 'Terminé';
    } else if (appointmentTime.isBefore(now) && endTime.isAfter(now)) {
      return 'En cours';
    } else {
      return 'À venir';
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Terminé':
        return const Color(0xFF10B981);
      case 'En cours':
        return const Color(0xFF3B82F6);
      case 'À venir':
        return const Color(0xFF8B5CF6);
      default:
        return const Color(0xFF6B7280);
    }
  }

  List<AppointmentWithStatus> _getFilteredAppointments() {
    return allAppointments.where((item) {
      return item.appointment.patientName.toLowerCase().contains(searchQuery.toLowerCase()) ||
          item.appointment.id.toLowerCase().contains(searchQuery.toLowerCase());
    }).toList();
  }

  int _getTotalPages() {
    final filtered = _getFilteredAppointments();
    return (filtered.length / itemsPerPage).ceil();
  }

  List<AppointmentWithStatus> _getPaginatedAppointments() {
    final filtered = _getFilteredAppointments();
    final startIndex = (currentPage - 1) * itemsPerPage;
    final endIndex = startIndex + itemsPerPage;
    return filtered.sublist(
      startIndex,
      endIndex > filtered.length ? filtered.length : endIndex,
    );
  }

  @override
  Widget build(BuildContext context) {
    final totalCount = allAppointments.length;
    final upcoming = allAppointments.where((a) => a.status == 'À venir').length;
    final inProgress = allAppointments.where((a) => a.status == 'En cours').length;
    final completed = allAppointments.where((a) => a.status == 'Terminé').length;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      backgroundColor: Colors.white,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 1800, maxHeight: 950),
        child: Column(
          children: [
            // En-tête - COMPACT
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              decoration: BoxDecoration(
                border: Border(bottom: BorderSide(color: Colors.grey[200]!)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Text(
                        'Total des rendez-vous',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF111827),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFF6B6B),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Text(
                          '$totalCount',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, size: 20),
                    onPressed: () => Navigator.pop(context),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
            ),
            // Pastilles de statut et barre de recherche sur la même ligne
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Row(
                children: [
                  // Pastilles de statut
                  Row(
                    children: [
                      _buildStatusPill('À venir', upcoming, const Color(0xFF8B5CF6)),
                      const SizedBox(width: 12),
                      _buildStatusPill('En cours', inProgress, const Color(0xFF3B82F6)),
                      const SizedBox(width: 12),
                      _buildStatusPill('Terminé', completed, const Color(0xFF10B981)),
                    ],
                  ),
                  const SizedBox(width: 20),
                  // Barre de recherche - PLUS GRANDE
                  Expanded(
                    child: Container(
                      height: 44,
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey[300]!),
                        borderRadius: BorderRadius.circular(8),
                        color: Colors.grey[50],
                      ),
                      child: TextField(
                        onChanged: (value) {
                          setState(() {
                            searchQuery = value;
                            currentPage = 1;
                          });
                        },
                        decoration: InputDecoration(
                          hintText: 'Rechercher par nom du patient ou ID',
                          border: InputBorder.none,
                          hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
                          prefixIcon: Icon(Icons.search, color: Colors.grey[400], size: 20),
                          isDense: true,
                          contentPadding: EdgeInsets.zero,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Bouton de tri
                  Container(
                    height: 44,
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey[300]!),
                      borderRadius: BorderRadius.circular(8),
                      color: Colors.grey[50],
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.sort, color: Colors.grey[600], size: 20),
                        const SizedBox(width: 8),
                        const Text(
                          'Tri:',
                          style: TextStyle(fontSize: 13, color: Color(0xFF6B7280)),
                        ),
                        const SizedBox(width: 4),
                        DropdownButton<String>(
                          value: sortBy,
                          underline: const SizedBox(),
                          style: const TextStyle(color: Color(0xFF111827), fontSize: 13, fontWeight: FontWeight.w600),
                          items: ['Plus récent', 'Plus ancien'].map((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(value),
                            );
                          }).toList(),
                          onChanged: (String? value) {
                            if (value != null) {
                              setState(() {
                                sortBy = value;
                                _sortAppointments();
                              });
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Divider(color: Colors.grey[200], height: 1),
            // Tableau - PLEIN ESPACE
            Expanded(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: SingleChildScrollView(
                  child: _buildTable(),
                ),
              ),
            ),
            Divider(color: Colors.grey[200], height: 1),
            // Pagination - COMPACT
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Text(
                        'Affichage',
                        style: TextStyle(fontSize: 12, color: Color(0xFF6B7280)),
                      ),
                      const SizedBox(width: 6),
                      Container(
                        height: 32,
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey[300]!),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: DropdownButton<int>(
                          value: itemsPerPage,
                          underline: const SizedBox(),
                          style: const TextStyle(color: Color(0xFF111827), fontSize: 12, fontWeight: FontWeight.w600),
                          items: [5, 10, 20, 50].map((int value) {
                            return DropdownMenuItem<int>(
                              value: value,
                              child: Text('$value'),
                            );
                          }).toList(),
                          onChanged: (int? value) {},
                        ),
                      ),
                      const SizedBox(width: 6),
                      const Text(
                        'résultats',
                        style: TextStyle(fontSize: 12, color: Color(0xFF6B7280)),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      GestureDetector(
                        onTap: currentPage > 1 ? () => setState(() => currentPage--) : null,
                        child: Container(
                          height: 32,
                          width: 32,
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey[300]!),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Icon(
                            Icons.chevron_left,
                            color: currentPage > 1 ? Colors.grey[700] : Colors.grey[300],
                            size: 16,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      for (int i = 1; i <= _getTotalPages(); i++) ...[
                        GestureDetector(
                          onTap: () => setState(() => currentPage = i),
                          child: Container(
                            height: 32,
                            width: 32,
                            decoration: BoxDecoration(
                              color: currentPage == i ? const Color(0xFF3B82F6) : Colors.transparent,
                              border: Border.all(
                                color: currentPage == i ? const Color(0xFF3B82F6) : Colors.grey[300]!,
                              ),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Center(
                              child: Text(
                                '$i',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: currentPage == i ? Colors.white : const Color(0xFF6B7280),
                                ),
                              ),
                            ),
                          ),
                        ),
                        if (i < _getTotalPages()) const SizedBox(width: 4),
                      ],
                      const SizedBox(width: 8),
                      GestureDetector(
                        onTap: currentPage < _getTotalPages() ? () => setState(() => currentPage++) : null,
                        child: Container(
                          height: 32,
                          width: 32,
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey[300]!),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Icon(
                            Icons.chevron_right,
                            color: currentPage < _getTotalPages() ? Colors.grey[700] : Colors.grey[300],
                            size: 16,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusPill(String label, int count, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
          const SizedBox(width: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              '$count',
              style: const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTable() {
    final paginatedAppointments = _getPaginatedAppointments();

    return Table(
      columnWidths: const {
        0: FixedColumnWidth(50),
        1: FixedColumnWidth(140),
        2: FixedColumnWidth(220),
        3: FixedColumnWidth(420),
        4: FixedColumnWidth(150),
        5: FixedColumnWidth(70),
      },
      defaultVerticalAlignment: TableCellVerticalAlignment.middle,
      children: [
        // En-tête
        TableRow(
          decoration: BoxDecoration(color: Colors.grey[100]),
          children: [
            _buildTableHeader(''),
            _buildTableHeader('ID Patient'),
            _buildTableHeader('Nom du patient'),
            _buildTableHeader('Date du rendez-vous'),
            _buildTableHeader('Statut'),
            _buildTableHeader(''),
          ],
        ),
        // Lignes
        ...paginatedAppointments.asMap().entries.map((entry) {
          final item = entry.value;
          final app = item.appointment;
          final status = item.status;
          final appointmentTime = AppointmentUtils.getAppointmentDateTime(app);
          final endTime = appointmentTime.add(Duration(minutes: app.duration));
          final dateTimeString =
              '${DateFormat('dd MMM yyyy, hh:mm a').format(appointmentTime)} à ${DateFormat('hh:mm a').format(endTime)}';

          return TableRow(
            decoration: BoxDecoration(
              border: Border(bottom: BorderSide(color: Colors.grey[200]!)),
              color: entry.key.isEven ? Colors.grey[50] : Colors.white,
            ),
            children: [
              _buildTableCell(
                Checkbox(
                  value: false,
                  onChanged: (value) {},
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
              ),
              _buildTableCell(
                Text(
                  '#PT${app.id.padLeft(4, '0')}',
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF6B7280)),
                ),
              ),
              _buildTableCell(
                Row(
                  children: [
                    CircleAvatar(
                      radius: 16,
                      backgroundColor: _getStatusColor(status),
                      child: Text(
                        app.patientName[0].toUpperCase(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        app.patientName,
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF111827)),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              _buildTableCell(
                Text(
                  dateTimeString,
                  style: const TextStyle(fontSize: 11, color: Color(0xFF6B7280)),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              _buildTableCell(
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: _getStatusColor(status).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    status,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: _getStatusColor(status),
                    ),
                  ),
                ),
              ),
              _buildTableCell(
                Center(
                  child: PopupMenuButton(
                    itemBuilder: (BuildContext context) {
                      return [
                        const PopupMenuItem(child: Text('Modifier')),
                        const PopupMenuItem(child: Text('Supprimer')),
                      ];
                    },
                    child: Icon(Icons.more_vert, color: Colors.grey[400], size: 16),
                  ),
                ),
              ),
            ],
          );
        }).toList(),
      ],
    );
  }

  Widget _buildTableHeader(String text) {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: Color(0xFF111827),
        ),
      ),
    );
  }

  Widget _buildTableCell(Widget content) {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: content,
    );
  }
}

class AppointmentWithStatus {
  final Appointment appointment;
  final String status;

  AppointmentWithStatus({
    required this.appointment,
    required this.status,
  });
}