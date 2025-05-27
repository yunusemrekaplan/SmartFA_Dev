import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../controllers/reports_controller.dart';
import '../widgets/quick_report_section.dart';
import '../widgets/report_card.dart';
import '../../../widgets/custom_app_bar.dart';
import '../../../widgets/empty_state_view.dart';
import '../../../theme/app_colors.dart';

class ReportsPage extends GetView<ReportsController> {
  const ReportsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: 'Raporlar',
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Get.back(),
        ),
        actions: [
          /*IconButton(
            icon: const Icon(Icons.filter_list_rounded),
            tooltip: 'Filtrele',
            onPressed: () {
              _showFilterDialog(context);
            },
          ),*/
        ],
      ),
      body: Obx(() {
        return Column(
          children: [
            // Hızlı Raporlar Bölümü - Her zaman görünür
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const QuickReportSection(),
                ],
              ),
            ),

            // Kayıtlı Raporlar Bölümü
            Expanded(
              child: controller.isLoading.value
                  ? const Center(
                      child: CircularProgressIndicator(),
                    )
                  : controller.reports.isEmpty
                      ? Center(
                          child: EmptyStateView(
                            title: 'Henüz Kayıtlı Rapor Yok',
                            message:
                                'Özel raporlar oluşturup kaydedebilirsiniz.',
                            icon: Icons.analytics_outlined,
                            onAction: () => _showCreateReportDialog(context),
                            actionText: 'Rapor Oluştur',
                            actionIcon: Icons.add_chart_rounded,
                          ),
                        )
                      : Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Kayıtlı Raporlar Başlığı
                              Row(
                                children: [
                                  Text(
                                    'Kayıtlı Raporlar',
                                    style: GoogleFonts.poppins(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.grey[800],
                                    ),
                                  ),
                                  const Spacer(),
                                  Text(
                                    '${controller.reports.length} rapor',
                                    style: GoogleFonts.poppins(
                                      fontSize: 14,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              // Raporlar Listesi
                              Expanded(
                                child: ListView.separated(
                                  itemCount: controller.reports.length,
                                  separatorBuilder: (context, index) =>
                                      const SizedBox(height: 12),
                                  itemBuilder: (context, index) {
                                    final report = controller.reports[index];
                                    return ReportCard(
                                      report: report,
                                      onTap: () =>
                                          controller.openReport(report.id),
                                      onDelete: () =>
                                          controller.deleteReport(report.id),
                                      onExport: (format) => controller
                                          .exportReport(report.id, format),
                                    );
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
            ),
          ],
        );
      }),
    );
  }

  void _showCreateReportDialog(BuildContext context) {
    // TODO: Create report dialog implementasyonu
    Get.snackbar(
      'Bilgi',
      'Özel rapor oluşturma özelliği yakında eklenecek',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: AppColors.info,
      colorText: Colors.white,
    );
  }
}
