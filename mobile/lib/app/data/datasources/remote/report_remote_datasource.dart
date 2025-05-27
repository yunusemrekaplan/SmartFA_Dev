import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:mobile/app/domain/models/request/report_request_models.dart';
import 'package:mobile/app/domain/models/response/report_response_models.dart';
import 'package:mobile/app/domain/models/response/quick_report_response_model.dart';
import 'package:mobile/app/domain/models/enums/report_format.dart';
import 'package:mobile/app/data/network/dio_client.dart';
import 'package:mobile/app/data/network/exceptions/unexpected_exception.dart';

const String _reportsEndpoint = '/reports'; // Ana endpoint

abstract class IReportRemoteDataSource {
  /// Kullanıcının raporlarını getirir (paginated)
  Future<List<ReportModel>> getUserReports({
    ReportFilterModel? filter,
  });

  /// ID ile belirli bir raporu getirir
  Future<ReportModel> getReportById(int reportId);

  /// Yeni rapor oluşturur
  Future<ReportModel> createReport(CreateReportRequestModel reportData);

  /// Raporu siler
  Future<void> deleteReport(int reportId);

  /// Rapor export et
  Future<String> exportReport(int reportId, ReportFormat format);

  /// Hızlı rapor oluştur
  Future<QuickReportResponseModel> generateQuickReport(
      QuickReportRequestModel requestData);

  /// Report türlerini getir
  Future<Map<String, dynamic>> getReportTypes();

  /// Report periodlarını getir
  Future<Map<String, dynamic>> getReportPeriods();

  /// Report formatlarını getir
  Future<Map<String, dynamic>> getReportFormats();
}

class ReportRemoteDataSource implements IReportRemoteDataSource {
  final DioClient _dioClient;

  ReportRemoteDataSource(this._dioClient);

  @override
  Future<List<ReportModel>> getUserReports({ReportFilterModel? filter}) async {
    try {
      Map<String, dynamic>? queryParameters;
      if (filter != null) {
        queryParameters = filter.toQueryParameters();
      }

      final response = await _dioClient.get(
        _reportsEndpoint,
        queryParameters: queryParameters,
      );

      // Backend Result wrapper'ını handle et
      final Map<String, dynamic> responseData =
          response.data as Map<String, dynamic>;

      if (responseData['isSuccess'] == true) {
        final List<dynamic> data = responseData['value'] as List<dynamic>;
        return data
            .map((json) => ReportModel.fromJson(json as Map<String, dynamic>))
            .toList();
      } else {
        throw UnexpectedException(
          message: responseData['errors']?.join(', ') ??
              'Raporlar getirilirken hata oluştu',
        );
      }
    } on DioException {
      rethrow;
    } catch (e) {
      _logError('GetUserReports', e);
      throw UnexpectedException(
        message: 'Raporlar getirilirken beklenmedik bir hata oluştu',
        details: e,
      );
    }
  }

  @override
  Future<ReportModel> getReportById(int reportId) async {
    try {
      final response = await _dioClient.get('$_reportsEndpoint/$reportId');

      // Backend Result wrapper'ını handle et
      final Map<String, dynamic> responseData =
          response.data as Map<String, dynamic>;

      if (responseData['isSuccess'] == true) {
        return ReportModel.fromJson(
            responseData['value'] as Map<String, dynamic>);
      } else {
        throw UnexpectedException(
          message: responseData['errors']?.join(', ') ??
              'Rapor detayı getirilirken hata oluştu',
        );
      }
    } on DioException {
      rethrow;
    } catch (e) {
      _logError('GetReportById', e);
      throw UnexpectedException(
        message: 'Rapor detayı getirilirken beklenmedik bir hata oluştu',
        details: e,
      );
    }
  }

  @override
  Future<ReportModel> createReport(CreateReportRequestModel reportData) async {
    try {
      final response = await _dioClient.post(
        _reportsEndpoint,
        data: reportData.toJson(),
      );

      // Backend Result wrapper'ını handle et
      final Map<String, dynamic> responseData =
          response.data as Map<String, dynamic>;

      if (responseData['isSuccess'] == true) {
        return ReportModel.fromJson(
            responseData['value'] as Map<String, dynamic>);
      } else {
        throw UnexpectedException(
          message: responseData['errors']?.join(', ') ??
              'Rapor oluşturulurken hata oluştu',
        );
      }
    } on DioException {
      rethrow;
    } catch (e) {
      _logError('CreateReport', e);
      throw UnexpectedException(
        message: 'Rapor oluşturulurken beklenmedik bir hata oluştu',
        details: e,
      );
    }
  }

