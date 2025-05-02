import 'package:mobile/app/data/models/request/transaction_request_models.dart';
import 'package:mobile/app/data/models/response/transaction_response_model.dart';
import 'package:mobile/app/utils/exceptions.dart';
import 'package:mobile/app/utils/result.dart';

abstract class ITransactionRepository {
  /// Kullanıcının işlemlerini filtreleyerek getirir.
  Future<Result<List<TransactionModel>, AppException>> getUserTransactions(
      TransactionFilterDto filter);

  /// Belirli bir işlemi ID ile getirir.
  Future<Result<TransactionModel, AppException>> getTransactionById(
      int transactionId);

  /// Yeni bir işlem oluşturur.
  Future<Result<TransactionModel, AppException>> createTransaction(
      CreateTransactionRequestModel transactionData);

  /// Mevcut bir işlemi günceller.
  Future<Result<void, AppException>> updateTransaction(
      int transactionId, UpdateTransactionRequestModel transactionData);

  /// Belirli bir işlemi siler (Soft Delete).
  Future<Result<void, AppException>> deleteTransaction(int transactionId);
}
