import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../../domain/models/response/report_response_models.dart';
import '../../../domain/models/enums/report_type.dart';
import '../../../domain/models/enums/report_period.dart';
import '../../../domain/models/enums/report_format.dart';

class ReportCard extends StatelessWidget {
  final ReportModel report;
  final VoidCallback onTap;
  final VoidCallback onDelete;
  final Function(ReportFormat) onExport;

  const ReportCard({
    super.key,
    required this.report,
    required this.onTap,
    required this.onDelete,
    required this.onExport,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: _getTypeColor().withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      _getTypeIcon(),
                      color: _getTypeColor(),
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          report.title,
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey[800],
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          report.type.displayName,
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                  PopupMenuButton<String>(
                    onSelected: (value) {
                      switch (value) {
                        case 'export_pdf':
                          onExport(ReportFormat.PDF);
                          break;
                        case 'export_excel':
                          onExport(ReportFormat.Excel);
                          break;
                        case 'delete':
                          onDelete();
                          break;
                      }
                    },
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: 'export_pdf',
                        child: Row(
                          children: [
                            Icon(Icons.picture_as_pdf, size: 18),
                            SizedBox(width: 8),
                            Text('PDF olarak dışa aktar'),
                          ],
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'export_excel',
                        child: Row(
                          children: [
                            Icon(Icons.table_chart, size: 18),
                            SizedBox(width: 8),
                            Text('Excel olarak dışa aktar'),
                          ],
                        ),
                      ),
                      const PopupMenuDivider(),
                      const PopupMenuItem(
                        value: 'delete',
                        child: Row(
                          children: [
                            Icon(Icons.delete, size: 18, color: Colors.red),
                            SizedBox(width: 8),
                            Text('Sil', style: TextStyle(color: Colors.red)),
                          ],
                        ),
                      ),
                    ],
                    child: const Icon(
                      Icons.more_vert,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _buildInfoItem(
                      'Dönem',
                      report.period.displayName,
                      Icons.date_range,
                    ),
                  ),
                  Expanded(
                    child: _buildInfoItem(
                      'Oluşturulma',
                      DateFormat('dd.MM.yyyy').format(report.generatedAt),
                      Icons.schedule,
                    ),
                  ),
                ],
              ),
              if (report.description != null) ...[
                const SizedBox(height: 12),
                Text(
                  report.description!,
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoItem(String label, String value, IconData icon) {
    return Row(
      children: [
        Icon(
          icon,
          size: 16,
          color: Colors.grey[500],
        ),
        const SizedBox(width: 4),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: GoogleFonts.poppins(
                  fontSize: 10,
                  color: Colors.grey[500],
                ),
              ),
              Text(
                value,
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey[700],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Color _getTypeColor() {
    switch (report.type) {
      case ReportType.IncomeExpenseAnalysis:
        return const Color(0xFF4CAF50);
      case ReportType.BudgetPerformance:
        return const Color(0xFF2196F3);
      case ReportType.CategoryAnalysis:
        return const Color(0xFFFF9800);
      case ReportType.AccountSummary:
        return const Color(0xFF9C27B0);
      case ReportType.CashFlowAnalysis:
        return const Color(0xFF00BCD4);
      case ReportType.MonthlyFinancialSummary:
        return const Color(0xFF795548);
      case ReportType.YearlyFinancialSummary:
        return const Color(0xFF607D8B);
      case ReportType.CustomReport:
        return const Color(0xFF9E9E9E);
    }
  }

  IconData _getTypeIcon() {
    switch (report.type) {
      case ReportType.IncomeExpenseAnalysis:
        return Icons.trending_up;
      case ReportType.BudgetPerformance:
        return Icons.pie_chart;
      case ReportType.CategoryAnalysis:
        return Icons.category;
      case ReportType.AccountSummary:
        return Icons.account_balance_wallet;
      case ReportType.CashFlowAnalysis:
        return Icons.waterfall_chart;
      case ReportType.MonthlyFinancialSummary:
        return Icons.calendar_month;
      case ReportType.YearlyFinancialSummary:
        return Icons.date_range;
      case ReportType.CustomReport:
        return Icons.assessment;
    }
  }
}
