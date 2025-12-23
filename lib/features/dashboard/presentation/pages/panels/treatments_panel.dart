import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:dentist_ms/core/constants/app_colors.dart';
import 'package:dentist_ms/features/dashboard/bloc/treatments_bloc.dart';
import 'package:dentist_ms/features/dashboard/bloc/treatments_event.dart';
import 'package:dentist_ms/features/dashboard/bloc/treatments_state.dart';
import 'package:dentist_ms/features/dashboard/models/treatments_chart_data.dart';
import '../dashboard_constants.dart';
import '../widgets/treatment_volume_row.dart';

class TreatmentsPanel extends StatefulWidget {
  final double screenWidth;
  final double screenHeight;
  
  const TreatmentsPanel({super.key, required this.screenWidth, required this.screenHeight});

  @override
  State<TreatmentsPanel> createState() => _TreatmentsPanelState();
}

class _TreatmentsPanelState extends State<TreatmentsPanel> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<TreatmentsBloc>().add(LoadTreatmentsChart());
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children:  [
        Expanded(
          flex: 3,
          child: Container(
            decoration: BoxDecoration(color: kSurface, borderRadius: BorderRadius.circular(kRadiusCard), border: Border.all(color: kBorder)),
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Répartition des traitements', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: kTextPrimary)),
                const SizedBox(height: 6),
                const Text('Ventilation par type de traitement', style: TextStyle(color: kTextSecondary)),
                const SizedBox(height: 12),
                Expanded(child: BlocBuilder<TreatmentsBloc, TreatmentsState>(builder: (context, state) => _buildPieChart(context, state))),
              ],
            ),
          ),
        ),
        const SizedBox(width: 24),
        Expanded(
          flex: 2,
          child: Container(
            decoration: BoxDecoration(color: kSurface, borderRadius: BorderRadius.circular(kRadiusCard), border: Border.all(color: kBorder)),
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Volume de traitement', style: TextStyle(fontSize: 18, fontWeight:  FontWeight.w700, color: kTextPrimary)),
                const SizedBox(height: 6),
                const Text('Nombre de traitements effectués', style: TextStyle(color: kTextSecondary)),
                const SizedBox(height:  12),
                Expanded(child: BlocBuilder<TreatmentsBloc, TreatmentsState>(builder: (context, state) => _buildVolumeList(context, state))),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPieChart(BuildContext context, TreatmentsState state) {
    if (state is TreatmentsLoadInProgress) return const Center(child: CircularProgressIndicator());
    if (state is TreatmentsOperationFailure) return Center(child:  Padding(padding: const EdgeInsets.all(16.0), child: Text('Erreur: ${state.message}', style: const TextStyle(color:  Colors.red), textAlign: TextAlign.center)));
    if (state is TreatmentsLoadSuccess) {
      final treatmentsWithData = state.chartData.treatments.where((t) => t.count > 0).toList();
      if (treatmentsWithData.isEmpty) {
        return Container(
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14), border: Border.all(color: const Color(0xFFE7E7E7))),
          child: const Center(child: Text('Aucun traitement effectué', style: TextStyle(color: kTextSecondary, fontSize: 14))),
        );
      }
      return Container(
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14), border: Border.all(color: const Color(0xFFE7E7E7))),
        padding: const EdgeInsets.all(8),
        child: PieChart(PieChartData(sectionsSpace: 2, centerSpaceRadius: 0, sections: _createPieSections(treatmentsWithData))),
      );
    }
    return const SizedBox. shrink();
  }

  List<PieChartSectionData> _createPieSections(List<TreatmentDistribution> treatments) {
    final colors = [
      const Color(0xFF3B82F6), const Color(0xFF10B981), const Color(0xFFF59E0B), const Color(0xFF6366F1),
      const Color(0xFFEC4899), const Color(0xFFEF4444), const Color(0xFF8B5CF6), const Color(0xFF14B8A6),
      const Color(0xFFF97316), const Color(0xFF06B6D4),
    ];
    return treatments.asMap().entries.map((entry) {
      final color = colors[entry.key % colors.length];
      final percentage = entry.value. percentage. isFinite ? entry.value.percentage :  0.0;
      return PieChartSectionData(
        value: entry.value.count.toDouble(),
        title: '${entry.value.treatmentName}\n${percentage.toStringAsFixed(1)}%',
        color: color,
        radius: 180,
        titleStyle: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w700, shadows: [Shadow(color: Colors.black26, offset: Offset(1, 1), blurRadius: 2)]),
        titlePositionPercentageOffset: 0.6,
      );
    }).toList();
  }

  Widget _buildVolumeList(BuildContext context, TreatmentsState state) {
    if (state is TreatmentsLoadInProgress) return const Center(child: CircularProgressIndicator());
    if (state is TreatmentsOperationFailure) return Center(child: Padding(padding: const EdgeInsets.all(8.0), child: Text('Erreur: ${state.message}', style: const TextStyle(color: Colors.red, fontSize: 12), textAlign: TextAlign.center)));
    if (state is TreatmentsLoadSuccess) {
      if (state.chartData.treatments. isEmpty) return const Center(child: Text('Aucune donnée disponible', style: TextStyle(color: kTextSecondary)));
      final maxCount = state.chartData.maxCount > 0 ? state.chartData.maxCount : 1;
      return ListView.builder(
        padding: EdgeInsets.zero,
        itemCount: state.chartData.treatments.length,
        itemBuilder: (context, index) {
          final treatment = state.chartData.treatments[index];
          return TreatmentVolumeRow(label: treatment.treatmentName, value: treatment.count, max: maxCount);
        },
      );
    }
    return const SizedBox.shrink();
  }
}