// API endpoint yolları (DebtsController altındaki alt kaynak)
import 'package:dio/dio.dart';
import 'package:mobile/app/data/models/request/debt_payment_request_models.dart';
import 'package:mobile/app/data/models/response/debt_payment_response_model.dart';
import 'package:mobile/app/data/network/dio_client.dart';

const String _debtsEndpoint = '/debts';

/// Borç ödemeleriyle ilgili API isteklerini yapan arayüz.
abstract class IDebtPaymentRemoteDataSource {
  Future<List<DebtPaymentModel>> getDebtPayments(int debtId);

  Future<DebtPaymentModel> addDebtPayment(CreateDebtPaymentRequestModel paymentData);
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
      return data.map((json) => DebtPaymentModel.fromJson(json as Map<String, dynamic>)).toList();
    } on DioException catch (e) {
      print('DebtPaymentRemoteDataSource GetDebtPayments Error: $e');
      rethrow;
    } catch (e) {
      print('DebtPaymentRemoteDataSource GetDebtPayments Unexpected Error: $e');
      throw Exception('Borç ödemeleri getirilirken beklenmedik bir hata oluştu.');
    }
  }

  @override
  Future<DebtPaymentModel> addDebtPayment(CreateDebtPaymentRequestModel paymentData) async {
    try {
      // debtId, paymentData içinden alınır ve endpoint oluşturulur
      final response = await _dioClient.post(
        '$_debtsEndpoint/${paymentData.debtId}/payments',
        data: paymentData.toJson(),
      );
      return DebtPaymentModel.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      print('DebtPaymentRemoteDataSource AddDebtPayment Error: $e');
      rethrow;
    } catch (e) {
      print('DebtPaymentRemoteDataSource AddDebtPayment Unexpected Error: $e');
      throw Exception('Borç ödemesi eklenirken beklenmedik bir hata oluştu.');
    }
  }
}
