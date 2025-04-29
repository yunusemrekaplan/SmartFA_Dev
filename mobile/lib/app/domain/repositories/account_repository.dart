import 'package:mobile/app/data/models/request/account_request_models.dart';
import 'package:mobile/app/data/models/response/account_response_model.dart';
import 'package:mobile/app/data/network/exceptions.dart';
import 'package:mobile/app/utils/result.dart';

abstract class IAccountRepository {
  /// Kullanıcının tüm hesaplarını getirir.
  Future<Result<List<AccountModel>, ApiException>> getUserAccounts();

  /// Belirli bir hesabı ID ile getirir.
  Future<Result<AccountModel, ApiException>> getAccountById(int accountId);

  /// Yeni bir hesap oluşturur.
  Future<Result<AccountModel, ApiException>> createAccount(CreateAccountRequestModel accountData);

  /// Mevcut bir hesabı günceller.
  Future<Result<void, ApiException>> updateAccount(
      int accountId, UpdateAccountRequestModel accountData);

  /// Belirli bir hesabı siler (Soft Delete).
  Future<Result<void, ApiException>> deleteAccount(int accountId);
}
