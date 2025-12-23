import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/gestures.dart';
import 'package:dentist_ms/core/constants/app_colors.dart';
import 'package:dentist_ms/features/dashboard/bloc/performance_bloc.dart';
import 'package:dentist_ms/features/dashboard/bloc/performance_event.dart';
import 'package:dentist_ms/features/dashboard/bloc/performance_state.dart';
import 'package:dentist_ms/features/dashboard/models/performance_chart_data.dart';
import '../dashboard_constants.dart';
import '../widgets/doctor_performance_row.dart';

class PerformancePanel extends StatefulWidget {
  final double screenWidth;
  final double screenHeight;
  
  const PerformancePanel({super.key, required this.screenWidth, required this.screenHeight});

  @override
  State<PerformancePanel> createState() => _PerformancePanelState();
}

class _PerformancePanelState extends State<PerformancePanel> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<PerformanceBloc>().add(LoadPerformanceChart(year: DateTime.now().year));
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
                const Text(
                  'Performance des rendez-vous',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: kTextPrimary),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Répartition des statuts par mois',
                  style: TextStyle(color: kTextSecondary),
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: BlocBuilder<PerformanceBloc, PerformanceState>(
                    builder: (context, state) => _buildChart(context, state),
                  ),
                ),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 24,
                  runSpacing:  12,
                  alignment: WrapAlignment.center,
                  children: const [
                    _LegendItem(color: Color(0xFF10B981), label: 'Terminé'),
                    _LegendItem(color: Color(0xFF3B82F6), label: 'Confirmé'),
                    _LegendItem(color: Color(0xFFF59E0B), label: 'Annulé'),
                    _LegendItem(color: Color(0xFFEF4444), label: 'Absent'),
                  ],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 24),
        Expanded(
          flex: 2,
          child:  Container(
            decoration: BoxDecoration(
              color: kSurface,
              borderRadius:  BorderRadius.circular(kRadiusCard),
              border: Border.all(color: kBorder),
            ),
            padding:  const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Performance des docteurs',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: kTextPrimary),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Classement par traitements terminés',
                  style: TextStyle(color: kTextSecondary),
                ),
                const SizedBox(height: 12),
                Expanded(
                  child: BlocBuilder<PerformanceBloc, PerformanceState>(
                    builder: (context, state) => _buildDoctorPerformance(context, state),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildChart(BuildContext context, PerformanceState state) {
    if (state is PerformanceLoadInProgress) {
      return const Center(child: CircularProgressIndicator());
    }
    if (state is PerformanceOperationFailure) {
      return Center(
        child:  Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            'Erreur:  ${state.message}',
            style: const TextStyle(color: Colors.red),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }
    if (state is PerformanceLoadSuccess) {
      return Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFE7E7E7)),
        ),
        padding: const EdgeInsets.fromLTRB(10, 10, 18, 18),
        child: BarChart(_performanceChartData(state.chartData)),
      );
    }
    return const SizedBox. shrink();
  }

  Widget _buildDoctorPerformance(BuildContext context, PerformanceState state) {
    if (state is PerformanceLoadInProgress) {
      return const Center(child: CircularProgressIndicator());
    }
    if (state is PerformanceOperationFailure) {
      return Center(
        child:  Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            'Erreur:  ${state.message}',
            style: const TextStyle(color:  Colors.red, fontSize: 12),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }
    if (state is PerformanceLoadSuccess) {
      final doctors = state.chartData.doctorPerformance;
      
      if (doctors.isEmpty) {
        return const Center(
          child:  Text(
            'Aucune donnée disponible',
            style:  TextStyle(color: kTextSecondary),
          ),
        );
      }

      return ScrollConfiguration(
        behavior: ScrollConfiguration.of(context).copyWith(
          dragDevices: {
            PointerDeviceKind.touch,
            PointerDeviceKind.mouse,
            PointerDeviceKind. trackpad,
          },
        ),
        child: ListView.builder(
          padding: EdgeInsets.zero,
          itemCount: doctors.length,
          itemBuilder: (context, index) {
            final doctor = doctors[index];
            return DoctorPerformanceRow(
              doctorName: doctor.doctorName,
              completedTreatments: doctor.completedTreatments,
              progress: doctor.progress,
              rank: index + 1,
            );
          },
        ),
      );
    }
    return const SizedBox.shrink();
  }

  BarChartData _performanceChartData(PerformanceChartData chartData) {
    final months = ['Jan', 'Fév', 'Mar', 'Avr', 'Mai', 'Jun', 'Jul', 'Aoû', 'Sep', 'Oct', 'Nov', 'Déc'];
    return BarChartData(
      alignment: BarChartAlignment. spaceAround,
      maxY: 100,
      minY: 0,
      barTouchData: BarTouchData(
        enabled: true,
        touchTooltipData: BarTouchTooltipData(
          getTooltipColor: (group) => Colors.white,
          tooltipRoundedRadius: 8,
          tooltipPadding: const EdgeInsets.all(8),
          getTooltipItem: (group, groupIndex, rod, rodIndex) {
            final monthData = chartData.monthlyData[group.x. toInt()];
            return BarTooltipItem(
              '${months[group.x.toInt()]}\n',
              const TextStyle(color:  kTextPrimary, fontWeight: FontWeight.bold, fontSize: 12),
              children: [
                TextSpan(
                  text:  'Total: ${monthData.totalCount}\n',
                  style: const TextStyle(color: kTextSecondary, fontSize: 11, fontWeight: FontWeight.normal),
                ),
                TextSpan(
                  text: '🟢 ${monthData.completedPercentage.toStringAsFixed(0)}%\n',
                  style: const TextStyle(color:  Color(0xFF10B981), fontSize: 11, fontWeight: FontWeight.normal),
                ),
                TextSpan(
                  text: '🔵 ${monthData.confirmedPercentage.toStringAsFixed(0)}%\n',
                  style: const TextStyle(color: Color(0xFF3B82F6), fontSize: 11, fontWeight: FontWeight.normal),
                ),
                TextSpan(
                  text: '🟠 ${monthData.cancelledPercentage.toStringAsFixed(0)}%\n',
                  style: const TextStyle(color: Color(0xFFF59E0B), fontSize: 11, fontWeight: FontWeight. normal),
                ),
                TextSpan(
                  text:  '🔴 ${monthData.noShowPercentage.toStringAsFixed(0)}%',
                  style: const TextStyle(color: Color(0xFFEF4444), fontSize: 11, fontWeight: FontWeight. normal),
                ),
              ],
            );
          },
        ),
      ),
      titlesData: FlTitlesData(
        show: true,
        rightTitles: const AxisTitles(sideTitles:  SideTitles(showTitles: false)),
        topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        bottomTitles: AxisTitles(
          sideTitles:  SideTitles(
            showTitles: true,
            getTitlesWidget: (value, meta) {
              final index = value.toInt();
              if (index >= 0 && index < months. length) {
                return Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    months[index],
                    style: const TextStyle(color: kTextSecondary, fontSize: 11),
                  ),
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ),
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 40,
            interval: 25,
            getTitlesWidget:  (value, meta) => Text(
              '${value.toInt()}%',
              style: const TextStyle(color: kTextSecondary, fontSize: 11),
            ),
          ),
        ),
      ),
      gridData: FlGridData(
        show: true,
        drawVerticalLine: false,
        horizontalInterval: 25,
        getDrawingHorizontalLine: (value) => const FlLine(color: Color(0xFFE8EDF4), strokeWidth: 1),
      ),
      borderData: FlBorderData(
        show: true,
        border: const Border(
          left: BorderSide(color: Color(0xFFE0E6EE)),
          bottom: BorderSide(color: Color(0xFFE0E6EE)),
        ),
      ),
      barGroups: _createBarGroups(chartData. monthlyData),
    );
  }

  List<BarChartGroupData> _createBarGroups(List<MonthlyAppointmentStatus> monthlyData) {
    return monthlyData.asMap().entries.map((entry) {
      final data = entry.value;
      if (data.totalCount == 0) {
        return BarChartGroupData(
          x: entry.key,
          barRods: [
            BarChartRodData(
              toY: 0,
              rodStackItems: [],
              width: 16,
              borderRadius: BorderRadius.circular(4),
            ),
          ],
        );
      }
      return BarChartGroupData(
        x: entry.key,
        barRods: [
          BarChartRodData(
            toY: 100,
            width: 16,
            borderRadius: BorderRadius.circular(4),
            rodStackItems: [
              BarChartRodStackItem(0, data.completedPercentage, const Color(0xFF10B981)),
              BarChartRodStackItem(
                data.completedPercentage,
                data.completedPercentage + data.confirmedPercentage,
                const Color(0xFF3B82F6),
              ),
              BarChartRodStackItem(
                data.completedPercentage + data.confirmedPercentage,
                data.completedPercentage + data.confirmedPercentage + data.cancelledPercentage,
                const Color(0xFFF59E0B),
              ),
              BarChartRodStackItem(
                data.completedPercentage + data.confirmedPercentage + data.cancelledPercentage,
                100,
                const Color(0xFFEF4444),
              ),
            ],
          ),
        ],
      );
    }).toList();
  }
}

class _LegendItem extends StatelessWidget {
  final Color color;
  final String label;
  const _LegendItem({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width:  6),
        Text(
          label,
          style: const TextStyle(
            color: kTextSecondary,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}