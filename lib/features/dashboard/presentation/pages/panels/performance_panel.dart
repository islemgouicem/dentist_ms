import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:dentist_ms/core/constants/app_colors.dart';
import '../dashboard_constants.dart';
import '../widgets/performance_stat_row.dart';

class PerformancePanel extends StatelessWidget {
  final double screenWidth;
  final double screenHeight;
  const PerformancePanel({super.key, required this.screenWidth, required this.screenHeight});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
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
              children: const [
                Text(
                  'Résumé des performances',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: kTextPrimary,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Ventilation détaillée des métriques',
                  style: TextStyle(color: kTextSecondary),
                ),
                SizedBox(height: 24),

                PerformanceStatRow(
                  label: 'Satisfaction des patients',
                  value: 0.95,
                  percentLabel: '95%',
                  color: Color(0xFF16A34A),
                ),
                SizedBox(height: 18),

                PerformanceStatRow(
                  label: 'Succès du traitement',
                  value: 0.88,
                  percentLabel: '88%',
                  color: Color(0xFF2563EB),
                ),
                SizedBox(height: 18),

                PerformanceStatRow(
                  label: 'Rendez-vous ponctuels',
                  value: 0.92,
                  percentLabel: '92%',
                  color: Color(0xFF16A34A),
                ),
                SizedBox(height: 18),

                PerformanceStatRow(
                  label: 'Taux de suivi',
                  value: 0.78,
                  percentLabel: '78%',
                  color: Color(0xFFF59E0B),
                ),
                SizedBox(height: 18),

                PerformanceStatRow(
                  label: 'Croissance des revenus',
                  value: 0.85,
                  percentLabel: '85%',
                  color: Color(0xFF2563EB),
                ),
              ],
            ),
          ),
        ),

        const SizedBox(width: 24),

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
                  'Index de performance global',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: kTextPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Score composite basé sur les métriques clés',
                  style: TextStyle(color: kTextSecondary),
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: Color(0xFFE7E7E7)),
                    ),
                    padding: const EdgeInsets.fromLTRB(10, 10, 18, 18),
                    child: LineChart(_performanceChartData()),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  LineChartData _performanceChartData() {
    final months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
    ];
    final values = [78, 82, 80, 85, 86, 88, 90, 89, 91, 92];

    return LineChartData(
      minX: 0,
      maxX: 9,
      minY: 70,
      maxY: 100,
      gridData: FlGridData(
        show: true,
        getDrawingHorizontalLine: (_) => const FlLine(color: Color(0xFFE8EDF4), strokeWidth: 1),
        getDrawingVerticalLine: (_) => const FlLine(color: Color(0xFFE8EDF4), strokeWidth: 1),
        drawVerticalLine: true,
      ),
      titlesData: FlTitlesData(
        topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 40,
            interval: 5,
            getTitlesWidget: (v, _) => Text(
              v.toInt().toString(),
              style: const TextStyle(fontSize: 12, color: kTextSecondary),
            ),
          ),
        ),
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            interval: 1,
            getTitlesWidget: (v, _) => Padding(
              padding: const EdgeInsets.only(top: 6),
              child: Text(
                months[v.toInt()],
                style: const TextStyle(fontSize: 12, color: kTextSecondary),
              ),
            ),
          ),
        ),
      ),
      borderData: FlBorderData(
        show: true,
        border: const Border(
          top: BorderSide(color: Color(0xFFE0E6EE)),
          left: BorderSide(color: Color(0xFFE0E6EE)),
          right: BorderSide(color: Color(0xFFE0E6EE)),
          bottom: BorderSide(color: Color(0xFFE0E6EE)),
        ),
      ),
      lineBarsData: [
        LineChartBarData(
          isCurved: true,
          color: const Color(0xFF2563EB),
          barWidth: 3,
          dotData: const FlDotData(show: true),
          belowBarData: BarAreaData(
            show: true,
            color: const Color(0xFF2563EB).withOpacity(0.12),
          ),
          spots: List.generate(values.length, (i) => FlSpot(i.toDouble(), values[i].toDouble())),
        ),
      ],
      lineTouchData: LineTouchData(
        touchTooltipData: LineTouchTooltipData(
          getTooltipColor: (_) => Colors.white,
          tooltipRoundedRadius: 8,
          getTooltipItems: (items) => items.map((s) => LineTooltipItem('${values[s.x.toInt()]}%', const TextStyle(color: kTextPrimary, fontWeight: FontWeight.w700))).toList(),
        ),
      ),
    );
  }
}
