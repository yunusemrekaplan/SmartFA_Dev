import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../domain/models/response/report_response_models.dart';
import '../../../domain/models/request/report_request_models.dart';
import '../../../domain/models/enums/report_type.dart';
import '../../../domain/models/enums/report_period.dart';
import '../../../domain/models/enums/report_format.dart';
import '../../../domain/repositories/report_repository.dart';

class ReportsController extends GetxController {
  final IReportRepository _reportRepository;

  ReportsController(this._reportRepository);

  // Observable değişkenler
  final isLoading = false.obs;
  final reports = <ReportModel>[].obs;
  final summaryData = Rxn<FinancialSummaryModel>();

  // Filtreler
  final selectedReportType = Rxn<ReportType>();
  final selectedPeriod = Rxn<ReportPeriod>();
  final startDate = Rxn<DateTime>();
  final endDate = Rxn<DateTime>();

  @override
  void onInit() {
    super.onInit();
    loadReports();
    loadSummaryData();
  }

  // Raporları yükle
  Future<void> loadReports() async {
    try {
      isLoading.value = true;

      final filter = ReportFilterModel(
        type: selectedReportType.value,
        period: selectedPeriod.value,
        startDate: startDate.value,
        endDate: endDate.value,
      );

      final result = await _reportRepository.getUserReports(filter: filter);

      result.when(
        success: (reportList) {
          reports.value = reportList;
        },
        failure: (exception) {
          Get.snackbar(
            'Hata',
            'Raporlar yüklenirken bir hata oluştu: ${exception.message}',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.red,
            colorText: Colors.white,
          );
        },
      );
    } catch (e) {
      Get.snackbar(
        'Hata',
        'Beklenmedik bir hata oluştu: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // Özet verileri yükle
  Future<void> loadSummaryData() async {
    try {
      // TODO: Backend'te özet veriler için ayrı endpoint varsa burası kullanılacak
      // Şimdilik quick report ile mock data oluşturabiliriz
      summaryData.value = null;
    } catch (e) {
      print('Özet veriler yüklenirken hata: $e');
    }
  }

  // Raporları yenile
  Future<void> refreshReports() async {
    await Future.wait([
      loadReports(),
      loadSummaryData(),
    ]);
  }

  // Rapor aç
  void openReport(int reportId) {
    Get.toNamed('/reports/detail', arguments: {'reportId': reportId});
  }

  // Rapor sil
  Future<void> deleteReport(int reportId) async {
    try {
      final confirmed = await Get.dialog<bool>(
        AlertDialog(
          title: const Text('Raporu Sil'),
          content: const Text('Bu raporu silmek istediğinizden emin misiniz?'),
          actions: [
            TextButton(
              onPressed: () => Get.back(result: false),
              child: const Text('İptal'),
            ),
            ElevatedButton(
              onPressed: () => Get.back(result: true),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
              ),
              child: const Text('Sil'),
            ),
          ],
        ),
      );

      if (confirmed == true) {
        final result = await _reportRepository.deleteReport(reportId);

        result.when(
          success: (_) {
            reports.removeWhere((report) => report.id == reportId);
            Get.snackbar(
              'Başarılı',
              'Rapor başarıyla silindi',
              snackPosition: SnackPosition.BOTTOM,
              backgroundColor: Colors.green,
              colorText: Colors.white,
            );
          },
          failure: (exception) {
            Get.snackbar(
              'Hata',
              'Rapor silinirken bir hata oluştu: ${exception.message}',
              snackPosition: SnackPosition.BOTTOM,
              backgroundColor: Colors.red,
              colorText: Colors.white,
            );
          },
        );
      }
    } catch (e) {
      Get.snackbar(
        'Hata',
        'Beklenmedik bir hata oluştu: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  // Rapor dışa aktar
  Future<void> exportReport(int reportId, ReportFormat format) async {
    try {
      Get.snackbar(
        'Dışa Aktarılıyor',
        'Rapor ${format.displayName} formatında hazırlanıyor...',
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 2),
      );

      final result = await _reportRepository.exportReport(reportId, format);

      result.when(
        success: (filePath) {
          Get.snackbar(
            'Başarılı',
            'Rapor başarıyla dışa aktarıldı\nDosya: $filePath',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.green,
            colorText: Colors.white,
            duration: const Duration(seconds: 3),
          );
        },
        failure: (exception) {
          Get.snackbar(
            'Hata',
            'Rapor dışa aktarılırken bir hata oluştu: ${exception.message}',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.red,
            colorText: Colors.white,
          );
        },
      );
    } catch (e) {
      Get.snackbar(
        'Hata',
        'Beklenmedik bir hata oluştu: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  // Hızlı rapor oluştur
  Future<void> generateQuickReport(ReportType type, ReportPeriod period) async {
    try {
      isLoading.value = true;

      Get.snackbar(
        'Rapor Oluşturuluyor',
        '${type.displayName} raporu hazırlanıyor...',
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 2),
      );

      final requestData = QuickReportRequestModel(
        type: type,
        period: period,
        startDate: period == ReportPeriod.Custom ? startDate.value : null,
        endDate: period == ReportPeriod.Custom ? endDate.value : null,
      );

      final result = await _reportRepository.generateQuickReport(requestData);

      result.when(
        success: (reportData) {
          // Rapor detay sayfasına git
          Get.toNamed('/reports/detail', arguments: {
            'reportType': type,
            'period': period,
            'reportData': reportData,
            'isQuickReport': true,
          });
        },
        failure: (exception) {
          Get.snackbar(
            'Hata',
            'Rapor oluşturulurken bir hata oluştu: ${exception.message}',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.red,
            colorText: Colors.white,
          );
        },
      );
    } catch (e) {
      Get.snackbar(
        'Hata',
        'Beklenmedik bir hata oluştu: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // Özel rapor oluştur
  Future<void> createCustomReport({
    required String title,
    required ReportType type,
    required ReportPeriod period,
    DateTime? customStartDate,
    DateTime? customEndDate,
    String? description,
  }) async {
    try {
      isLoading.value = true;

      Get.snackbar(
        'Rapor Oluşturuluyor',
        'Özel rapor hazırlanıyor...',
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 2),
      );

      final requestData = CreateReportRequestModel(
        title: title,
        type: type,
        period: period,
        startDate: customStartDate,
        endDate: customEndDate,
        description: description,
        isScheduled: false,
      );

      final result = await _reportRepository.createReport(requestData);

      result.when(
        success: (newReport) {
          // Raporları yenile
          loadReports();

          Get.snackbar(
            'Başarılı',
            'Rapor başarıyla oluşturuldu',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.green,
            colorText: Colors.white,
          );
        },
        failure: (exception) {
          Get.snackbar(
            'Hata',
            'Rapor oluşturulurken bir hata oluştu: ${exception.message}',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.red,
            colorText: Colors.white,
          );
        },
      );
    } catch (e) {
      Get.snackbar(
        'Hata',
        'Beklenmedik bir hata oluştu: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // Filtreleri uygula
  void applyFilters({
    ReportType? reportType,
    ReportPeriod? period,
    DateTime? start,
    DateTime? end,
  }) {
    selectedReportType.value = reportType;
    selectedPeriod.value = period;
    startDate.value = start;
    endDate.value = end;

    loadReports(); // Filtrelenmiş raporları yükle
  }

  // Filtreleri temizle
  void clearFilters() {
    selectedReportType.value = null;
    selectedPeriod.value = null;
    startDate.value = null;
    endDate.value = null;

    loadReports();
  }
}
