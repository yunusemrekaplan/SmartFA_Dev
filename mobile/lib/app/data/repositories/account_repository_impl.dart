import 'package:dio/dio.dart';
import 'package:mobile/app/data/datasources/remote/account_remote_datasource.dart';
import 'package:mobile/app/data/models/request/account_request_models.dart';
import 'package:mobile/app/data/models/response/account_response_model.dart';
import 'package:mobile/app/data/network/exceptions.dart';
import 'package:mobile/app/domain/repositories/account_repository.dart';
import 'package:mobile/app/utils/result.dart';

class AccountRepositoryImpl implements IAccountRepository {
  final IAccountRemoteDataSource _remoteDataSource;

  // final IAccountLocalDataSource _localDataSource; // Opsiyonel: Caching vb. için

  AccountRepositoryImpl(this._remoteDataSource /*, this._localDataSource */);

  @override
  Future<Result<List<AccountModel>, ApiException>> getUserAccounts() async {
    try {
      final accounts = await _remoteDataSource.getUserAccounts();
      return Success(accounts);
    } on DioException catch (e) {
      return Failure(ApiException.fromDioError(e));
    } catch (e) {
      return Failure(ApiException.fromException(e as Exception));
    }
  }

  @override
  Future<Result<AccountModel, ApiException>> getAccountById(int accountId) async {
    try {
      final account = await _remoteDataSource.getAccountById(accountId);
      return Success(account);
    } on DioException catch (e) {
      // 404 Not Found durumunu özel olarak ele alabiliriz
      if (e.response?.statusCode == 404) {
        return Failure(ApiException(message: 'Hesap bulunamadı.', statusCode: 404));
      }
      return Failure(ApiException.fromDioError(e));
    } catch (e) {
      return Failure(ApiException.fromException(e as Exception));
    }
  }

  @override
  Future<Result<AccountModel, ApiException>> createAccount(
      CreateAccountRequestModel accountData) async {
    try {
      final newAccount = await _remoteDataSource.createAccount(accountData);
      return Success(newAccount);
    } on DioException catch (e) {
      return Failure(ApiException.fromDioError(e));
    } catch (e) {
      return Failure(ApiException.fromException(e as Exception));
    }
  }

  @override
  Future<Result<void, ApiException>> updateAccount(
      int accountId, UpdateAccountRequestModel accountData) async {
    try {
      await _remoteDataSource.updateAccount(accountId, accountData);
      return Success(null); // Başarılı ama veri yok
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        return Failure(ApiException(message: 'Güncellenecek hesap bulunamadı.', statusCode: 404));
      }
      return Failure(ApiException.fromDioError(e));
    } catch (e) {
      return Failure(ApiException.fromException(e as Exception));
    }
  }

  @override
  Future<Result<void, ApiException>> deleteAccount(int accountId) async {
    try {
      await _remoteDataSource.deleteAccount(accountId);
      return Success(null); // Başarılı ama veri yok
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        return Failure(ApiException(message: 'Silinecek hesap bulunamadı.', statusCode: 404));
      }
      // Backend'den gelen 400 Bad Request (örn: ilişkili işlem var) hatasını yakala
      if (e.response?.statusCode == 400) {
        return Failure(ApiException.fromDioError(e)); // Backend'in mesajını kullan
      }
      return Failure(ApiException.fromDioError(e));
    } catch (e) {
      return Failure(ApiException.fromException(e as Exception));
    }
  }
}
