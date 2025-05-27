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
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Icon(
            _getSectionIcon(title),
            color: AppColors.primary,
            size: 20,
          ),
          const SizedBox(width: 8),
          Text(
            title,
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey[800],
            ),
          ),
        ],
      ),
    );
  }

  IconData _getSectionIcon(String title) {
    switch (title.toLowerCase()) {
      case 'özet':
        return Icons.summarize_rounded;
      case 'grafikler':
        return Icons.insert_chart_rounded;
      case 'kategori analizi':
        return Icons.category_rounded;
      case 'bütçe performansı':
        return Icons.account_balance_wallet_rounded;
      case 'hesap özetleri':
        return Icons.account_balance_rounded;
      default:
        return Icons.analytics_rounded;
    }
  }

  Widget _buildSummaryCard(ReportSummaryModel summary) {
    final netAmount = summary.netAmount ?? 0;
    final isPositive = netAmount >= 0;
    final budgetUtilization = summary.budgetUtilization ?? 0;
    final isOverBudget = budgetUtilization > 100;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primary.withOpacity(0.8),
            AppColors.primary,
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 2,
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Net Durum',
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            color: Colors.white.withOpacity(0.9),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '₺${netAmount.abs().toStringAsFixed(2)}',
                          style: GoogleFonts.poppins(
                            fontSize: 24,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: (isPositive ? Colors.green : Colors.red)
                            .withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: (isPositive ? Colors.green : Colors.red)
                              .withOpacity(0.3),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            isPositive
                                ? Icons.trending_up_rounded
                                : Icons.trending_down_rounded,
                            color: Colors.white,
                            size: 18,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            isPositive ? 'Kâr' : 'Zarar',
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: _buildSummaryMetric(
                        'Gelir',
                        summary.totalIncome ?? 0,
                        Icons.arrow_upward_rounded,
                        Colors.green.shade300,
                      ),
                    ),
                    Container(
                      height: 40,
                      width: 1,
                      color: Colors.white.withOpacity(0.2),
                      margin: const EdgeInsets.symmetric(horizontal: 16),
                    ),
                    Expanded(
                      child: _buildSummaryMetric(
                        'Gider',
                        summary.totalExpense ?? 0,
                        Icons.arrow_downward_rounded,
                        Colors.red.shade300,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.pie_chart_rounded,
                                color: Colors.white.withOpacity(0.9),
                                size: 18,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Bütçe Kullanımı',
                                style: GoogleFonts.poppins(
                                  fontSize: 14,
                                  color: Colors.white.withOpacity(0.9),
                                ),
                              ),
                            ],
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: (isOverBudget ? Colors.red : Colors.green)
                                  .withOpacity(0.2),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              '%${budgetUtilization.toStringAsFixed(1)}',
                              style: GoogleFonts.poppins(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: budgetUtilization / 100,
                          backgroundColor: Colors.white.withOpacity(0.1),
                          valueColor: AlwaysStoppedAnimation<Color>(
                            isOverBudget
                                ? Colors.red.shade300
                                : Colors.green.shade300,
                          ),
                          minHeight: 6,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryMetric(
    String label,
    double amount,
    IconData icon,
    Color color,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: color.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                color: Colors.white,
                size: 16,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: Colors.white.withOpacity(0.9),
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          '₺${amount.toStringAsFixed(2)}',
          style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
      ],
    );
  }

  Widget _buildCategoryAnalysisCard(CategoryAnalysisModel analysis) {
    final color = analysis.categoryType == "Income"
        ? Colors.green.shade100
        : Colors.red.shade100;
    final textColor = analysis.categoryType == "Income"
        ? Colors.green.shade700
        : Colors.red.shade700;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: color.withOpacity(0.3),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        analysis.categoryName,
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey[800],
                        ),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '${analysis.transactionCount} İşlem',
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            color: textColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  '₺${analysis.amount.toStringAsFixed(2)}',
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: textColor,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Oran',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                    Text(
                      '%${analysis.percentage.toStringAsFixed(1)}',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: analysis.percentage / 100,
                    backgroundColor: color.withOpacity(0.3),
                    valueColor: AlwaysStoppedAnimation<Color>(textColor),
                    minHeight: 6,
                  ),
                ),
                if (analysis.budgetAmount != null) ...[
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Bütçe',
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                      Text(
                        '₺${analysis.budgetAmount!.toStringAsFixed(2)}',
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: Colors.grey[700],
                        ),
                      ),
                    ],
                  ),
                  if (analysis.budgetUtilization != null) ...[
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Kullanım',
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                        Text(
                          '%${analysis.budgetUtilization!.toStringAsFixed(1)}',
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: analysis.budgetUtilization! > 100
                                ? Colors.red.shade700
                                : Colors.green.shade700,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: analysis.budgetUtilization! / 100,
                        backgroundColor: Colors.grey[200],
                        valueColor: AlwaysStoppedAnimation<Color>(
                          analysis.budgetUtilization! > 100
                              ? Colors.red.shade700
                              : Colors.green.shade700,
                        ),
                        minHeight: 4,
                      ),
                    ),
                  ],
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBudgetPerformanceWrapperCard(
      BudgetPerformanceWrapperModel performance) {
    final utilizationPercentage = performance.utilizationPercentage ?? 0;
    final isOverBudget = utilizationPercentage > 100;
    final statusColor = isOverBudget ? AppColors.error : AppColors.success;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppColors.secondary.withOpacity(0.8),
                  AppColors.secondary,
                ],
              ),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Toplam Bütçe',
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            color: Colors.white.withOpacity(0.9),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '₺${(performance.totalBudget ?? 0).toStringAsFixed(2)}',
                          style: GoogleFonts.poppins(
                            fontSize: 24,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: statusColor.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: statusColor.withOpacity(0.3),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            isOverBudget
                                ? Icons.warning_rounded
                                : Icons.check_circle_rounded,
                            color: Colors.white,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '%${utilizationPercentage.toStringAsFixed(1)}',
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: LinearProgressIndicator(
                    value: utilizationPercentage / 100,
                    backgroundColor: Colors.white.withOpacity(0.2),
                    valueColor: AlwaysStoppedAnimation<Color>(statusColor),
                    minHeight: 8,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                _buildBudgetRow(
                  'Toplam Harcama',
                  performance.totalSpent ?? 0,
                  Icons.shopping_cart_rounded,
                  AppColors.error,
                  showProgress: true,
                  total: performance.totalBudget ?? 0,
                ),
                const SizedBox(height: 16),
                _buildBudgetRow(
                  'Kalan Bütçe',
                  performance.remaining ?? 0,
                  Icons.account_balance_wallet_rounded,
                  (performance.remaining ?? 0) >= 0
                      ? AppColors.success
                      : AppColors.error,
                  showProgress: true,
                  total: performance.totalBudget ?? 0,
                  isRemaining: true,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBudgetRow(
    String label,
    double amount,
    IconData icon,
    Color color, {
    bool showProgress = false,
    double total = 0,
    bool isRemaining = false,
  }) {
    final percentage = total != 0 ? (amount.abs() / total * 100) : 0.0;

    return Column(
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        label,
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                      Text(
                        '%${percentage.toStringAsFixed(1)}',
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: Colors.grey[500],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '₺${amount.abs().toStringAsFixed(2)}',
                        style: GoogleFonts.poppins(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: color,
                        ),
                      ),
                      if (isRemaining)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: color.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            amount >= 0 ? 'Kalan' : 'Aşım',
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: color,
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
        if (showProgress) ...[
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: percentage / 100,
              backgroundColor: Colors.grey[200],
              valueColor: AlwaysStoppedAnimation<Color>(
                color.withOpacity(0.5),
              ),
              minHeight: 4,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildAccountSummaryCard(AccountSummaryModel summary) {
    final isPositive = summary.currentBalance >= 0;
    final backgroundColor = isPositive
        ? Colors.green.withOpacity(0.1)
        : Colors.red.withOpacity(0.1);
    final textColor = isPositive ? Colors.green.shade700 : Colors.red.shade700;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: backgroundColor,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      summary.accountName,
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey[800],
                      ),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '${summary.transactionCount} İşlem',
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: textColor,
                        ),
                      ),
                    ),
                  ],
                ),
                Text(
                  '₺${summary.currentBalance.toStringAsFixed(2)}',
                  style: GoogleFonts.poppins(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: textColor,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _buildAccountDetailRow(
                  'Toplam Gelir',
                  summary.totalIncome,
                  Icons.arrow_upward_rounded,
                  Colors.green.shade700,
                ),
                const SizedBox(height: 12),
                _buildAccountDetailRow(
                  'Toplam Gider',
                  summary.totalExpense,
                  Icons.arrow_downward_rounded,
                  Colors.red.shade700,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAccountDetailRow(
      String label, double amount, IconData icon, Color color) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
              Text(
                '₺${amount.toStringAsFixed(2)}',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: color,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
