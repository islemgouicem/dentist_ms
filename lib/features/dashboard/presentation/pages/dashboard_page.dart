 
import 'package:flutter/material.dart';
// fl_chart is used in panel files; imported there where needed
import 'package:flutter/gestures.dart';
import 'package:dentist_ms/core/constants/app_colors.dart';
import 'dashboard_constants.dart';
import 'panels/revenue_panel.dart';
import 'panels/patients_panel.dart';
import 'panels/treatments_panel.dart';
import 'panels/performance_panel.dart';
import 'widgets/metric_card.dart';
import 'widgets/pill_tabs.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  String selectedRange = 'This Year';
  int currentTab = 0;

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
          constraints: BoxConstraints(maxWidth: maxContentWidth),
          child: Padding(
            padding: EdgeInsets.fromLTRB(isMobile ? 8 : 24, isMobile ? 8 : 24, isMobile ? 8 : 24, isMobile ? 16 : 32),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Rapports et Analyse',
                              style: Theme.of(context).textTheme.headlineSmall ??
                                  const TextStyle(
                                    fontSize: 32,
                                    fontWeight: FontWeight.w700,
                                    color: kTextPrimary,
                                  ),
                            ),
                            const SizedBox(height: 6),
                            const Text(
                              'Aperçus et métriques de performance',
                              style: TextStyle(
                                fontSize: 16,
                                color: kTextSecondary,
                              ),
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
                              blurRadius: 18,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: selectedRange,
                            items: const [
                              DropdownMenuItem(
                                value: 'Today',
                                child: Text('Aujourd\'hui'),
                              ),
                              DropdownMenuItem(
                                value: 'This Month',
                                child: Text('Ce mois'),
                              ),
                              DropdownMenuItem(
                                value: 'This Quarter',
                                child: Text('Ce trimestre'),
                              ),
                              DropdownMenuItem(
                                value: 'This Year',
                                child: Text('Cette année'),
                              ),
                              DropdownMenuItem(
                                value: 'Last Year',
                                child: Text('L\'année dernière'),
                              ),
                            ],
                            onChanged: (v) => setState(() {
                              if (v != null) selectedRange = v;
                            }),
                            icon: const Icon(Icons.keyboard_arrow_down_rounded),
                            borderRadius: BorderRadius.circular(12),
                            style: const TextStyle(
                              color: kTextPrimary,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      ElevatedButton.icon(
                        onPressed: () {},
                        icon: const Icon(Icons.file_download_outlined, size: 20),
                        label: const Text('Rapport d\'exportation'),
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
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  LayoutBuilder(
                    builder: (context, constraints) {
                      final isTight = constraints.maxWidth < 980;
                      return Wrap(
                        spacing: kGutter,
                        runSpacing: kGutter,
                        children: [
                          SizedBox(
                            width: _cardWidth(constraints, isTight),
                            child: const MetricCard(
                              color: kRevenueColor,
                              icon: Icons.attach_money_rounded,
                              trendingIcon: Icons.trending_up_rounded,
                              title: 'Revenu total',
                              value: '\$634,000',
                              subNote: '+18% comparé à l\'an dernier',
                            ),
                          ),
                          SizedBox(
                            width: _cardWidth(constraints, isTight),
                            child: const MetricCard(
                              color: kPatientsColor,
                              icon: Icons.people_alt_rounded,
                              trendingIcon: Icons.trending_up_rounded,
                              title: 'Patients totaux',
                              value: '1,609',
                              subNote: '+12% comparé à l\'an dernier',
                            ),
                          ),
                          SizedBox(
                            width: _cardWidth(constraints, isTight),
                            child: const MetricCard(
                              color: kAppointmentsColor,
                              icon: Icons.event_available_rounded,
                              trendingIcon: Icons.trending_up_rounded,
                              title: 'Rendez-vous',
                              value: '2,847',
                              subNote: 'Taux de réussite de 94%',
                            ),
                          ),
                          SizedBox(
                            width: _cardWidth(constraints, isTight),
                            child: const MetricCard(
                              color: kAvgRevColor,
                              icon: Icons.bar_chart_rounded,
                              trendingIcon: Icons.trending_up_rounded,
                              title: 'Rév. moy/Patient',
                              value: '\$394',
                              subNote: '+8% comparé à l\'an dernier',
                            ),
                          ),
                        ],
                      );
                    },
                  ),

                  const SizedBox(height: 18),

                  PillTabs(
                    items: const [
                      'Chiffre d\'affaires',
                      'Patients',
                      'Traitements',
                      'Performance',
                    ],
                    currentIndex: currentTab,
                    onChanged: (i) => setState(() => currentTab = i),
                  ),

                  const SizedBox(height: 24),

                  SizedBox(
                    height: isMobile ? screenHeight * 0.8 : (isTablet ? 540 : 600),
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
        return RevenuePanel(screenWidth: screenWidth, screenHeight: screenHeight);
      case 1:
        return PatientsPanel(screenWidth: screenWidth, screenHeight: screenHeight);
      case 2:
        return TreatmentsPanel(screenWidth: screenWidth, screenHeight: screenHeight);
      case 3:
        return PerformancePanel(screenWidth: screenWidth, screenHeight: screenHeight);
      default:
        return const SizedBox.shrink();
    }
  }

}
