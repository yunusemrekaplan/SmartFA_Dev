// API endpoint yolları
import 'package:dio/dio.dart';
import 'package:mobile/app/data/models/request/transaction_request_models.dart';
import 'package:mobile/app/data/models/response/transaction_response_model.dart';
import 'package:mobile/app/data/network/dio_client.dart';

const String _transactionsEndpoint = '/transactions'; // Ana endpoint

abstract class ITransactionRemoteDataSource {
  Future<List<TransactionModel>> getUserTransactions(TransactionFilterDto filter);

  Future<TransactionModel> getTransactionById(int transactionId);

  Future<TransactionModel> createTransaction(CreateTransactionRequestModel transactionData);

  Future<void> updateTransaction(int transactionId, UpdateTransactionRequestModel transactionData);

  Future<void> deleteTransaction(int transactionId);
}

class TransactionRemoteDataSource implements ITransactionRemoteDataSource {
  final DioClient _dioClient;

  TransactionRemoteDataSource(this._dioClient);

  @override
  Future<List<TransactionModel>> getUserTransactions(TransactionFilterDto filter) async {
    try {
      // Filtre DTO'sunu query parametrelerine çevir
      final queryParams = filter.toQueryParameters();
      final response = await _dioClient.get(
        _transactionsEndpoint,
        queryParameters: queryParams,
      );
      final List<dynamic> data = response.data as List<dynamic>;
      return data.map((json) => TransactionModel.fromJson(json as Map<String, dynamic>)).toList();
    } on DioException catch (e) {
      print('TransactionRemoteDataSource GetUserTransactions Error: $e');
      rethrow; // Repository katmanı ele alacak
    } catch (e) {
      print('TransactionRemoteDataSource GetUserTransactions Unexpected Error: $e');
      throw Exception('İşlemler getirilirken beklenmedik bir hata oluştu.');
    }
  }

  @override
  Future<TransactionModel> getTransactionById(int transactionId) async {
    try {
      final response = await _dioClient.get('$_transactionsEndpoint/$transactionId');
      return TransactionModel.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      print('TransactionRemoteDataSource GetTransactionById Error: $e');
      rethrow;
    } catch (e) {
      print('TransactionRemoteDataSource GetTransactionById Unexpected Error: $e');
      throw Exception('İşlem detayı getirilirken beklenmedik bir hata oluştu.');
    }
  }

  @override
  Future<TransactionModel> createTransaction(CreateTransactionRequestModel transactionData) async {
    try {
      final response = await _dioClient.post(
        _transactionsEndpoint,
        data: transactionData.toJson(),
      );
      return TransactionModel.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      print('TransactionRemoteDataSource CreateTransaction Error: $e');
      rethrow;
    } catch (e) {
      print('TransactionRemoteDataSource CreateTransaction Unexpected Error: $e');
      throw Exception('İşlem oluşturulurken beklenmedik bir hata oluştu.');
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
    } on DioException catch (e) {
      print('TransactionRemoteDataSource UpdateTransaction Error: $e');
      rethrow;
    } catch (e) {
      print('TransactionRemoteDataSource UpdateTransaction Unexpected Error: $e');
      throw Exception('İşlem güncellenirken beklenmedik bir hata oluştu.');
    }
  }

  @override
  Future<void> deleteTransaction(int transactionId) async {
    try {
      await _dioClient.delete('$_transactionsEndpoint/$transactionId');
    } on DioException catch (e) {
      print('TransactionRemoteDataSource DeleteTransaction Error: $e');
      rethrow;
    } catch (e) {
      print('TransactionRemoteDataSource DeleteTransaction Unexpected Error: $e');
      throw Exception('İşlem silinirken beklenmedik bir hata oluştu.');
    }
  }
}
