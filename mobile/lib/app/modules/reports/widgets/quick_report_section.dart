import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../controllers/reports_controller.dart';
import '../../../domain/models/enums/report_type.dart';
import '../../../domain/models/enums/report_period.dart';

class QuickReportSection extends GetView<ReportsController> {
  const QuickReportSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Hızlı Raporlar',
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.grey[800],
          ),
        ),
        const SizedBox(height: 16),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 1.2,
          children: [
            _buildQuickReportCard(
              title: 'Bu Ay\nGelir-Gider',
              icon: Icons.trending_up,
              color: const Color(0xFF4CAF50),
              onTap: () => controller.generateQuickReport(
                  ReportType.IncomeExpenseAnalysis, ReportPeriod.Monthly),
            ),
            _buildQuickReportCard(
              title: 'Bütçe\nPerformansı',
              icon: Icons.pie_chart,
              color: const Color(0xFF2196F3),
              onTap: () => controller.generateQuickReport(
                  ReportType.BudgetPerformance, ReportPeriod.Monthly),
            ),
            _buildQuickReportCard(
              title: 'Kategori\nAnalizi',
              icon: Icons.category,
              color: const Color(0xFFFF9800),
              onTap: () => controller.generateQuickReport(
                  ReportType.CategoryAnalysis, ReportPeriod.Monthly),
            ),
            _buildQuickReportCard(
              title: 'Hesap\nÖzeti',
              icon: Icons.account_balance_wallet,
              color: const Color(0xFF9C27B0),
              onTap: () => controller.generateQuickReport(
                  ReportType.AccountSummary, ReportPeriod.Monthly),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildQuickReportCard({
    required String title,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                color.withOpacity(0.1),
                color.withOpacity(0.05),
              ],
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: 24,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                title,
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[700],
                  height: 1.2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
