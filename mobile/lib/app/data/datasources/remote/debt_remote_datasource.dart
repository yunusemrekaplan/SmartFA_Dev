// API endpoint yolları
import 'package:dio/dio.dart';
import 'package:mobile/app/data/models/request/debt_request_models.dart';
import 'package:mobile/app/data/models/response/debt_response_model.dart';
import 'package:mobile/app/data/network/dio_client.dart';

const String _debtsEndpoint = '/debts'; // Ana endpoint

/// Borçlarla ilgili API isteklerini yapan arayüz.
abstract class IDebtRemoteDataSource {
  Future<List<DebtModel>> getUserActiveDebts();

  Future<DebtModel> getDebtById(int debtId);

  Future<DebtModel> createDebt(CreateDebtRequestModel debtData);

  Future<void> updateDebt(int debtId, UpdateDebtRequestModel debtData);

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
      return data.map((json) => DebtModel.fromJson(json as Map<String, dynamic>)).toList();
    } on DioException catch (e) {
      print('DebtRemoteDataSource GetUserActiveDebts Error: $e');
      rethrow;
    } catch (e) {
      print('DebtRemoteDataSource GetUserActiveDebts Unexpected Error: $e');
      throw Exception('Aktif borçlar getirilirken beklenmedik bir hata oluştu.');
    }
  }

  @override
  Future<DebtModel> getDebtById(int debtId) async {
    try {
      final response = await _dioClient.get('$_debtsEndpoint/$debtId');
      return DebtModel.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      print('DebtRemoteDataSource GetDebtById Error: $e');
      rethrow;
    } catch (e) {
      print('DebtRemoteDataSource GetDebtById Unexpected Error: $e');
      throw Exception('Borç detayı getirilirken beklenmedik bir hata oluştu.');
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
    } on DioException catch (e) {
      print('DebtRemoteDataSource CreateDebt Error: $e');
      rethrow;
    } catch (e) {
      print('DebtRemoteDataSource CreateDebt Unexpected Error: $e');
      throw Exception('Borç oluşturulurken beklenmedik bir hata oluştu.');
    }
  }

  @override
  Future<void> updateDebt(int debtId, UpdateDebtRequestModel debtData) async {
    try {
      await _dioClient.put(
        '$_debtsEndpoint/$debtId',
        data: debtData.toJson(),
      );
    } on DioException catch (e) {
      print('DebtRemoteDataSource UpdateDebt Error: $e');
      rethrow;
    } catch (e) {
      print('DebtRemoteDataSource UpdateDebt Unexpected Error: $e');
      throw Exception('Borç güncellenirken beklenmedik bir hata oluştu.');
    }
  }

  @override
  Future<void> deleteDebt(int debtId) async {
    try {
      await _dioClient.delete('$_debtsEndpoint/$debtId');
    } on DioException catch (e) {
      print('DebtRemoteDataSource DeleteDebt Error: $e');
      rethrow;
    } catch (e) {
      print('DebtRemoteDataSource DeleteDebt Unexpected Error: $e');
      throw Exception('Borç silinirken beklenmedik bir hata oluştu.');
    }
  }
}
