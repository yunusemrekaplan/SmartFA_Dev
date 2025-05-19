// API endpoint yolları (DebtsController altındaki alt kaynak)
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:mobile/app/domain/models/request/debt_payment_request_models.dart';
import 'package:mobile/app/domain/models/response/debt_payment_response_model.dart';
import 'package:mobile/app/data/network/dio_client.dart';
import 'package:mobile/app/data/network/exceptions/unexpected_exception.dart';

const String _debtsEndpoint = '/debts';

/// Borç ödemeleriyle ilgili API isteklerini yapan arayüz.
abstract class IDebtPaymentRemoteDataSource {
  /// Belirli bir borcun ödemelerini getirir
  Future<List<DebtPaymentModel>> getDebtPayments(int debtId);

  /// Borç ödemesi ekler
  Future<DebtPaymentModel> addDebtPayment(
      CreateDebtPaymentRequestModel paymentData);
}

/// IDebtPaymentRemoteDataSource arayüzünün Dio implementasyonu.
class DebtPaymentRemoteDataSource implements IDebtPaymentRemoteDataSource {
  final DioClient _dioClient;

  DebtPaymentRemoteDataSource(this._dioClient);

  @override
  Future<List<DebtPaymentModel>> getDebtPayments(int debtId) async {
    try {
      final response = await _dioClient.get('$_debtsEndpoint/$debtId/payments');
      final List<dynamic> data = response.data as List<dynamic>;
      return data
          .map(
              (json) => DebtPaymentModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } on DioException {
      // ErrorInterceptor tarafından işlenecek
      rethrow;
    } catch (e) {
      _logError('GetDebtPayments', e);
      throw UnexpectedException(
        message: 'Borç ödemeleri getirilirken beklenmedik bir hata oluştu',
        details: e,
      );
    }
  }

  @override
  Future<DebtPaymentModel> addDebtPayment(
      CreateDebtPaymentRequestModel paymentData) async {
    try {
      // debtId, paymentData içinden alınır ve endpoint oluşturulur
      final response = await _dioClient.post(
        '$_debtsEndpoint/${paymentData.debtId}/payments',
        data: paymentData.toJson(),
      );
      return DebtPaymentModel.fromJson(response.data as Map<String, dynamic>);
    } on DioException {
      rethrow;
    } catch (e) {
      _logError('AddDebtPayment', e);
      throw UnexpectedException(
        message: 'Borç ödemesi eklenirken beklenmedik bir hata oluştu',
        details: e,
      );
    }
  }

  /// Debug modunda hata loglar
  void _logError(String operation, Object error) {
    if (kDebugMode) {
      print('DebtPaymentRemoteDataSource $operation Error: $error');
    }
  }
}
