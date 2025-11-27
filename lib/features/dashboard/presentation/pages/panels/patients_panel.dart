import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:dentist_ms/core/constants/app_colors.dart';
import '../dashboard_constants.dart';

class PatientsPanel extends StatelessWidget {
  final double screenWidth;
  final double screenHeight;
  const PatientsPanel({super.key, required this.screenWidth, required this.screenHeight});

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
                  'Croissance des patients',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: kTextPrimary,
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Acquisition mensuelle de patients',
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
                    child: LineChart(_patientsChartData()),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 24),
      ],
    );
  }

  LineChartData _patientsChartData() {
    final months = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct'];
    final values = [120, 135, 128, 160, 140, 170, 182, 175, 160, 178];

    return LineChartData(
      minX: 0,
      maxX: 9,
      minY: 0,
      maxY: 200,
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
            reservedSize: 34,
            interval: 50,
            getTitlesWidget: (v, _) => Text(v.toInt().toString(), style: const TextStyle(fontSize: 12, color: kTextSecondary)),
          ),
        ),
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            interval: 1,
            getTitlesWidget: (v, _) => Padding(
              padding: const EdgeInsets.only(top: 6),
              child: Text(months[v.toInt()], style: const TextStyle(fontSize: 12, color: kTextSecondary)),
            ),
          ),
        ),
      ),
      borderData: FlBorderData(show: true, border: const Border(
        top: BorderSide(color: Color(0xFFE0E6EE)),
        left: BorderSide(color: Color(0xFFE0E6EE)),
        right: BorderSide(color: Color(0xFFE0E6EE)),
        bottom: BorderSide(color: Color(0xFFE0E6EE)),
      )),
      lineBarsData: [
        LineChartBarData(
          isCurved: true,
          color: const Color(0xFF8B5CF6),
          barWidth: 3,
          dotData: const FlDotData(show: true),
          belowBarData: BarAreaData(show: false),
          spots: List.generate(values.length, (i) => FlSpot(i.toDouble(), values[i].toDouble())),
        ),
      ],
      lineTouchData: LineTouchData(
        touchTooltipData: LineTouchTooltipData(
          getTooltipColor: (touchedSpot) => Colors.white,
          tooltipRoundedRadius: 8,
          getTooltipItems: (items) => items.map((s) => LineTooltipItem('${values[s.x.toInt()]} patients', const TextStyle(color: kTextPrimary, fontWeight: FontWeight.w700))).toList(),
        ),
      ),
    );
  }
}
