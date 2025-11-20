import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/gestures.dart';
import 'package:dentist_ms/core/constants/app_colors.dart';
import '../dashboard_constants.dart';
import '../widgets/legend_dot.dart';
import '../widgets/treatment_row.dart';

class RevenuePanel extends StatelessWidget {
  final double screenWidth;
  final double screenHeight;
  const RevenuePanel({super.key, required this.screenWidth, required this.screenHeight});

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
                  'Tendances des revenus et des bénéfices',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: kTextPrimary,
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Analyse mensuelle des revenus et bénéfices',
                  style: TextStyle(color: kTextSecondary),
                ),
                const SizedBox(height: 16),

                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: const Color(0xFFE7E7E7)),
                    ),
                    padding: const EdgeInsets.fromLTRB(10, 10, 18, 18),
                    child: LineChart(_revenueChartData()),
                  ),
                ),

                const SizedBox(height: 10),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    LegendDot(color: Color(0xFF10B981)),
                    SizedBox(width: 6),
                    Text(
                      'Bénéfice',
                      style: TextStyle(
                        color: kTextSecondary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(width: 18),
                    LegendDot(color: Color(0xFF2563EB)),
                    SizedBox(width: 6),
                    Text(
                      'Chiffre d\'affaires',
                      style: TextStyle(
                        color: kTextSecondary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
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
                  'Meilleurs traitements par chiffre d\'affaires',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: kTextPrimary,
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Traitements avec les revenus les plus élevés',
                  style: TextStyle(color: kTextSecondary),
                ),
                const SizedBox(height: 12),

                Expanded(
                  child: ScrollConfiguration(
                    behavior: ScrollConfiguration.of(context).copyWith(
                      dragDevices: {
                        PointerDeviceKind.touch,
                        PointerDeviceKind.mouse,
                        PointerDeviceKind.trackpad,
                      },
                    ),
                    child: Scrollbar(
                      thumbVisibility: true,
                      child: ListView(
                        padding: EdgeInsets.zero,
                        children: const [
                          TreatmentRow(
                            title: 'Nettoyage dentaire',
                            amount: '\$21 750',
                            progress: 0.18,
                            count: 145,
                          ),
                          TreatmentRow(
                            title: 'Obturation',
                            amount: '\$24 500',
                            progress: 0.12,
                            count: 98,
                          ),
                          TreatmentRow(
                            title: 'Traitement orthodontique',
                            amount: '\$195 000',
                            progress: 1.00,
                            count: 65,
                          ),
                          TreatmentRow(
                            title: 'Traitement radiculaire',
                            amount: '\$50 400',
                            progress: 0.32,
                            count: 42,
                          ),
                          TreatmentRow(
                            title: 'Implant dentaire',
                            amount: '\$70 000',
                            progress: 0.28,
                            count: 28,
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
      ],
    );
  }

  LineChartData _revenueChartData() {
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
    final gridPaint = Paint()
      ..color = const Color(0xFFE8EDF4)
      ..strokeWidth = 1;

    return LineChartData(
      minX: 0,
      maxX: 9,
      minY: 0,
      maxY: 80000,
      gridData: FlGridData(
        show: true,
        drawVerticalLine: true,
        getDrawingHorizontalLine: (_) => FlLine(color: gridPaint.color, strokeWidth: 1),
        getDrawingVerticalLine: (_) => FlLine(color: gridPaint.color, strokeWidth: 1),
      ),
      titlesData: FlTitlesData(
        rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            interval: 20000,
            reservedSize: 48,
            getTitlesWidget: (value, _) => Text(
              value.toInt().toString(),
              style: const TextStyle(fontSize: 12, color: kTextSecondary),
            ),
          ),
        ),
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            interval: 1,
            getTitlesWidget: (value, _) => Padding(
              padding: const EdgeInsets.only(top: 6),
              child: Text(
                months[value.toInt()],
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
      lineTouchData: LineTouchData(
        touchTooltipData: LineTouchTooltipData(
          getTooltipColor: (touchedSpot) => Colors.white,
          tooltipRoundedRadius: 8,
          getTooltipItems: (touchedSpots) => touchedSpots.map((s) {
            return LineTooltipItem(
              '\$${s.y.toInt()}',
              const TextStyle(
                color: kTextPrimary,
                fontWeight: FontWeight.w700,
              ),
            );
          }).toList(),
        ),
      ),
      lineBarsData: [
        LineChartBarData(
          isCurved: true,
          color: const Color(0xFF10B981),
          barWidth: 3,
          belowBarData: BarAreaData(
            show: true,
            color: const Color(0xFF10B981).withOpacity(0.15),
          ),
          dotData: const FlDotData(show: false),
          spots: const [
            FlSpot(0, 17000),
            FlSpot(1, 22000),
            FlSpot(2, 19000),
            FlSpot(3, 29000),
            FlSpot(4, 24000),
            FlSpot(5, 33000),
            FlSpot(6, 37000),
            FlSpot(7, 36000),
            FlSpot(8, 32000),
            FlSpot(9, 37000),
          ],
        ),
        LineChartBarData(
          isCurved: true,
          color: const Color(0xFF2563EB),
          barWidth: 3,
          belowBarData: BarAreaData(
            show: true,
            color: const Color(0xFF2563EB).withOpacity(0.15),
          ),
          dotData: const FlDotData(show: false),
          spots: const [
            FlSpot(0, 45000),
            FlSpot(1, 51000),
            FlSpot(2, 48000),
            FlSpot(3, 61000),
            FlSpot(4, 56000),
            FlSpot(5, 68000),
            FlSpot(6, 73000),
            FlSpot(7, 71000),
            FlSpot(8, 65000),
            FlSpot(9, 72000),
          ],
        ),
      ],
    );
  }
}
