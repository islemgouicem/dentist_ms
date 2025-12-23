import 'dart:io';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:dentist_ms/features/dashboard/models/dashboard_metrics.dart';
import 'package:dentist_ms/features/dashboard/models/revenue_chart_data.dart';
import 'package:dentist_ms/features/dashboard/models/patients_chart_data.dart';
import 'package:dentist_ms/features/dashboard/models/treatments_chart_data.dart';
import 'package:dentist_ms/features/dashboard/models/performance_chart_data.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';

class PdfExportService {
  static Future<void> generateDashboardReport({
    required dynamic metrics,
    RevenueChartData? revenueData,
    PatientsChartData? patientsData,
    TreatmentsChartData? treatmentsData,
    PerformanceChartData? performanceData,
    required String dateRange,
  }) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw. MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(40),
        build: (context) {
          final List<pw.Widget> widgets = [];
          widgets.add(_buildHeader(dateRange));
          widgets.add(pw.SizedBox(height: 30));
          widgets.add(_buildMetricsSummary(metrics));
          widgets.add(pw.SizedBox(height: 30));
          if (revenueData != null) {
            widgets.add(_buildSectionTitle('Chiffre d\'Affaires'));
            widgets.add(pw.SizedBox(height: 15));
            widgets.add(_buildRevenueSection(revenueData));
            widgets.add(pw.SizedBox(height: 25));
          }
          if (patientsData != null) {
            widgets.add(_buildSectionTitle('Croissance des Patients'));
            widgets.add(pw.SizedBox(height: 15));
            widgets. add(_buildPatientsSection(patientsData));
            widgets.add(pw.SizedBox(height: 25));
          }
          if (treatmentsData != null) {
            widgets.add(_buildSectionTitle('Repartition des Traitements'));
            widgets.add(pw.SizedBox(height: 15));
            widgets.add(_buildTreatmentsSection(treatmentsData));
            widgets.add(pw.SizedBox(height: 25));
          }
          if (performanceData != null) {
            widgets.add(_buildSectionTitle('Performance des Rendez-vous'));
            widgets.add(pw.SizedBox(height: 15));
            widgets.add(_buildPerformanceSection(performanceData));
          }
          widgets.add(pw. Spacer());
          widgets.add(_buildFooter());

          return widgets;
        },
      ),
    );
    await _savePdfWindows(pdf);
  }

  static pw.Widget _buildHeader(String dateRange) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw. Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw. Text(
                  'Rapport d\'Analyse',
                  style: pw.TextStyle(
                    fontSize: 28,
                    fontWeight: pw.FontWeight.bold,
                    color: PdfColors.blue900,
                  ),
                ),
                pw.SizedBox(height: 4),
                pw.Text(
                  'Tableau de Bord Complet',
                  style: pw.TextStyle(
                    fontSize: 16,
                    color: PdfColors.grey700,
                  ),
                ),
              ],
            ),
            pw.Container(
              padding: const pw.EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: pw.BoxDecoration(
                color: PdfColors. blue100,
                borderRadius: pw. BorderRadius.circular(8),
              ),
              child: pw. Text(
                dateRange,
                style: pw.TextStyle(
                  fontSize: 14,
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColors.blue900,
                ),
              ),
            ),
          ],
        ),
        pw.SizedBox(height: 8),
        pw.Text(
          'Genere le:  ${_formatDateTime(DateTime.now())}',
          style: const pw.TextStyle(
            fontSize: 11,
            color: PdfColors.grey600,
          ),
        ),
        pw.SizedBox(height: 12),
        pw. Divider(thickness: 2, color: PdfColors.blue900),
      ],
    );
  }

  static pw.Widget _buildMetricsSummary(dynamic metrics) {
    return pw.Container(
      padding: const pw. EdgeInsets.all(20),
      decoration: pw.BoxDecoration(
        color: PdfColors.blue50,
        borderRadius: pw. BorderRadius.circular(8),
        border: pw.Border.all(color: PdfColors.blue200, width: 1.5),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            'Resume des Metriques Cles',
            style: pw. TextStyle(
              fontSize: 18,
              fontWeight: pw. FontWeight.bold,
              color: PdfColors.blue900,
            ),
          ),
          pw.SizedBox(height: 20),
          pw.Row(
            children: [
              pw.Expanded(
                child: _buildMetricCard(
                  'Revenu Total',
                  '${metrics. totalRevenue.toStringAsFixed(0)} DA',
                  PdfColors.green700,
                  PdfColors.green50,
                ),
              ),
              pw.SizedBox(width: 16),
              pw.Expanded(
                child: _buildMetricCard(
                  'Patients Totaux',
                  metrics.totalPatients.toString(),
                  PdfColors.blue700,
                  PdfColors. blue50,
                ),
              ),
            ],
          ),
          pw.SizedBox(height: 16),
          pw.Row(
            children: [
              pw. Expanded(
                child: _buildMetricCard(
                  'Rendez-vous Termines',
                  metrics.completedAppointments.toString(),
                  PdfColors.purple700,
                  PdfColors.purple50,
                ),
              ),
              pw.SizedBox(width: 16),
              pw.Expanded(
                child: _buildMetricCard(
                  'Rev. Moy/Patient',
                  '${metrics.averageRevenuePerPatient.toStringAsFixed(0)} DA',
                  PdfColors.orange700,
                  PdfColors.orange50,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  static pw.Widget _buildMetricCard(
    String label,
    String value,
    PdfColor valueColor,
    PdfColor bgColor,
  ) {
    return pw.Container(
      padding: const pw.EdgeInsets. all(12),
      decoration: pw.BoxDecoration(
        color: bgColor,
        borderRadius: pw.BorderRadius.circular(6),
        border: pw.Border.all(color: valueColor. shade(0.3)),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            label,
            style: const pw.TextStyle(
              fontSize: 10,
              color: PdfColors.grey700,
            ),
          ),
          pw.SizedBox(height: 6),
          pw.Text(
            value,
            style: pw.TextStyle(
              fontSize: 18,
              fontWeight: pw. FontWeight.bold,
              color: valueColor,
            ),
          ),
        ],
      ),
    );
  }

  static pw.Widget _buildSectionTitle(String title) {
    return pw.Container(
      padding: const pw. EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      decoration: pw.BoxDecoration(
        color: PdfColors.grey200,
        borderRadius: pw. BorderRadius.circular(4),
      ),
      child: pw.Text(
        title,
        style: pw.TextStyle(
          fontSize: 16,
          fontWeight: pw. FontWeight.bold,
          color: PdfColors.grey900,
        ),
      ),
    );
  }

  static pw.Widget _buildRevenueSection(RevenueChartData data) {
    final months = ['Jan', 'Fev', 'Mar', 'Avr', 'Mai', 'Jun', 'Jul', 'Aou', 'Sep', 'Oct', 'Nov', 'Dec'];
    final monthsWithData = data.monthlyData.where((m) => m.totalRevenue > 0 || m.netProfit != 0).toList();

    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw. Container(
          padding: const pw. EdgeInsets.all(12),
          decoration: pw.BoxDecoration(
            color: PdfColors.green50,
            borderRadius: pw.BorderRadius.circular(6),
          ),
          child: pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Text(
                'Revenu Total: ',
                style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold),
              ),
              pw.Text(
                '${data.monthlyData.fold<double>(0, (sum, m) => sum + m.totalRevenue).toStringAsFixed(0)} DA',
                style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold, color: PdfColors.green700),
              ),
            ],
          ),
        ),
        pw.SizedBox(height: 12),
        if (monthsWithData.isNotEmpty)
          pw.Table(
            border: pw.TableBorder.all(color: PdfColors.grey400),
            children: [
              pw.TableRow(
                decoration: const pw.BoxDecoration(color: PdfColors.grey300),
                children: [
                  _buildTableCell('Mois', isHeader: true),
                  _buildTableCell('Revenus', isHeader: true),
                  _buildTableCell('Benefices', isHeader: true),
                ],
              ),
              ...monthsWithData.map((monthData) {
                return pw.TableRow(
                  children: [
                    _buildTableCell(months[monthData.month - 1]),
                    _buildTableCell('${monthData.totalRevenue. toStringAsFixed(0)} DA'),
                    _buildTableCell(
                      '${monthData.netProfit.toStringAsFixed(0)} DA',
                      color: monthData.netProfit >= 0 ? PdfColors. green700 : PdfColors. red700,
                    ),
                  ],
                );
              }),
            ],
          ),
        if (data.topTreatments.isNotEmpty) ...[
          pw.SizedBox(height: 15),
          pw.Text(
            'Top 5 Traitements par Revenu: ',
            style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold),
          ),
          pw.SizedBox(height: 8),
          ... data.topTreatments. take(5).map((treatment) {
            return pw. Padding(
              padding: const pw.EdgeInsets.only(bottom: 6),
              child: pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw. Expanded(
                    child: pw.Text(
                      treatment. treatmentName,
                      style:  const pw.TextStyle(fontSize: 10),
                    ),
                  ),
                  pw.Text(
                    '${treatment.totalAmount.toStringAsFixed(0)} DA (${treatment.count}x)',
                    style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold),
                  ),
                ],
              ),
            );
          }),
        ],
      ],
    );
  }

  static pw.Widget _buildPatientsSection(PatientsChartData data) {
    final months = ['Jan', 'Fev', 'Mar', 'Avr', 'Mai', 'Jun', 'Jul', 'Aou', 'Sep', 'Oct', 'Nov', 'Dec'];
    final monthsWithData = data. monthlyData.where((m) => m.newPatients > 0).toList();

    return pw.Column(
      crossAxisAlignment:  pw.CrossAxisAlignment.start,
      children: [
        pw.Container(
          padding: const pw.EdgeInsets.all(12),
          decoration: pw. BoxDecoration(
            color:  PdfColors.blue50,
            borderRadius: pw.BorderRadius.circular(6),
          ),
          child: pw.Row(
            mainAxisAlignment: pw. MainAxisAlignment.spaceBetween,
            children: [
              pw.Text(
                'Total de Patients:',
                style:  pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold),
              ),
              pw.Text(
                '${data.maxPatientCount}',
                style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold, color: PdfColors.blue700),
              ),
            ],
          ),
        ),
        pw.SizedBox(height: 12),
        if (monthsWithData.isNotEmpty)
          pw.Table(
            border: pw.TableBorder. all(color: PdfColors. grey400),
            children: [
              pw.TableRow(
                decoration: const pw.BoxDecoration(color: PdfColors. grey300),
                children: [
                  _buildTableCell('Mois', isHeader: true),
                  _buildTableCell('Nouveaux', isHeader: true),
                  _buildTableCell('Cumulatif', isHeader: true),
                ],
              ),
              ...monthsWithData.map((monthData) {
                return pw.TableRow(
                  children: [
                    _buildTableCell(months[monthData.month - 1]),
                    _buildTableCell('+${monthData.newPatients}', color: PdfColors.green700),
                    _buildTableCell(monthData.cumulativeCount.toString()),
                  ],
                );
              }),
            ],
          ),
        pw.SizedBox(height: 10),
        pw.Text(
          'Total nouveaux patients: ${monthsWithData.fold<int>(0, (sum, m) => sum + m.newPatients)}',
          style: pw. TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold, color: PdfColors.blue700),
        ),
      ],
    );
  }

  static pw.Widget _buildTreatmentsSection(TreatmentsChartData data) {
    final treatmentsWithData = data.treatments.where((t) => t.count > 0).toList();

    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Container(
          padding: const pw.EdgeInsets.all(12),
          decoration: pw.BoxDecoration(
            color: PdfColors.orange50,
            borderRadius: pw.BorderRadius.circular(6),
          ),
          child: pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Text(
                'Total Traitements Effectues:',
                style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold),
              ),
              pw.Text(
                '${data.totalCount}',
                style: pw. TextStyle(fontSize: 14, fontWeight: pw.FontWeight. bold, color: PdfColors. orange700),
              ),
            ],
          ),
        ),
        pw.SizedBox(height: 12),
        if (treatmentsWithData.isNotEmpty)
          pw.Table(
            border: pw.TableBorder.all(color: PdfColors.grey400),
            children: [
              pw.TableRow(
                decoration: const pw. BoxDecoration(color: PdfColors.grey300),
                children: [
                  _buildTableCell('Traitement', isHeader: true),
                  _buildTableCell('Nombre', isHeader: true),
                  _buildTableCell('Pourcentage', isHeader: true),
                ],
              ),
              ...treatmentsWithData. map((treatment) {
                return pw.TableRow(
                  children: [
                    _buildTableCell(treatment.treatmentName),
                    _buildTableCell(treatment.count.toString()),
                    _buildTableCell('${treatment.percentage.toStringAsFixed(1)}%', color: PdfColors.orange700),
                  ],
                );
              }),
            ],
          ),
      ],
    );
  }

  static pw. Widget _buildPerformanceSection(PerformanceChartData data) {
    final months = ['Jan', 'Fev', 'Mar', 'Avr', 'Mai', 'Jun', 'Jul', 'Aou', 'Sep', 'Oct', 'Nov', 'Dec'];
    final monthsWithData = data.monthlyData.where((m) => m.totalCount > 0).toList();

    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Container(
          padding: const pw.EdgeInsets.all(12),
          decoration: pw.BoxDecoration(
            color: PdfColors. purple50,
            borderRadius:  pw.BorderRadius.circular(6),
          ),
          child: pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment. spaceBetween,
            children: [
              pw.Text(
                'Total Rendez-vous: ',
                style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold),
              ),
              pw.Text(
                '${data. totalAppointments}',
                style:  pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold, color: PdfColors.purple700),
              ),
            ],
          ),
        ),
        pw.SizedBox(height: 12),
        if (monthsWithData.isNotEmpty)
          pw.Table(
            border: pw.TableBorder.all(color: PdfColors.grey400),
            columnWidths: {
              0: const pw.FlexColumnWidth(2),
              1: const pw. FlexColumnWidth(1.5),
              2: const pw. FlexColumnWidth(1.5),
              3: const pw.FlexColumnWidth(1.5),
              4: const pw.FlexColumnWidth(1.5),
            },
            children: [
              pw.TableRow(
                decoration: const pw.BoxDecoration(color: PdfColors.grey300),
                children: [
                  _buildTableCell('Mois', isHeader: true),
                  _buildTableCell('Termine', isHeader: true),
                  _buildTableCell('Confirme', isHeader: true),
                  _buildTableCell('Annule', isHeader: true),
                  _buildTableCell('Absent', isHeader: true),
                ],
              ),
              ...monthsWithData.map((monthData) {
                return pw.TableRow(
                  children: [
                    _buildTableCell(months[monthData.month - 1]),
                    _buildTableCell('${monthData.completedPercentage.toStringAsFixed(0)}%', color: PdfColors.green700),
                    _buildTableCell('${monthData.confirmedPercentage.toStringAsFixed(0)}%', color: PdfColors.blue700),
                    _buildTableCell('${monthData.cancelledPercentage.toStringAsFixed(0)}%', color: PdfColors.orange700),
                    _buildTableCell('${monthData.noShowPercentage.toStringAsFixed(0)}%', color: PdfColors.red700),
                  ],
                );
              }),
            ],
          ),
        pw.SizedBox(height: 10),
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceAround,
          children:  [
            _buildLegendItem('Termine', PdfColors.green700),
            _buildLegendItem('Confirme', PdfColors.blue700),
            _buildLegendItem('Annule', PdfColors.orange700),
            _buildLegendItem('Absent', PdfColors.red700),
          ],
        ),
      ],
    );
  }

  static pw.Widget _buildLegendItem(String label, PdfColor color) {
    return pw.Row(
      mainAxisSize: pw.MainAxisSize.min,
      children: [
        pw.Container(
          width: 10,
          height: 10,
          decoration: pw.BoxDecoration(
            color: color,
            borderRadius: pw.BorderRadius.circular(2),
          ),
        ),
        pw.SizedBox(width: 4),
        pw.Text(
          label,
          style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey700),
        ),
      ],
    );
  }

  static pw.Widget _buildTableCell(String text, {bool isHeader = false, PdfColor?  color}) {
    return pw.Padding(
      padding: const pw.EdgeInsets.all(6),
      child: pw.Text(
        text,
        style: pw.TextStyle(
          fontSize: isHeader ? 10 : 9,
          fontWeight: isHeader ? pw.FontWeight.bold :  pw.FontWeight.normal,
          color: color,
        ),
      ),
    );
  }

  static pw.Widget _buildFooter() {
    return pw.Column(
      children: [
        pw. Divider(thickness: 1, color: PdfColors.grey400),
        pw.SizedBox(height: 8),
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children:  [
            pw.Text(
              'Systeme de Gestion Dentaire',
              style: pw. TextStyle(
                fontSize: 10,
                color: PdfColors.grey600,
                fontWeight: pw.FontWeight. bold,
              ),
            ),
            pw.Text(
              'Page 1',
              style: const pw.TextStyle(
                fontSize: 10,
                color:  PdfColors.grey600,
              ),
            ),
          ],
        ),
      ],
    );
  }

  static String _formatDateTime(DateTime dt) {
    final months = [
      'janvier', 'fevrier', 'mars', 'avril', 'mai', 'juin',
      'juillet', 'aout', 'septembre', 'octobre', 'novembre', 'decembre'
    ];
    return '${dt.day} ${months[dt.month - 1]} ${dt.year} a ${dt.hour. toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
  }

  static Future<void> _savePdfWindows(pw.Document pdf) async {
    try {
      final pdfBytes = await pdf.save();
      final defaultFileName = 'rapport_dashboard_${DateTime.now().millisecondsSinceEpoch}.pdf';

      String?  outputPath = await FilePicker.platform.saveFile(
        dialogTitle: 'Enregistrer le rapport PDF',
        fileName: defaultFileName,
        type: FileType.custom,
        allowedExtensions: ['pdf'],
      );

      if (outputPath != null) {
        if (! outputPath.toLowerCase().endsWith('.pdf')) {
          outputPath = '$outputPath.pdf';
        }

        final file = File(outputPath);
        await file.writeAsBytes(pdfBytes);
        
        print('PDF saved successfully to: $outputPath');
      } else {
        throw Exception('Enregistrement annule par l\'utilisateur');
      }
    } catch (e) {
      print('Error saving PDF: $e');
      rethrow;
    }
  }
}