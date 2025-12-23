import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:dentist_ms/core/constants/app_colors.dart';
import 'package:dentist_ms/features/dashboard/bloc/patients_bloc.dart';
import 'package:dentist_ms/features/dashboard/bloc/patients_event.dart';
import 'package:dentist_ms/features/dashboard/bloc/patients_state.dart';
import 'package:dentist_ms/features/dashboard/models/patients_chart_data.dart';
import '../dashboard_constants.dart';

class PatientsPanel extends StatefulWidget {
  final double screenWidth;
  final double screenHeight;
  
  const PatientsPanel({super.key, required this.screenWidth, required this.screenHeight});

  @override
  State<PatientsPanel> createState() => _PatientsPanelState();
}

class _PatientsPanelState extends State<PatientsPanel> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance. addPostFrameCallback((_) {
      if (mounted) {
        context.read<PatientsBloc>().add(LoadPatientsChart(year: DateTime.now().year));
      }
    });
  }

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
                const Text('Croissance des patients', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: kTextPrimary)),
                const SizedBox(height: 6),
                const Text('Acquisition mensuelle de patients', style: TextStyle(color:  kTextSecondary)),
                const SizedBox(height: 16),
                Expanded(
                  child: BlocBuilder<PatientsBloc, PatientsState>(
                    builder:  (context, state) => _buildChart(context, state),
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

  Widget _buildChart(BuildContext context, PatientsState state) {
    if (state is PatientsLoadInProgress) return const Center(child: CircularProgressIndicator());
    if (state is PatientsOperationFailure) return Center(child: Text('Erreur: ${state.message}', style: const TextStyle(color:  Colors.red)));
    if (state is PatientsLoadSuccess) {
      return Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border. all(color: const Color(0xFFE7E7E7)),
        ),
        padding: const EdgeInsets.fromLTRB(10, 10, 18, 18),
        child: LineChart(_patientsChartData(state.chartData)),
      );
    }
    return const SizedBox.shrink();
  }

  LineChartData _patientsChartData(PatientsChartData chartData) {
    final months = ['Jan', 'Fév', 'Mar', 'Avr', 'Mai', 'Jun', 'Jul', 'Aoû', 'Sep', 'Oct', 'Nov', 'Déc'];
    final spots = chartData.monthlyData. asMap().entries.map((e) => FlSpot(e.key.toDouble(), e.value.cumulativeCount. toDouble())).toList();

    return LineChartData(
      minX: 0,
      maxX: 11,
      minY: 0,
      maxY: chartData.yAxisMax. toDouble(),
      clipData: FlClipData.all(),
      gridData: FlGridData(
        show: true,
        getDrawingHorizontalLine: (_) => const FlLine(color:  Color(0xFFE8EDF4), strokeWidth: 1),
        getDrawingVerticalLine: (_) => const FlLine(color: Color(0xFFE8EDF4), strokeWidth: 1),
        drawVerticalLine: true,
      ),
      titlesData: FlTitlesData(
        topTitles: const AxisTitles(sideTitles:  SideTitles(showTitles: false)),
        rightTitles: const AxisTitles(sideTitles:  SideTitles(showTitles: false)),
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 50,
            interval: chartData. yAxisInterval,
            getTitlesWidget: (value, _) => Text(_formatYAxisLabel(value. toInt()), style: const TextStyle(fontSize: 11, color: kTextSecondary)),
          ),
        ),
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            interval: 1,
            getTitlesWidget: (value, _) {
              final index = value.toInt();
              if (index >= 0 && index < months.length) {
                return Padding(padding: const EdgeInsets.only(top: 6), child: Text(months[index], style: const TextStyle(fontSize: 12, color:  kTextSecondary)));
              }
              return const SizedBox.shrink();
            },
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
          curveSmoothness: 0.35,
          preventCurveOverShooting: true,
          color: const Color(0xFF8B5CF6),
          barWidth:  3,
          dotData: FlDotData(
            show: true,
            getDotPainter: (spot, percent, barData, index) => FlDotCirclePainter(radius: 4, color: const Color(0xFF8B5CF6), strokeWidth: 2, strokeColor: Colors.white),
          ),
          belowBarData: BarAreaData(show: false),
          spots: spots,
        ),
      ],
      lineTouchData: LineTouchData(
        touchTooltipData: LineTouchTooltipData(
          getTooltipColor: (touchedSpot) => Colors.white,
          tooltipRoundedRadius: 8,
          getTooltipItems: (touchedSpots) => touchedSpots.map((s) {
            final monthData = chartData.monthlyData[s.x.toInt()];
            return LineTooltipItem(
              '${monthData.cumulativeCount} patients\n(+${monthData.newPatients} nouveau${monthData.newPatients > 1 ? "x" : ""})',
              const TextStyle(color: kTextPrimary, fontWeight: FontWeight.w700, fontSize: 12),
            );
          }).toList(),
        ),
      ),
    );
  }

  String _formatYAxisLabel(int value) {
    if (value >= 1000000) return '${(value / 1000000).toStringAsFixed(1)}M';
    if (value >= 1000) return '${(value / 1000).toStringAsFixed(0)}K';
    return value.toString();
  }
}