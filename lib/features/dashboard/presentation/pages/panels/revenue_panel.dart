import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/gestures.dart';
import 'package:dentist_ms/core/constants/app_colors.dart';
import 'package:dentist_ms/features/dashboard/bloc/revenue_bloc.dart';
import 'package:dentist_ms/features/dashboard/bloc/revenue_event.dart';
import 'package:dentist_ms/features/dashboard/bloc/revenue_state.dart';
import 'package:dentist_ms/features/dashboard/models/revenue_chart_data.dart';
import '../dashboard_constants.dart';
import '../widgets/legend_dot.dart';
import '../widgets/treatment_row.dart';

class RevenuePanel extends StatefulWidget {
  final double screenWidth;
  final double screenHeight;
  
  const RevenuePanel({
    super.key,
    required this.screenWidth,
    required this.screenHeight,
  });

  @override
  State<RevenuePanel> createState() => _RevenuePanelState();
}

class _RevenuePanelState extends State<RevenuePanel> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<RevenueBloc>().add(LoadRevenueChart(year: DateTime. now().year));
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
              borderRadius: BorderRadius. circular(kRadiusCard),
              border: Border.all(color: kBorder),
            ),
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Tendances des revenus et des bénéfices',
                  style:  TextStyle(
                    fontSize:  18,
                    fontWeight: FontWeight.w700,
                    color: kTextPrimary,
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Analyse mensuelle des revenus et bénéfices',
                  style: TextStyle(color:  kTextSecondary),
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: BlocBuilder<RevenueBloc, RevenueState>(
                    builder: (context, state) {
                      return _buildChart(context, state);
                    },
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    LegendDot(color: Color(0xFF10B981)),
                    SizedBox(width: 6),
                    Text('Bénéfice', style: TextStyle(color: kTextSecondary, fontWeight: FontWeight.w600)),
                    SizedBox(width: 18),
                    LegendDot(color: Color(0xFF2563EB)),
                    SizedBox(width: 6),
                    Text('Chiffre d\'affaires', style: TextStyle(color: kTextSecondary, fontWeight: FontWeight.w600)),
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
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: kTextPrimary),
                ),
                const SizedBox(height: 6),
                const Text('Traitements avec les revenus les plus élevés', style: TextStyle(color: kTextSecondary)),
                const SizedBox(height: 12),
                Expanded(
                  child: BlocBuilder<RevenueBloc, RevenueState>(
                    builder: (context, state) {
                      return _buildTopTreatments(context, state);
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildChart(BuildContext context, RevenueState state) {
    if (state is RevenueLoadInProgress) {
      return const Center(child: CircularProgressIndicator());
    }
    if (state is RevenueOperationFailure) {
      return Center(child: Text('Erreur: ${state.message}', style: const TextStyle(color:  Colors.red)));
    }
    if (state is RevenueLoadSuccess) {
      return Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFE7E7E7)),
        ),
        padding: const EdgeInsets.fromLTRB(10, 10, 18, 18),
        child: LineChart(_revenueChartData(state. chartData)),
      );
    }
    return const SizedBox. shrink();
  }

  Widget _buildTopTreatments(BuildContext context, RevenueState state) {
    if (state is RevenueLoadInProgress) {
      return const Center(child: CircularProgressIndicator());
    }
    if (state is RevenueOperationFailure) {
      return Center(child: Text('Erreur: ${state.message}', style: const TextStyle(color: Colors.red, fontSize: 12)));
    }
    if (state is RevenueLoadSuccess) {
      final topTreatments = state.chartData.topTreatments;
      if (topTreatments.isEmpty) {
        return const Center(child: Text('Aucune donnée disponible', style: TextStyle(color: kTextSecondary)));
      }
      return ScrollConfiguration(
        behavior: ScrollConfiguration.of(context).copyWith(
          dragDevices: {PointerDeviceKind.touch, PointerDeviceKind.mouse, PointerDeviceKind. trackpad},
        ),
        child: ListView.builder(
          padding: EdgeInsets.zero,
          itemCount: topTreatments.length,
          itemBuilder: (context, index) {
            final treatment = topTreatments[index];
            return TreatmentRow(
              title: treatment.treatmentName,
              amount: '${treatment.totalAmount.toStringAsFixed(0)} DA',
              progress: treatment.progress,
              count: treatment.count,
            );
          },
        ),
      );
    }
    return const SizedBox.shrink();
  }

  LineChartData _revenueChartData(RevenueChartData chartData) {
    final months = ['Jan', 'Fév', 'Mar', 'Avr', 'Mai', 'Jun', 'Jul', 'Aoû', 'Sep', 'Oct', 'Nov', 'Déc'];
    final revenueSpots = chartData.monthlyData.asMap().entries.map((e) => FlSpot(e.key.toDouble(), e.value.totalRevenue)).toList();
    final profitSpots = chartData.monthlyData.asMap().entries.map((e) => FlSpot(e.key.toDouble(), e.value.netProfit)).toList();

    double minYValue = 0;
    for (var data in chartData.monthlyData) {
      if (data.netProfit < minYValue) minYValue = data.netProfit;
      if (data.totalRevenue < minYValue) minYValue = data.totalRevenue;
    }
    if (minYValue < 0) minYValue = (minYValue * 1.2).floorToDouble();

    return LineChartData(
      minX: 0,
      maxX: 11,
      minY: minYValue,
      maxY: chartData.yAxisMax,
      clipData: FlClipData.all(),
      gridData: FlGridData(
        show: true,
        drawVerticalLine: true,
        getDrawingHorizontalLine: (_) => const FlLine(color:  Color(0xFFE8EDF4), strokeWidth: 1),
        getDrawingVerticalLine: (_) => const FlLine(color: Color(0xFFE8EDF4), strokeWidth: 1),
      ),
      titlesData: FlTitlesData(
        rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            interval: chartData.yAxisInterval,
            reservedSize: 60,
            getTitlesWidget:  (value, _) => Text(_formatYAxisLabel(value), style: const TextStyle(fontSize: 11, color: kTextSecondary)),
          ),
        ),
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles:  true,
            interval: 1,
            getTitlesWidget: (value, _) {
              final index = value.toInt();
              if (index >= 0 && index < months. length) {
                return Padding(padding: const EdgeInsets.only(top: 6), child: Text(months[index], style: const TextStyle(fontSize: 12, color: kTextSecondary)));
              }
              return const SizedBox. shrink();
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
      lineTouchData: LineTouchData(
        touchTooltipData: LineTouchTooltipData(
          getTooltipColor: (touchedSpot) => Colors.white,
          tooltipRoundedRadius: 8,
          getTooltipItems: (touchedSpots) => touchedSpots.map((s) {
            final isRevenue = s.barIndex == 1;
            return LineTooltipItem(
              '${isRevenue ? "Rev" : "Bén"}:  ${_formatYAxisLabel(s.y)}',
              TextStyle(color: isRevenue ? const Color(0xFF2563EB) : const Color(0xFF10B981), fontWeight: FontWeight.w700, fontSize: 12),
            );
          }).toList(),
        ),
      ),
      lineBarsData: [
        LineChartBarData(
          isCurved: true,
          curveSmoothness: 0.35,
          preventCurveOverShooting: true,
          color: const Color(0xFF10B981),
          barWidth: 3,
          belowBarData: BarAreaData(show: true, color: const Color(0xFF10B981).withOpacity(0.15), cutOffY: minYValue, applyCutOffY: true),
          dotData: const FlDotData(show: false),
          spots: profitSpots,
        ),
        LineChartBarData(
          isCurved: true,
          curveSmoothness: 0.35,
          preventCurveOverShooting: true,
          color: const Color(0xFF2563EB),
          barWidth: 3,
          belowBarData:  BarAreaData(show: true, color: const Color(0xFF2563EB).withOpacity(0.15), cutOffY: minYValue, applyCutOffY: true),
          dotData: const FlDotData(show: false),
          spots: revenueSpots,
        ),
      ],
    );
  }

  String _formatYAxisLabel(double value) {
    if (value >= 1000000) return '${(value / 1000000).toStringAsFixed(1)}M';
    if (value >= 1000) return '${(value / 1000).toStringAsFixed(0)}K';
    if (value <= -1000000) return '${(value / 1000000).toStringAsFixed(1)}M';
    if (value <= -1000) return '${(value / 1000).toStringAsFixed(0)}K';
    return value.toStringAsFixed(0);
  }
}