import 'package:mobile/app/domain/models/request/account_request_models.dart';
import 'package:mobile/app/domain/models/response/account_response_model.dart';
import 'package:mobile/app/data/network/exceptions/app_exception.dart';
import 'package:mobile/app/utils/result.dart';

abstract class IAccountRepository {
  /// Kullanıcının tüm hesaplarını getirir.
  Future<Result<List<AccountModel>, AppException>> getUserAccounts();

  /// Belirli bir hesabı ID ile getirir.
  Future<Result<AccountModel, AppException>> getAccountById(int accountId);

  /// Yeni bir hesap oluşturur.
  Future<Result<AccountModel, AppException>> createAccount(
      CreateAccountRequestModel accountData);

  /// Mevcut bir hesabı günceller.
  Future<Result<void, AppException>> updateAccount(
      int accountId, UpdateAccountRequestModel accountData);

  /// Belirli bir hesabı siler (Soft Delete).
  Future<Result<void, AppException>> deleteAccount(int accountId);
}
