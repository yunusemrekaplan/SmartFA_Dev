import 'package:dio/dio.dart';
import 'package:mobile/app/data/datasources/remote/transaction_remote_datasource.dart';
import 'package:mobile/app/data/models/request/transaction_request_models.dart';
import 'package:mobile/app/data/models/response/transaction_response_model.dart';
import 'package:mobile/app/data/network/exceptions.dart';
import 'package:mobile/app/domain/repositories/transaction_repository.dart';
import 'package:mobile/app/utils/result.dart';

class TransactionRepositoryImpl implements ITransactionRepository {
  final ITransactionRemoteDataSource _remoteDataSource;

  TransactionRepositoryImpl(this._remoteDataSource);

  @override
  Future<Result<List<TransactionModel>, ApiException>> getUserTransactions(
      TransactionFilterDto filter) async {
    try {
      final transactions = await _remoteDataSource.getUserTransactions(filter);
      return Success(transactions);
    } on DioException catch (e) {
      return Failure(ApiException.fromDioError(e));
    } catch (e) {
      return Failure(ApiException.fromException(e as Exception));
    }
  }

  @override
  Future<Result<TransactionModel, ApiException>> getTransactionById(int transactionId) async {
    try {
      final transaction = await _remoteDataSource.getTransactionById(transactionId);
      return Success(transaction);
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        return Failure(ApiException(message: 'İşlem bulunamadı.', statusCode: 404));
      }
      return Failure(ApiException.fromDioError(e));
    } catch (e) {
      return Failure(ApiException.fromException(e as Exception));
    }
  }

  @override
  Future<Result<TransactionModel, ApiException>> createTransaction(
      CreateTransactionRequestModel transactionData) async {
    try {
      final newTransaction = await _remoteDataSource.createTransaction(transactionData);
      return Success(newTransaction);
    } on DioException catch (e) {
      return Failure(ApiException.fromDioError(e));
    } catch (e) {
      return Failure(ApiException.fromException(e as Exception));
    }
  }

  @override
  Future<Result<void, ApiException>> updateTransaction(
      int transactionId, UpdateTransactionRequestModel transactionData) async {
    try {
      await _remoteDataSource.updateTransaction(transactionId, transactionData);
      return Success(null);
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        return Failure(ApiException(message: 'Güncellenecek işlem bulunamadı.', statusCode: 404));
      }
      return Failure(ApiException.fromDioError(e));
    } catch (e) {
      return Failure(ApiException.fromException(e as Exception));
    }
  }

  @override
  Future<Result<void, ApiException>> deleteTransaction(int transactionId) async {
    try {
      await _remoteDataSource.deleteTransaction(transactionId);
      return Success(null);
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        return Failure(ApiException(message: 'Silinecek işlem bulunamadı.', statusCode: 404));
      }
      return Failure(ApiException.fromDioError(e));
    } catch (e) {
      return Failure(ApiException.fromException(e as Exception));
    }
  }
}
