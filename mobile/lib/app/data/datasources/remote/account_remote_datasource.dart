// API endpoint yolları
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:mobile/app/domain/models/request/account_request_models.dart';
import 'package:mobile/app/domain/models/response/account_response_model.dart';
import 'package:mobile/app/data/network/dio_client.dart';
import 'package:mobile/app/data/network/exceptions/unexpected_exception.dart';

const String _accountsEndpoint = '/accounts'; // Ana endpoint

abstract class IAccountRemoteDataSource {
  /// Kullanıcının hesaplarını getirir
  Future<List<AccountModel>> getUserAccounts();

  /// ID ile belirli bir hesabı getirir
  Future<AccountModel> getAccountById(int accountId);

  /// Yeni hesap oluşturur
  Future<AccountModel> createAccount(CreateAccountRequestModel accountData);

  /// Varolan hesabı günceller
  Future<void> updateAccount(int accountId, UpdateAccountRequestModel accountData);

  /// Hesabı siler
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
    } on DioException {
      // DioException'ı ErrorInterceptor işleyecek
      rethrow;
    } catch (e) {
      _logError('GetUserAccounts', e);
      throw UnexpectedException(
        message: 'Hesaplar getirilirken beklenmedik bir hata oluştu',
        details: e,
      );
    }
  }

  @override
  Future<AccountModel> getAccountById(int accountId) async {
    try {
      final response = await _dioClient.get('$_accountsEndpoint/$accountId');
      return AccountModel.fromJson(response.data as Map<String, dynamic>);
    } on DioException {
      rethrow;
    } catch (e) {
      _logError('GetAccountById', e);
      throw UnexpectedException(
        message: 'Hesap detayı getirilirken beklenmedik bir hata oluştu',
        details: e,
      );
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
    } on DioException {
      rethrow;
    } catch (e) {
      _logError('CreateAccount', e);
      throw UnexpectedException(
        message: 'Hesap oluşturulurken beklenmedik bir hata oluştu',
        details: e,
      );
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
    } on DioException {
      rethrow;
    } catch (e) {
      _logError('UpdateAccount', e);
      throw UnexpectedException(
        message: 'Hesap güncellenirken beklenmedik bir hata oluştu',
        details: e,
      );
    }
  }

  @override
  Future<void> deleteAccount(int accountId) async {
    try {
      // Delete genellikle 204 No Content döner
      await _dioClient.delete('$_accountsEndpoint/$accountId');
    } on DioException {
      rethrow;
    } catch (e) {
      _logError('DeleteAccount', e);
      throw UnexpectedException(
        message: 'Hesap silinirken beklenmedik bir hata oluştu',
        details: e,
      );
    }
  }

  /// Debug modunda hata loglar
  void _logError(String operation, Object error) {
    if (kDebugMode) {
      print('AccountRemoteDataSource $operation Error: $error');
    }
  }
}
