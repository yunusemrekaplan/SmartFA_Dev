// API endpoint yolları
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:mobile/app/domain/models/request/transaction_request_models.dart';
import 'package:mobile/app/domain/models/response/transaction_response_model.dart';
import 'package:mobile/app/data/network/dio_client.dart';
import 'package:mobile/app/data/network/exceptions/unexpected_exception.dart';

const String _transactionsEndpoint = '/transactions'; // Ana endpoint

abstract class ITransactionRemoteDataSource {
  /// Kullanıcının işlemlerini filtreye göre getirir
  Future<List<TransactionModel>> getUserTransactions(
      TransactionFilterDto filter);

  /// ID ile belirli bir işlemi getirir
  Future<TransactionModel> getTransactionById(int transactionId);

  /// Yeni işlem oluşturur
  Future<TransactionModel> createTransaction(
      CreateTransactionRequestModel transactionData);

  /// Var olan işlemi günceller
  Future<void> updateTransaction(
      int transactionId, UpdateTransactionRequestModel transactionData);

  /// İşlemi siler
  Future<void> deleteTransaction(int transactionId);
}

class TransactionRemoteDataSource implements ITransactionRemoteDataSource {
  final DioClient _dioClient;

  TransactionRemoteDataSource(this._dioClient);

  @override
  Future<List<TransactionModel>> getUserTransactions(
      TransactionFilterDto filter) async {
    try {
      // Filtre DTO'sunu query parametrelerine çevir
      final queryParams = filter.toQueryParameters();
      final response = await _dioClient.get(
        _transactionsEndpoint,
        queryParameters: queryParams,
      );
      final List<dynamic> data = response.data as List<dynamic>;
      return data
          .map(
              (json) => TransactionModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } on DioException {
      // ErrorInterceptor tarafından işlenecek
      rethrow;
    } catch (e) {
      _logError('GetUserTransactions', e);
      throw UnexpectedException(
        message: 'İşlemler getirilirken beklenmedik bir hata oluştu',
        details: e,
      );
    }
  }

  @override
  Future<TransactionModel> getTransactionById(int transactionId) async {
    try {
      final response =
          await _dioClient.get('$_transactionsEndpoint/$transactionId');
      return TransactionModel.fromJson(response.data as Map<String, dynamic>);
    } on DioException {
      rethrow;
    } catch (e) {
      _logError('GetTransactionById', e);
      throw UnexpectedException(
        message: 'İşlem detayı getirilirken beklenmedik bir hata oluştu',
        details: e,
      );
    }
  }

  @override
  Future<TransactionModel> createTransaction(
      CreateTransactionRequestModel transactionData) async {
    try {
      final response = await _dioClient.post(
        _transactionsEndpoint,
        data: transactionData.toJson(),
      );
      return TransactionModel.fromJson(response.data as Map<String, dynamic>);
    } on DioException {
      rethrow;
    } catch (e) {
      _logError('CreateTransaction', e);
      throw UnexpectedException(
        message: 'İşlem oluşturulurken beklenmedik bir hata oluştu',
        details: e,
      );
    }
  }

  @override
  Future<void> updateTransaction(
      int transactionId, UpdateTransactionRequestModel transactionData) async {
    try {
      await _dioClient.put(
        '$_transactionsEndpoint/$transactionId',
        data: transactionData.toJson(),
      );
    } on DioException {
      rethrow;
    } catch (e) {
      _logError('UpdateTransaction', e);
      throw UnexpectedException(
        message: 'İşlem güncellenirken beklenmedik bir hata oluştu',
        details: e,
      );
    }
  }

  @override
  Future<void> deleteTransaction(int transactionId) async {
    try {
      await _dioClient.delete('$_transactionsEndpoint/$transactionId');
    } on DioException {
      rethrow;
    } catch (e) {
      _logError('DeleteTransaction', e);
      throw UnexpectedException(
        message: 'İşlem silinirken beklenmedik bir hata oluştu',
        details: e,
      );
    }
  }

  /// Debug modunda hata loglar
  void _logError(String operation, Object error) {
    if (kDebugMode) {
      print('TransactionRemoteDataSource $operation Error: $error');
    }
  }
}
