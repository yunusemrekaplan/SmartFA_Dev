import 'package:mobile/app/domain/models/request/report_request_models.dart';
import 'package:mobile/app/domain/models/response/report_response_models.dart';
import 'package:mobile/app/domain/models/response/quick_report_response_model.dart';
import 'package:mobile/app/domain/models/enums/report_format.dart';
import 'package:mobile/app/data/network/exceptions/app_exception.dart';
import 'package:mobile/app/utils/result.dart';

abstract class IReportRepository {
  // Kullanıcının raporlarını getir (paginated)
  Future<Result<List<ReportModel>, AppException>> getUserReports({
    ReportFilterModel? filter,
  });

  // Rapor detayını ID ile getir
  Future<Result<ReportModel, AppException>> getReportById(int reportId);

  // Yeni rapor oluştur
  Future<Result<ReportModel, AppException>> createReport(
    CreateReportRequestModel reportData,
  );

  // Raporu sil
  Future<Result<void, AppException>> deleteReport(int reportId);

  // Rapor export et
  Future<Result<String, AppException>> exportReport(
    int reportId,
    ReportFormat format,
  );

  // Hızlı rapor oluştur (backend QuickReport endpoint'i)
  Future<Result<QuickReportResponseModel, AppException>> generateQuickReport(
    QuickReportRequestModel requestData,
  );

  // Report türlerini getir (backend enum endpoint)
  Future<Result<Map<String, dynamic>, AppException>> getReportTypes();

  // Report periodlarını getir (backend enum endpoint)
  Future<Result<Map<String, dynamic>, AppException>> getReportPeriods();

  // Report formatlarını getir (backend enum endpoint)
  Future<Result<Map<String, dynamic>, AppException>> getReportFormats();
}