  @override
  Future<void> deleteReport(int reportId) async {
    try {
      final response = await _dioClient.delete('$_reportsEndpoint/$reportId');

      // Backend Result wrapper'ını handle et
      final Map<String, dynamic> responseData =
          response.data as Map<String, dynamic>;

      if (responseData['isSuccess'] != true) {
        throw UnexpectedException(
          message: responseData['errors']?.join(', ') ??
              'Rapor silinirken hata oluştu',
        );
      }
    } on DioException {
      rethrow;
    } catch (e) {
      _logError('DeleteReport', e);
      throw UnexpectedException(
        message: 'Rapor silinirken beklenmedik bir hata oluştu',
        details: e,
      );
    }
  }

  @override
  Future<String> exportReport(int reportId, ReportFormat format) async {
    try {
      final response = await _dioClient.get(
        '$_reportsEndpoint/$reportId/export',
        queryParameters: {
          'format': reportFormatToJson(format),
        },
      );
      // Backend'ten file path veya download URL döner
      return response.data as String;
    } on DioException {
      rethrow;
    } catch (e) {
      _logError('ExportReport', e);
      throw UnexpectedException(
        message: 'Rapor dışa aktarılırken beklenmedik bir hata oluştu',
        details: e,
      );
    }
  }

  @override
  Future<QuickReportResponseModel> generateQuickReport(
      QuickReportRequestModel requestData) async {
    try {
      final response = await _dioClient.get(
        '$_reportsEndpoint/quick',
        queryParameters: requestData.toQueryParameters(),
      );

      // Backend Result wrapper'ını handle et
      final Map<String, dynamic> responseData =
          response.data as Map<String, dynamic>;

      if (responseData['isSuccess'] == true) {
        return QuickReportResponseModel.fromJson(
            responseData['value'] as Map<String, dynamic>);
      } else {
        throw UnexpectedException(
          message: responseData['errors']?.join(', ') ??
              'Hızlı rapor oluşturulurken hata oluştu',
        );
      }
    } on DioException {
      rethrow;
    } catch (e) {
      _logError('GenerateQuickReport', e);
      throw UnexpectedException(
        message: 'Hızlı rapor oluşturulurken beklenmedik bir hata oluştu',
        details: e,
      );
    }
  }

  @override
  Future<Map<String, dynamic>> getReportTypes() async {
    try {
      final response = await _dioClient.get('$_reportsEndpoint/types');
      return response.data as Map<String, dynamic>;
    } on DioException {
      rethrow;
    } catch (e) {
      _logError('GetReportTypes', e);
      throw UnexpectedException(
        message: 'Rapor türleri getirilirken beklenmedik bir hata oluştu',
        details: e,
      );
    }
  }

  @override
  Future<Map<String, dynamic>> getReportPeriods() async {
    try {
      final response = await _dioClient.get('$_reportsEndpoint/periods');
      return response.data as Map<String, dynamic>;
    } on DioException {
      rethrow;
    } catch (e) {
      _logError('GetReportPeriods', e);
      throw UnexpectedException(
        message: 'Rapor dönemleri getirilirken beklenmedik bir hata oluştu',
        details: e,
      );
    }
  }

  @override
  Future<Map<String, dynamic>> getReportFormats() async {
    try {
      final response = await _dioClient.get('$_reportsEndpoint/formats');
      return response.data as Map<String, dynamic>;
    } on DioException {
      rethrow;
    } catch (e) {
      _logError('GetReportFormats', e);
      throw UnexpectedException(
        message: 'Rapor formatları getirilirken beklenmedik bir hata oluştu',
        details: e,
      );
    }
  }

  /// Debug modunda hata loglar
  void _logError(String operation, Object error) {
    if (kDebugMode) {
      print('ReportRemoteDataSource $operation Error: $error');
    }
  }
}
