// API endpoint yolları
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:mobile/app/domain/models/request/debt_request_models.dart';
import 'package:mobile/app/domain/models/response/debt_response_model.dart';
import 'package:mobile/app/data/network/dio_client.dart';
import 'package:mobile/app/data/network/exceptions/unexpected_exception.dart';

const String _debtsEndpoint = '/debts'; // Ana endpoint

/// Borçlarla ilgili API isteklerini yapan arayüz.
abstract class IDebtRemoteDataSource {
  /// Kullanıcının aktif borçlarını getirir
  Future<List<DebtModel>> getUserActiveDebts();

  /// ID ile belirli bir borcu getirir
  Future<DebtModel> getDebtById(int debtId);

  /// Yeni borç oluşturur
  Future<DebtModel> createDebt(CreateDebtRequestModel debtData);

  /// Var olan borcu günceller
  Future<void> updateDebt(int debtId, UpdateDebtRequestModel debtData);

  /// Borcu siler
  Future<void> deleteDebt(int debtId);
}

/// IDebtRemoteDataSource arayüzünün Dio implementasyonu.
class DebtRemoteDataSource implements IDebtRemoteDataSource {
  final DioClient _dioClient;

  DebtRemoteDataSource(this._dioClient);

  @override
  Future<List<DebtModel>> getUserActiveDebts() async {
    try {
      // Backend'deki endpoint'e GET isteği (aktif borçları döndürür)
      final response = await _dioClient.get(_debtsEndpoint);
      final List<dynamic> data = response.data as List<dynamic>;
      return data
          .map((json) => DebtModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } on DioException {
      // ErrorInterceptor tarafından işlenecek
      rethrow;
    } catch (e) {
      _logError('GetUserActiveDebts', e);
      throw UnexpectedException(
        message: 'Aktif borçlar getirilirken beklenmedik bir hata oluştu',
        details: e,
      );
    }
  }

  @override
  Future<DebtModel> getDebtById(int debtId) async {
    try {
      final response = await _dioClient.get('$_debtsEndpoint/$debtId');
      return DebtModel.fromJson(response.data as Map<String, dynamic>);
    } on DioException {
      rethrow;
    } catch (e) {
      _logError('GetDebtById', e);
      throw UnexpectedException(
        message: 'Borç detayı getirilirken beklenmedik bir hata oluştu',
        details: e,
      );
    }
  }

  @override
  Future<DebtModel> createDebt(CreateDebtRequestModel debtData) async {
    try {
      final response = await _dioClient.post(
        _debtsEndpoint,
        data: debtData.toJson(),
      );
      return DebtModel.fromJson(response.data as Map<String, dynamic>);
    } on DioException {
      rethrow;
    } catch (e) {
      _logError('CreateDebt', e);
      throw UnexpectedException(
        message: 'Borç oluşturulurken beklenmedik bir hata oluştu',
        details: e,
      );
    }
  }

  @override
  Future<void> updateDebt(int debtId, UpdateDebtRequestModel debtData) async {
    try {
      await _dioClient.put(
        '$_debtsEndpoint/$debtId',
        data: debtData.toJson(),
      );
    } on DioException {
      rethrow;
    } catch (e) {
      _logError('UpdateDebt', e);
      throw UnexpectedException(
        message: 'Borç güncellenirken beklenmedik bir hata oluştu',
        details: e,
      );
    }
  }

  @override
  Future<void> deleteDebt(int debtId) async {
    try {
      await _dioClient.delete('$_debtsEndpoint/$debtId');
    } on DioException {
      rethrow;
    } catch (e) {
      _logError('DeleteDebt', e);
      throw UnexpectedException(
        message: 'Borç silinirken beklenmedik bir hata oluştu',
        details: e,
      );
    }
  }

  /// Debug modunda hata loglar
  void _logError(String operation, Object error) {
    if (kDebugMode) {
      print('DebtRemoteDataSource $operation Error: $error');
    }
  }
}
