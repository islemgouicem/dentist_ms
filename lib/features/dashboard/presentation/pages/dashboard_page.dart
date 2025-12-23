import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dentist_ms/core/constants/app_colors.dart';
import 'package:dentist_ms/features/dashboard/bloc/dashboard_bloc.dart';
import 'package:dentist_ms/features/dashboard/bloc/dashboard_event.dart';
import 'package:dentist_ms/features/dashboard/bloc/dashboard_state.dart';
import 'package:dentist_ms/features/dashboard/bloc/revenue_bloc.dart';
import 'package:dentist_ms/features/dashboard/bloc/patients_bloc.dart';
import 'package:dentist_ms/features/dashboard/bloc/treatments_bloc.dart';
import 'package:dentist_ms/features/dashboard/bloc/performance_bloc.dart';
import 'package:dentist_ms/features/dashboard/data/dashboard_remote.dart';
import 'package:dentist_ms/features/dashboard/repositories/dashboard_repository.dart';
import 'package:dentist_ms/features/dashboard/data/revenue_remote.dart';
import 'package:dentist_ms/features/dashboard/repositories/revenue_repository.dart';
import 'package:dentist_ms/features/dashboard/data/patients_remote.dart';
import 'package:dentist_ms/features/dashboard/repositories/patients_repository.dart';
import 'package:dentist_ms/features/dashboard/data/treatments_remote.dart';
import 'package:dentist_ms/features/dashboard/repositories/treatments_repository.dart';
import 'package:dentist_ms/features/dashboard/data/performance_remote.dart';
import 'package:dentist_ms/features/dashboard/repositories/performance_repository.dart';
import 'package:dentist_ms/features/dashboard/services/pdf_export_service.dart';
import 'package:dentist_ms/features/dashboard/bloc/revenue_state.dart';
import 'package:dentist_ms/features/dashboard/bloc/revenue_event.dart';
import 'package:dentist_ms/features/dashboard/bloc/patients_state.dart';
import 'package:dentist_ms/features/dashboard/bloc/patients_event.dart';
import 'package:dentist_ms/features/dashboard/bloc/treatments_state.dart';
import 'package:dentist_ms/features/dashboard/bloc/treatments_event.dart';
import 'package:dentist_ms/features/dashboard/bloc/performance_state.dart';
import 'package:dentist_ms/features/dashboard/bloc/performance_event.dart';
import 'dashboard_constants.dart';
import 'panels/revenue_panel.dart';
import 'panels/patients_panel.dart';
import 'panels/treatments_panel.dart';
import 'panels/performance_panel.dart';
import 'widgets/metric_card.dart';
import 'widgets/pill_tabs.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers:  [
        BlocProvider(
          create: (context) => DashboardBloc(
            repository: SupabaseDashboardRepository(
              remote: DashboardRemoteDataSource(),
            ),
          ),
        ),
        BlocProvider(
          create: (context) => RevenueBloc(
            repository: SupabaseRevenueRepository(
              remote: RevenueRemoteDataSource(),
            ),
          ),
        ),
        BlocProvider(
          create: (context) => PatientsBloc(
            repository: SupabasePatientsRepository(
              remote: PatientsRemoteDataSource(),
            ),
          ),
        ),
        BlocProvider(
          create: (context) => TreatmentsBloc(
            repository: SupabaseTreatmentsRepository(
              remote: TreatmentsRemoteDataSource(),
            ),
          ),
        ),
        BlocProvider(
          create: (context) => PerformanceBloc(
            repository: SupabasePerformanceRepository(
              remote: PerformanceRemoteDataSource(),
            ),
          ),
        ),
      ],
      child: const _DashboardPageContent(),
    );
  }
}

class _DashboardPageContent extends StatefulWidget {
  const _DashboardPageContent();

  @override
  State<_DashboardPageContent> createState() => _DashboardPageContentState();
}

class _DashboardPageContentState extends State<_DashboardPageContent> {
  String selectedRange = 'This Year';
  int currentTab = 0;
  bool _isExporting = false;

  @override
  void initState() {
    super.initState();
    context.read<DashboardBloc>().add(LoadDashboardMetrics(dateRange: selectedRange));
  }

