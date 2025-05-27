import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../domain/models/response/report_response_models.dart';
import '../../../domain/models/response/quick_report_response_model.dart';
import '../../../domain/models/enums/report_type.dart';
import '../../../domain/models/enums/report_period.dart';
import '../../../widgets/custom_app_bar.dart';
import '../../../widgets/chart_widget.dart';
import '../../../theme/app_colors.dart';

class ReportDetailPage extends StatelessWidget {
  const ReportDetailPage({super.key});

  @override
  Widget build(BuildContext context) {
    final args = Get.arguments as Map<String, dynamic>;
    final isQuickReport = args['isQuickReport'] as bool? ?? false;
    final reportType = args['reportType'] as ReportType?;
    final period = args['period'] as ReportPeriod?;
    final reportData = args['reportData'] as QuickReportResponseModel?;

    return Scaffold(
      appBar: CustomAppBar(
        title: isQuickReport
            ? '${reportType?.displayName ?? 'Rapor'} (${period?.displayName ?? 'Dönem'})'
            : 'Rapor Detayı',
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Get.back(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.share_rounded),
            tooltip: 'Paylaş',
            onPressed: () {
              // TODO: Paylaşım fonksiyonu
              Get.snackbar(
                'Bilgi',
                'Paylaşım özelliği yakında eklenecek',
                snackPosition: SnackPosition.BOTTOM,
                backgroundColor: AppColors.info,
                colorText: Colors.white,
              );
            },
          ),
        ],
      ),
      body: reportData == null
          ? const Center(
              child: Text('Rapor verisi bulunamadı'),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Özet Bilgiler
                  _buildSectionTitle('Özet'),
                  _buildSummaryCard(reportData.summary),
                  const SizedBox(height: 24),

                  // Grafikler
                  if (reportData.charts.isNotEmpty) ...[
                    _buildSectionTitle('Grafikler'),
                    ...reportData.charts.map((chart) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            chart.title,
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: Colors.grey[700],
                            ),
                          ),
                          const SizedBox(height: 8),
                          ChartWidget(chart: chart),
                          const SizedBox(height: 24),
                        ],
                      );
                    }),
                  ],

                  // Kategori Analizi
                  if (reportData.categoryAnalysis != null &&
                      reportData.categoryAnalysis!.isNotEmpty) ...[
                    _buildSectionTitle('Kategori Analizi'),
                    ...reportData.categoryAnalysis!.map(
                        (category) => _buildCategoryAnalysisCard(category)),
                    const SizedBox(height: 24),
                  ],

                  // Bütçe Performansı
                  if (reportData.budgetPerformance != null) ...[
                    _buildSectionTitle('Bütçe Performansı'),
                    _buildBudgetPerformanceWrapperCard(
                        reportData.budgetPerformance!),
                    const SizedBox(height: 24),
                  ],

                  // Hesap Özetleri
                  if (reportData.accountSummaries != null &&
                      reportData.accountSummaries!.isNotEmpty) ...[
                    _buildSectionTitle('Hesap Özetleri'),
                    ...reportData.accountSummaries!
                        .map((account) => _buildAccountSummaryCard(account)),
                  ],
                ],
              ),
            ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: GoogleFonts.poppins(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: Colors.grey[800],
        ),
      ),
    );
  }

  Widget _buildSummaryCard(ReportSummaryModel summary) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildSummaryRow(
              'Toplam Gelir',
              summary.totalIncome ?? 0,
              Colors.green,
            ),
            const Divider(height: 24),
            _buildSummaryRow(
              'Toplam Gider',
              summary.totalExpense ?? 0,
              Colors.red,
            ),
            const Divider(height: 24),
            _buildSummaryRow(
              'Net Durum',
              summary.netAmount ?? 0,
              (summary.netAmount ?? 0) >= 0 ? Colors.green : Colors.red,
            ),
            const Divider(height: 24),
            _buildSummaryRow(
              'Bütçe Kullanımı',
              summary.budgetUtilization ?? 0,
              Colors.blue,
              isPercentage: true,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryAnalysisCard(CategoryAnalysisModel analysis) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildCategoryRow(
              analysis.categoryName,
              analysis.amount,
              analysis.percentage,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBudgetPerformanceWrapperCard(
      BudgetPerformanceWrapperModel performance) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildPerformanceRow(
              'Toplam Bütçe',
              performance.totalBudget ?? 0,
              Colors.blue,
            ),
            const Divider(height: 24),
            _buildPerformanceRow(
              'Toplam Harcama',
              performance.totalSpent ?? 0,
              Colors.orange,
            ),
            const Divider(height: 24),
            _buildPerformanceRow(
              'Kalan',
              performance.remaining ?? 0,
              (performance.remaining ?? 0) >= 0 ? Colors.green : Colors.red,
            ),
            const Divider(height: 24),
            _buildPerformanceRow(
              'Kullanım Oranı',
              performance.utilizationPercentage ?? 0,
              Colors.purple,
              isPercentage: true,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAccountSummaryCard(AccountSummaryModel summary) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildAccountRow(
              summary.accountName,
              summary.currentBalance,
              'Hesap',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryRow(String label, double amount, Color color,
      {bool isPercentage = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 14,
            color: Colors.grey[700],
          ),
        ),
        Text(
          isPercentage
              ? '%${amount.toStringAsFixed(1)}'
              : '₺${amount.toStringAsFixed(2)}',
          style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildCategoryRow(String name, double amount, double percentage) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              name,
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: Colors.grey[700],
              ),
            ),
            Text(
              '₺${amount.toStringAsFixed(2)}',
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.grey[800],
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        LinearProgressIndicator(
          value: percentage / 100,
          backgroundColor: Colors.grey[200],
          valueColor: AlwaysStoppedAnimation<Color>(
            AppColors.primary.withOpacity(0.8),
          ),
        ),
        const SizedBox(height: 2),
        Align(
          alignment: Alignment.centerRight,
          child: Text(
            '%${percentage.toStringAsFixed(1)}',
            style: GoogleFonts.poppins(
              fontSize: 12,
              color: Colors.grey[600],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPerformanceRow(String label, double amount, Color color,
      {bool isPercentage = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 14,
            color: Colors.grey[700],
          ),
        ),
        Text(
          isPercentage
              ? '%${amount.toStringAsFixed(1)}'
              : '₺${amount.toStringAsFixed(2)}',
          style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildAccountRow(String name, double balance, String type) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              name,
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: Colors.grey[700],
              ),
            ),
            Text(
              type,
              style: GoogleFonts.poppins(
                fontSize: 12,
                color: Colors.grey[500],
              ),
            ),
          ],
        ),
        Text(
          '₺${balance.toStringAsFixed(2)}',
          style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: balance >= 0 ? Colors.green : Colors.red,
          ),
        ),
      ],
    );
  }
}
