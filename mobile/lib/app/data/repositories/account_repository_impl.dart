import 'package:dio/dio.dart';
import 'package:mobile/app/data/datasources/remote/account_remote_datasource.dart';
import 'package:mobile/app/data/models/request/account_request_models.dart';
import 'package:mobile/app/data/models/response/account_response_model.dart';
import 'package:mobile/app/domain/repositories/account_repository.dart';
import 'package:mobile/app/data/network/exceptions.dart'; // Yeni exception sınıflarını import et
import 'package:mobile/app/utils/result.dart';

class AccountRepositoryImpl implements IAccountRepository {
  final IAccountRemoteDataSource _remoteDataSource;

  // final IAccountLocalDataSource _localDataSource; // Opsiyonel: Caching vb. için

  AccountRepositoryImpl(this._remoteDataSource /*, this._localDataSource */);

  @override
  Future<Result<List<AccountModel>, AppException>> getUserAccounts() async {
    try {
      final accounts = await _remoteDataSource.getUserAccounts();
      return Success(accounts);
    } on DioException catch (e) {
      return Failure(NetworkException.fromDioError(e));
    } catch (e) {
      return Failure(UnexpectedException.fromException(e as Exception));
    }
  }

  @override
  Future<Result<AccountModel, AppException>> getAccountById(
      int accountId) async {
    try {
      final account = await _remoteDataSource.getAccountById(accountId);
      return Success(account);
    } on DioException catch (e) {
      // 404 Not Found durumunu özel olarak ele alabiliriz
      if (e.response?.statusCode == 404) {
        return Failure(NotFoundException(
            message: 'Hesap bulunamadı.',
            resourceType: 'Account',
            resourceId: accountId.toString()));
      }
      return Failure(NetworkException.fromDioError(e));
    } catch (e) {
      return Failure(UnexpectedException.fromException(e as Exception));
    }
  }

  @override
  Future<Result<AccountModel, AppException>> createAccount(
      CreateAccountRequestModel accountData) async {
    try {
      final newAccount = await _remoteDataSource.createAccount(accountData);
      return Success(newAccount);
    } on DioException catch (e) {
      // 400 Bad Request veya 422 Unprocessable Entity durumunda ValidationException
      if (e.response?.statusCode == 400 || e.response?.statusCode == 422) {
        return Failure(ValidationException.fromDioResponse(e.response?.data,
            defaultMessage: 'Hesap oluşturma bilgileri geçersiz.'));
      }
      return Failure(NetworkException.fromDioError(e));
    } catch (e) {
      return Failure(UnexpectedException.fromException(e as Exception));
    }
  }

  @override
  Future<Result<void, AppException>> updateAccount(
      int accountId, UpdateAccountRequestModel accountData) async {
    try {
      await _remoteDataSource.updateAccount(accountId, accountData);
      return Success(null); // Başarılı ama veri yok
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        return Failure(NotFoundException(
            message: 'Güncellenecek hesap bulunamadı.',
            resourceType: 'Account',
            resourceId: accountId.toString()));
      }
      // Validasyon hataları için
      if (e.response?.statusCode == 400 || e.response?.statusCode == 422) {
        return Failure(ValidationException.fromDioResponse(e.response?.data,
            defaultMessage: 'Hesap güncelleme bilgileri geçersiz.'));
      }
      return Failure(NetworkException.fromDioError(e));
    } catch (e) {
      return Failure(UnexpectedException.fromException(e as Exception));
    }
  }

  @override
  Future<Result<void, AppException>> deleteAccount(int accountId) async {
    try {
      await _remoteDataSource.deleteAccount(accountId);
      return Success(null); // Başarılı ama veri yok
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        return Failure(NotFoundException(
            message: 'Silinecek hesap bulunamadı.',
            resourceType: 'Account',
            resourceId: accountId.toString()));
      }
      // Backend'den gelen 400 Bad Request (örn: ilişkili işlem var) hatasını yakala
      if (e.response?.statusCode == 400 || e.response?.statusCode == 422) {
        // Sunucudan gelen özel mesajı kullan
        String message =
            'Hesap silinemedi. Hesaba ait işlemler bulunuyor olabilir.';
        if (e.response?.data is Map && e.response?.data['message'] != null) {
          message = e.response?.data['message'];
        }

        return Failure(
            ValidationException(message: message, details: e.response?.data));
      }
      return Failure(NetworkException.fromDioError(e));
    } catch (e) {
      return Failure(UnexpectedException.fromException(e as Exception));
    }
  }
}