  void _onDateRangeChanged(String newRange) {
    setState(() => selectedRange = newRange);
    
    context.read<DashboardBloc>().add(LoadDashboardMetrics(dateRange: newRange));
    
    final year = newRange == 'Last Year' ? DateTime.now().year - 1 : DateTime.now().year;
    
    context.read<RevenueBloc>().add(LoadRevenueChart(year: year));
    context.read<PatientsBloc>().add(LoadPatientsChart(year: year));
    context.read<TreatmentsBloc>().add(LoadTreatmentsChart());
    context.read<PerformanceBloc>().add(LoadPerformanceChart(year:  year));
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final isMobile = screenWidth < 700;
    final isTablet = screenWidth >= 700 && screenWidth < 1100;
    final maxContentWidth = screenWidth > 1200 ? 1200.0 : screenWidth;

    return Scaffold(
      backgroundColor: kBg,
      body: Center(
        child: ConstrainedBox(
          constraints:  BoxConstraints(maxWidth: maxContentWidth),
          child:  Padding(
            padding: EdgeInsets.fromLTRB(
              isMobile ? 8 : 24,
              isMobile ? 8 : 24,
              isMobile ? 8 :  24,
              isMobile ? 16 : 32,
            ),
            child:  SingleChildScrollView(
              child:  Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment:  CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Rapports et Analyse',
                              style: Theme.of(context).textTheme.headlineSmall ??
                                  const TextStyle(
                                    fontSize: 32,
                                    fontWeight:  FontWeight.w700,
                                    color:  kTextPrimary,
                                  ),
                            ),
                            const SizedBox(height: 6),
                            const Text(
                              'Aperçus et métriques de performance',
                              style: TextStyle(fontSize: 16, color: kTextSecondary),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        height: 48,
                        decoration: BoxDecoration(
                          color: kSurface,
                          border: Border.all(color: kBorder),
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.04),
                              blurRadius:  18,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: selectedRange,
                            items: const [
                              DropdownMenuItem(value: 'Today', child: Text('Aujourd\'hui')),
                              DropdownMenuItem(value: 'This Month', child: Text('Ce mois')),
                              DropdownMenuItem(value: 'This Quarter', child: Text('Ce trimestre')),
                              DropdownMenuItem(value: 'This Year', child: Text('Cette année')),
                              DropdownMenuItem(value: 'Last Year', child: Text('L\'année dernière')),
                            ],
                            onChanged: (v) {
                              if (v != null) {
                                _onDateRangeChanged(v);
                              }
                            },
                            icon:  const Icon(Icons.keyboard_arrow_down_rounded),
                            borderRadius: BorderRadius.circular(12),
                            style: const TextStyle(color: kTextPrimary, fontSize: 14, fontWeight: FontWeight.w600),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      BlocBuilder<DashboardBloc, DashboardState>(
                        builder: (context, state) {
                          return ElevatedButton. icon(
                            onPressed:  _isExporting || state is!  DashboardLoadSuccess ? null : () => _exportToPdf(state. metrics),
                            icon: _isExporting
                                ? const SizedBox(
                                    width: 16,
                                    height: 16,
                                    child:  CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation<Color>(kTextSecondary)),
                                  )
                                : const Icon(Icons.file_download_outlined, size: 20),
                            label: Text(_isExporting ? 'Export.. .' : 'Rapport d\'exportation'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: kSurface,
                              foregroundColor: kTextPrimary,
                              elevation: 0,
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                              minimumSize: const Size(0, 48),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                                side: const BorderSide(color: kBorder),
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  BlocBuilder<DashboardBloc, DashboardState>(
                    builder: (context, state) {
                      if (state is DashboardLoadInProgress) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      if (state is DashboardOperationFailure) {
                        return Center(child: Text('Erreur: ${state.message}', style: const TextStyle(color: Colors.red)));
                      }
                      if (state is DashboardLoadSuccess) {
                        final metrics = state.metrics;
                        return LayoutBuilder(
                          builder: (context, constraints) {
                            final isTight = constraints.maxWidth < 980;
                            return Wrap(
                              spacing: kGutter,
                              runSpacing: kGutter,
                              children: [
                                SizedBox(
                                  width: _cardWidth(constraints, isTight),
                                  child: MetricCard(
                                    color: kRevenueColor,
                                    icon: Icons.attach_money_rounded,
                                    trendingIcon: Icons.trending_up_rounded,
                                    title: 'Revenu total',
                                    value: '${metrics.totalRevenue.toStringAsFixed(0)} DA',
                                    subNote: '', // Empty string - no trend
                                  ),
                                ),
                                SizedBox(
                                  width: _cardWidth(constraints, isTight),
                                  child: MetricCard(
                                    color: kPatientsColor,
                                    icon: Icons.people_alt_rounded,
                                    trendingIcon: Icons.trending_up_rounded,
                                    title: 'Patients totaux',
                                    value:  '${metrics.totalPatients}',
                                    subNote:  '', // Empty string - no trend
                                  ),
                                ),
                                SizedBox(
                                  width: _cardWidth(constraints, isTight),
                                  child: MetricCard(
                                    color: kAppointmentsColor,
                                    icon: Icons.event_available_rounded,
                                    trendingIcon: Icons.trending_up_rounded,
                                    title: 'Rendez-vous',
                                    value:  '${metrics.completedAppointments}',
                                    subNote: '', // Empty string - no trend
                                  ),
                                ),
                                SizedBox(
                                  width: _cardWidth(constraints, isTight),
                                  child: MetricCard(
                                    color: kAvgRevColor,
                                    icon: Icons.bar_chart_rounded,
                                    trendingIcon: Icons. trending_up_rounded,
                                    title: 'Rév. moy/Patient',
                                    value: '${metrics.averageRevenuePerPatient.toStringAsFixed(0)} DA',
                                    subNote: '', // Empty string - no trend
                                  ),
                                ),
                              ],
                            );
                          },
                        );
                      }
                      return const SizedBox. shrink();
                    },
                  ),
                  const SizedBox(height: 18),
                  PillTabs(
                    items: const ['Chiffre d\'affaires', 'Patients', 'Traitements', 'Performance'],
                    currentIndex: currentTab,
                    onChanged: (i) => setState(() => currentTab = i),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    height:  isMobile ? screenHeight * 0.8 : (isTablet ? 540 : 600),
                    child: _buildTabBody(screenWidth, screenHeight),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  double _cardWidth(BoxConstraints c, bool isTight) {
    final max = c.maxWidth;
    if (max >= 1120) return (max - (kGutter * 3)) / 4;
    if (max >= 760) return (max - (kGutter * 2)) / 3;
    return (max - kGutter) / 2;
  }

  Widget _buildTabBody(double screenWidth, double screenHeight) {
    switch (currentTab) {
      case 0:
        return RevenuePanel(screenWidth: screenWidth, screenHeight:  screenHeight);
      case 1:
        return PatientsPanel(screenWidth: screenWidth, screenHeight: screenHeight);
      case 2:
        return TreatmentsPanel(screenWidth:  screenWidth, screenHeight: screenHeight);
      case 3:
        return PerformancePanel(screenWidth: screenWidth, screenHeight: screenHeight);
      default:
        return const SizedBox. shrink();
    }
  }

  Future<void> _exportToPdf(dynamic metrics) async {
    setState(() => _isExporting = true);

    try {
      final currentYear = DateTime.now().year;

      context.read<RevenueBloc>().add(LoadRevenueChart(year:  currentYear));
      context.read<PatientsBloc>().add(LoadPatientsChart(year: currentYear));
      context.read<TreatmentsBloc>().add(LoadTreatmentsChart());
      context.read<PerformanceBloc>().add(LoadPerformanceChart(year: currentYear));

      await Future.delayed(const Duration(milliseconds: 2000));

      final revenueState = context.read<RevenueBloc>().state;
      final patientsState = context. read<PatientsBloc>().state;
      final treatmentsState = context.read<TreatmentsBloc>().state;
      final performanceState = context.read<PerformanceBloc>().state;

      final revenueData = revenueState is RevenueLoadSuccess ? revenueState.chartData : null;
      final patientsData = patientsState is PatientsLoadSuccess ? patientsState.chartData : null;
      final treatmentsData = treatmentsState is TreatmentsLoadSuccess ? treatmentsState. chartData : null;
      final performanceData = performanceState is PerformanceLoadSuccess ? performanceState.chartData : null;

      await PdfExportService.generateDashboardReport(
        metrics: metrics,
        revenueData: revenueData,
        patientsData: patientsData,
        treatmentsData: treatmentsData,
        performanceData: performanceData,
        dateRange: _getFrenchDateRange(selectedRange),
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('✓ Rapport PDF enregistré avec succès! '), backgroundColor: Colors.green, duration: Duration(seconds: 3)),
        );
      }
    } catch (e) {
      print('PDF Export Error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur:  $e'), backgroundColor: Colors.red, duration: const Duration(seconds: 4)),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isExporting = false);
      }
    }
  }

  String _getFrenchDateRange(String range) {
    switch (range) {
      case 'Today':
        return 'Aujourd\'hui';
      case 'This Month':
        return 'Ce mois';
      case 'This Quarter':
        return 'Ce trimestre';
      case 'This Year':
        return 'Cette année';
      case 'Last Year':
        return 'L\'année dernière';
      default:
        return range;
    }
  }
}