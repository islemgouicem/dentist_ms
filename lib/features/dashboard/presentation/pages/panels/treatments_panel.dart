import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:dentist_ms/core/constants/app_colors.dart';
import '../dashboard_constants.dart';
import '../widgets/treatment_volume_row.dart';

class TreatmentsPanel extends StatelessWidget {
  final double screenWidth;
  final double screenHeight;
  const TreatmentsPanel({super.key, required this.screenWidth, required this.screenHeight});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          flex: 3,
          child: Container(
            decoration: BoxDecoration(
              color: kSurface,
              borderRadius: BorderRadius.circular(kRadiusCard),
              border: Border.all(color: kBorder),
            ),
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Répartition des traitements',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: kTextPrimary,
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Ventilation par type de traitement',
                  style: TextStyle(color: kTextSecondary),
                ),
                const SizedBox(height: 12),
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: Color(0xFFE7E7E7)),
                    ),
                    padding: const EdgeInsets.all(8),
                    child: PieChart(
                      PieChartData(
                        sectionsSpace: 0,
                        centerSpaceRadius: 0,
                        sections: [
                          PieChartSectionData(
                            value: 35,
                            title: 'Nettoyage dentaire 35%',
                            color: Color(0xFF3B82F6),
                            radius: 200,
                            titleStyle: TextStyle(
                              color: kTextPrimary,
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          PieChartSectionData(
                            value: 24,
                            title: 'Obturation 24%',
                            color: Color(0xFF10B981),
                            radius: 200,
                            titleStyle: TextStyle(
                              color: kTextPrimary,
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          PieChartSectionData(
                            value: 10,
                            title: 'Traitement radiculaire 10%',
                            color: Color(0xFFF59E0B),
                            radius: 200,
                            titleStyle: TextStyle(
                              color: kTextPrimary,
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          PieChartSectionData(
                            value: 7,
                            title: 'Implant dentaire 7%',
                            color: Color(0xFF6366F1),
                            radius: 200,
                            titleStyle: TextStyle(
                              color: kTextPrimary,
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          PieChartSectionData(
                            value: 16,
                            title: 'Orthodontie 16%',
                            color: Color(0xFFEC4899),
                            radius: 200,
                            titleStyle: TextStyle(
                              color: kTextPrimary,
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          PieChartSectionData(
                            value: 8,
                            title: 'Extraction 8%',
                            color: Color(0xFFEF4444),
                            radius: 200,
                            titleStyle: TextStyle(
                              color: kTextPrimary,
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 24),

        Expanded(
          flex: 2,
          child: Container(
            decoration: BoxDecoration(
              color: kSurface,
              borderRadius: BorderRadius.circular(kRadiusCard),
              border: Border.all(color: kBorder),
            ),
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Volume de traitement',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: kTextPrimary,
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Nombre de traitements effectués',
                  style: TextStyle(color: kTextSecondary),
                ),
                const SizedBox(height: 12),
                Expanded(
                  child: ListView(
                    children: const [
                      TreatmentVolumeRow(label: 'Extraction', value: 3, max: 5),
                      TreatmentVolumeRow(label: 'Orthodontie', value: 4, max: 5),
                      TreatmentVolumeRow(label: 'Implant dentaire', value: 2, max: 5),
                      TreatmentVolumeRow(label: 'Traitement radiculaire', value: 3, max: 5),
                      TreatmentVolumeRow(label: 'Obturation', value: 4, max: 5),
                      TreatmentVolumeRow(label: 'Nettoyage dentaire', value: 5, max: 5),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
