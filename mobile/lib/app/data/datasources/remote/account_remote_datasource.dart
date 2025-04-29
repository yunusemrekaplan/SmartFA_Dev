// API endpoint yolları
import 'package:dio/dio.dart';
import 'package:mobile/app/data/models/request/account_request_models.dart';
import 'package:mobile/app/data/models/response/account_response_model.dart';
import 'package:mobile/app/data/network/dio_client.dart';

const String _accountsEndpoint = '/accounts'; // Ana endpoint

abstract class IAccountRemoteDataSource {
  Future<List<AccountModel>> getUserAccounts();

  Future<AccountModel> getAccountById(int accountId);

  Future<AccountModel> createAccount(CreateAccountRequestModel accountData);

  Future<void> updateAccount(int accountId, UpdateAccountRequestModel accountData);

  Future<void> deleteAccount(int accountId);
}

class AccountRemoteDataSource implements IAccountRemoteDataSource {
  final DioClient _dioClient;

  AccountRemoteDataSource(this._dioClient);

  @override
  Future<List<AccountModel>> getUserAccounts() async {
    try {
      final response = await _dioClient.get(_accountsEndpoint);
      // Yanıt listesini AccountModel listesine dönüştür
      final List<dynamic> data = response.data as List<dynamic>;
      return data.map((json) => AccountModel.fromJson(json as Map<String, dynamic>)).toList();
    } on DioException catch (e) {
      print('AccountRemoteDataSource GetUserAccounts Error: $e');
      // DioException'ı doğrudan fırlat, Repository katmanı ApiException'a çevirecek
      rethrow;
    } catch (e) {
      print('AccountRemoteDataSource GetUserAccounts Unexpected Error: $e');
      throw Exception('Hesaplar getirilirken beklenmedik bir hata oluştu.'); // Genel hata
    }
  }

  @override
  Future<AccountModel> getAccountById(int accountId) async {
    try {
      final response = await _dioClient.get('$_accountsEndpoint/$accountId');
      return AccountModel.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      print('AccountRemoteDataSource GetAccountById Error: $e');
      rethrow;
    } catch (e) {
      print('AccountRemoteDataSource GetAccountById Unexpected Error: $e');
      throw Exception('Hesap detayı getirilirken beklenmedik bir hata oluştu.');
    }
  }

  @override
  Future<AccountModel> createAccount(CreateAccountRequestModel accountData) async {
    try {
      final response = await _dioClient.post(
        _accountsEndpoint,
        data: accountData.toJson(),
      );
      // Yanıt (201 Created) genellikle oluşturulan kaynağı içerir
      return AccountModel.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      print('AccountRemoteDataSource CreateAccount Error: $e');
      rethrow;
    } catch (e) {
      print('AccountRemoteDataSource CreateAccount Unexpected Error: $e');
      throw Exception('Hesap oluşturulurken beklenmedik bir hata oluştu.');
    }
  }

  @override
  Future<void> updateAccount(int accountId, UpdateAccountRequestModel accountData) async {
    try {
      // Put genellikle 204 No Content döner
      await _dioClient.put(
        '$_accountsEndpoint/$accountId',
        data: accountData.toJson(),
      );
    } on DioException catch (e) {
      print('AccountRemoteDataSource UpdateAccount Error: $e');
      rethrow;
    } catch (e) {
      print('AccountRemoteDataSource UpdateAccount Unexpected Error: $e');
      throw Exception('Hesap güncellenirken beklenmedik bir hata oluştu.');
    }
  }

  @override
  Future<void> deleteAccount(int accountId) async {
    try {
      // Delete genellikle 204 No Content döner
      await _dioClient.delete('$_accountsEndpoint/$accountId');
    } on DioException catch (e) {
      print('AccountRemoteDataSource DeleteAccount Error: $e');
      rethrow;
    } catch (e) {
      print('AccountRemoteDataSource DeleteAccount Unexpected Error: $e');
      throw Exception('Hesap silinirken beklenmedik bir hata oluştu.');
    }
  }
}
