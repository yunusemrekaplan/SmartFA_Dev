import 'package:dio/dio.dart';
import 'package:mobile/app/data/datasources/remote/report_remote_datasource.dart';
import 'package:mobile/app/domain/models/request/report_request_models.dart';
import 'package:mobile/app/domain/models/response/report_response_models.dart';
import 'package:mobile/app/domain/models/response/quick_report_response_model.dart';
import 'package:mobile/app/domain/models/enums/report_format.dart';
import 'package:mobile/app/data/network/exceptions/app_exception.dart';
import 'package:mobile/app/data/network/exceptions/network_exception.dart';
import 'package:mobile/app/data/network/exceptions/not_found_exception.dart';
import 'package:mobile/app/data/network/exceptions/unexpected_exception.dart';
import 'package:mobile/app/data/network/exceptions/validation_exception.dart';
import 'package:mobile/app/domain/repositories/report_repository.dart';
import 'package:mobile/app/utils/result.dart';

class ReportRepositoryImpl implements IReportRepository {
  final IReportRemoteDataSource _remoteDataSource;

  ReportRepositoryImpl(this._remoteDataSource);

  @override
  Future<Result<List<ReportModel>, AppException>> getUserReports({
    ReportFilterModel? filter,
  }) async {
    try {
      final reports = await _remoteDataSource.getUserReports(filter: filter);
      return Success(reports);
    } on DioException catch (e) {
      return Failure(NetworkException.fromDioError(e));
    } catch (e) {
      return Failure(UnexpectedException.fromException(e as Exception));
    }
  }

  @override
  Future<Result<ReportModel, AppException>> getReportById(int reportId) async {
    try {
      final report = await _remoteDataSource.getReportById(reportId);
      return Success(report);
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        return Failure(NotFoundException(
          message: 'Rapor bulunamadı.',
          resourceType: 'Report',
          resourceId: reportId.toString(),
        ));
      }
      return Failure(NetworkException.fromDioError(e));
    } catch (e) {
      return Failure(UnexpectedException.fromException(e as Exception));
    }
  }

  @override
  Future<Result<ReportModel, AppException>> createReport(
    CreateReportRequestModel reportData,
  ) async {
    try {
      final newReport = await _remoteDataSource.createReport(reportData);
      return Success(newReport);
    } on DioException catch (e) {
      if (e.response?.statusCode == 400 || e.response?.statusCode == 422) {
        return Failure(ValidationException.fromDioResponse(
          e.response?.data,
          defaultMessage: 'Rapor oluşturma bilgileri geçersiz.',
        ));
      }
      return Failure(NetworkException.fromDioError(e));
    } catch (e) {
      return Failure(UnexpectedException.fromException(e as Exception));
    }
  }

  @override
  Future<Result<void, AppException>> deleteReport(int reportId) async {
    try {
      await _remoteDataSource.deleteReport(reportId);
      return Success(null);
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        return Failure(NotFoundException(
          message: 'Silinecek rapor bulunamadı.',
          resourceType: 'Report',
          resourceId: reportId.toString(),
        ));
      }
      if (e.response?.statusCode == 400 || e.response?.statusCode == 422) {
        String message = 'Rapor silinemedi.';
        if (e.response?.data is Map && e.response?.data['message'] != null) {
          message = e.response?.data['message'];
        }
        return Failure(ValidationException(
          message: message,
          details: e.response?.data,
        ));
      }
      return Failure(NetworkException.fromDioError(e));
    } catch (e) {
      return Failure(UnexpectedException.fromException(e as Exception));
    }
  }

  @override
  Future<Result<String, AppException>> exportReport(
    int reportId,
    ReportFormat format,
  ) async {
    try {
      final filePath = await _remoteDataSource.exportReport(reportId, format);
      return Success(filePath);
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        return Failure(NotFoundException(
          message: 'Export edilecek rapor bulunamadı.',
          resourceType: 'Report',
          resourceId: reportId.toString(),
        ));
      }
      return Failure(NetworkException.fromDioError(e));
    } catch (e) {
      return Failure(UnexpectedException.fromException(e as Exception));
    }
  }

  @override
  Future<Result<QuickReportResponseModel, AppException>> generateQuickReport(
    QuickReportRequestModel requestData,
  ) async {
    try {
      final reportData =
          await _remoteDataSource.generateQuickReport(requestData);
      return Success(reportData);
    } on DioException catch (e) {
      if (e.response?.statusCode == 400 || e.response?.statusCode == 422) {
        return Failure(ValidationException.fromDioResponse(
          e.response?.data,
          defaultMessage: 'Hızlı rapor parametreleri geçersiz.',
        ));
      }
      return Failure(NetworkException.fromDioError(e));
    } catch (e) {
      return Failure(UnexpectedException.fromException(e as Exception));
    }
  }

  @override
  Future<Result<Map<String, dynamic>, AppException>> getReportTypes() async {
    try {
      final types = await _remoteDataSource.getReportTypes();
      return Success(types);
    } on DioException catch (e) {
      return Failure(NetworkException.fromDioError(e));
    } catch (e) {
      return Failure(UnexpectedException.fromException(e as Exception));
    }
  }

  @override
  Future<Result<Map<String, dynamic>, AppException>> getReportPeriods() async {
    try {
      final periods = await _remoteDataSource.getReportPeriods();
      return Success(periods);
    } on DioException catch (e) {
      return Failure(NetworkException.fromDioError(e));
    } catch (e) {
      return Failure(UnexpectedException.fromException(e as Exception));
    }
  }

  @override
  Future<Result<Map<String, dynamic>, AppException>> getReportFormats() async {
    try {
      final formats = await _remoteDataSource.getReportFormats();
      return Success(formats);
    } on DioException catch (e) {
      return Failure(NetworkException.fromDioError(e));
    } catch (e) {
      return Failure(UnexpectedException.fromException(e as Exception));
    }
  }
}
