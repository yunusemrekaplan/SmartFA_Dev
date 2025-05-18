import 'package:dio/dio.dart';
import 'package:mobile/app/data/datasources/remote/transaction_remote_datasource.dart';
import 'package:mobile/app/data/models/request/transaction_request_models.dart';
import 'package:mobile/app/data/models/response/transaction_response_model.dart';
import 'package:mobile/app/data/network/exceptions/app_exception.dart';
import 'package:mobile/app/data/network/exceptions/network_exception.dart';
import 'package:mobile/app/data/network/exceptions/not_found_exception.dart';
import 'package:mobile/app/data/network/exceptions/unexpected_exception.dart';
import 'package:mobile/app/data/network/exceptions/validation_exception.dart';
import 'package:mobile/app/domain/repositories/transaction_repository.dart';
import 'package:mobile/app/utils/result.dart';

class TransactionRepositoryImpl implements ITransactionRepository {
  final ITransactionRemoteDataSource _remoteDataSource;

  TransactionRepositoryImpl(this._remoteDataSource);

  @override
  Future<Result<List<TransactionModel>, AppException>> getUserTransactions(
      TransactionFilterDto filter) async {
    try {
      final transactions = await _remoteDataSource.getUserTransactions(filter);
      return Success(transactions);
    } on DioException catch (e) {
      return Failure(NetworkException.fromDioError(e));
    } catch (e) {
      return Failure(UnexpectedException.fromException(e as Exception));
    }
  }

  @override
  Future<Result<TransactionModel, AppException>> getTransactionById(int transactionId) async {
    try {
      final transaction = await _remoteDataSource.getTransactionById(transactionId);
      return Success(transaction);
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        return Failure(NotFoundException(
            message: 'İşlem bulunamadı.',
            resourceType: 'Transaction',
            resourceId: transactionId.toString()));
      }
      return Failure(NetworkException.fromDioError(e));
    } catch (e) {
      return Failure(UnexpectedException.fromException(e as Exception));
    }
  }

  @override
  Future<Result<TransactionModel, AppException>> createTransaction(
      CreateTransactionRequestModel transactionData) async {
    try {
      final newTransaction = await _remoteDataSource.createTransaction(transactionData);
      return Success(newTransaction);
    } on DioException catch (e) {
      // Validasyon hatalarını ele al
      if (e.response?.statusCode == 400) {
        final data = e.response?.data;
        if (data is Map<String, dynamic> && data.containsKey('errors')) {
          Map<String, String> fieldErrors = {};

          try {
            final errors = data['errors'] as Map<String, dynamic>;
            errors.forEach((key, value) {
              if (value is List && value.isNotEmpty) {
                fieldErrors[key] = value.first.toString();
              } else if (value is String) {
                fieldErrors[key] = value;
              }
            });

            return Failure(ValidationException(
                message: 'İşlem bilgileri geçersiz.', fieldErrors: fieldErrors));
          } catch (_) {}
        }
      }

      return Failure(NetworkException.fromDioError(e));
    } catch (e) {
      return Failure(UnexpectedException.fromException(e as Exception));
    }
  }

  @override
  Future<Result<void, AppException>> updateTransaction(
      int transactionId, UpdateTransactionRequestModel transactionData) async {
    try {
      await _remoteDataSource.updateTransaction(transactionId, transactionData);
      return Success(null);
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        return Failure(NotFoundException(
            message: 'Güncellenecek işlem bulunamadı.',
            resourceType: 'Transaction',
            resourceId: transactionId.toString()));
      }

      // Validasyon hatalarını ele al
      if (e.response?.statusCode == 400) {
        final data = e.response?.data;
        if (data is Map<String, dynamic> && data.containsKey('errors')) {
          Map<String, String> fieldErrors = {};

          try {
            final errors = data['errors'] as Map<String, dynamic>;
            errors.forEach((key, value) {
              if (value is List && value.isNotEmpty) {
                fieldErrors[key] = value.first.toString();
              } else if (value is String) {
                fieldErrors[key] = value;
              }
            });

            return Failure(ValidationException(
                message: 'İşlem güncelleme bilgileri geçersiz.', fieldErrors: fieldErrors));
          } catch (_) {}
        }
      }

      return Failure(NetworkException.fromDioError(e));
    } catch (e) {
      return Failure(UnexpectedException.fromException(e as Exception));
    }
  }

  @override
  Future<Result<void, AppException>> deleteTransaction(int transactionId) async {
    try {
      await _remoteDataSource.deleteTransaction(transactionId);
      return Success(null);
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        return Failure(NotFoundException(
            message: 'Silinecek işlem bulunamadı.',
            resourceType: 'Transaction',
            resourceId: transactionId.toString()));
      }
      return Failure(NetworkException.fromDioError(e));
    } catch (e) {
      return Failure(UnexpectedException.fromException(e as Exception));
    }
  }
}
