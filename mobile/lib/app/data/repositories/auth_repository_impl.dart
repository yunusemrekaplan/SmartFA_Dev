import 'package:dio/dio.dart';
import 'package:mobile/app/data/datasources/remote/auth_remote_datasource.dart';
import 'package:mobile/app/data/models/request/auth_request_models.dart';
import 'package:mobile/app/data/models/response/auth_response_model.dart';
import 'package:mobile/app/data/network/exceptions.dart';
import 'package:mobile/app/domain/repositories/auth_repository.dart';
import 'package:mobile/app/utils/result.dart';

class AuthRepositoryImpl implements IAuthRepository {
  final IAuthRemoteDataSource _remoteDataSource;

  // Token saklama için Local DataSource (daha sonra eklenecek)
  // final IAuthLocalDataSource _localDataSource;

  AuthRepositoryImpl(this._remoteDataSource /*, this._localDataSource */);

  @override
  Future<Result<AuthResponseModel, ApiException>> login(String email, String password) async {
    final requestModel = LoginRequestModel(email: email, password: password);
    try {
      final responseModel = await _remoteDataSource.login(requestModel);
      // Başarılı olursa tokenları sakla (local datasource ile)
      // await _localDataSource.saveTokens(responseModel.accessToken, responseModel.refreshToken);
      return Result.success(responseModel); // Başarılı Result döndür
    } on DioException catch (e) {
      return Result.failure(ApiException.fromDioError(e)); // Dio hatasını ApiException'a çevir
    } catch (e) {
      // Diğer beklenmedik hatalar
      return Result.failure(ApiException.fromException(e as Exception));
    }
  }

  @override
  Future<Result<AuthResponseModel, ApiException>> register(
      String email, String password, String confirmPassword) async {
    final requestModel = RegisterRequestModel(
      email: email,
      password: password,
      confirmPassword: confirmPassword,
    );
    try {
      final responseModel = await _remoteDataSource.register(requestModel);
      // Başarılı olursa tokenları sakla
      // await _localDataSource.saveTokens(responseModel.accessToken, responseModel.refreshToken);
      return Result.success(responseModel);
    } on DioException catch (e) {
      return Result.failure(ApiException.fromDioError(e));
    } catch (e) {
      return Result.failure(ApiException.fromException(e as Exception));
    }
  }

  @override
  Future<Result<AuthResponseModel, ApiException>> refreshToken(String refreshToken) async {
    final requestModel = RefreshTokenRequestModel(refreshToken: refreshToken);
    try {
      final responseModel = await _remoteDataSource.refreshToken(requestModel);
      // Başarılı olursa yeni tokenları sakla
      // await _localDataSource.saveTokens(responseModel.accessToken, responseModel.refreshToken);
      return Result.success(responseModel);
    } on DioException catch (e) {
      // Refresh token geçersizse veya başka bir API hatası varsa
      // Tokenları temizle ve hata döndür
      // await _localDataSource.clearTokens();
      return Result.failure(ApiException.fromDioError(e));
    } catch (e) {
      // await _localDataSource.clearTokens(); // Güvenlik için
      return Result.failure(ApiException.fromException(e as Exception));
    }
  }

  @override
  Future<Result<void, ApiException>> revokeToken(String refreshToken) async {
    final requestModel = RefreshTokenRequestModel(refreshToken: refreshToken);
    try {
      await _remoteDataSource.revokeToken(requestModel);
      // Başarılı olursa yereldeki tokenları da temizle
      // await _localDataSource.clearTokens();
      return Result.success(null); // Başarılı ama veri yok
    } on DioException catch (e) {
      return Result.failure(ApiException.fromDioError(e));
    } catch (e) {
      return Result.failure(ApiException.fromException(e as Exception));
    }
  }

// Diğer metotlar (isLoggedIn, logout) buraya eklenebilir ve localDataSource'u kullanabilir.
}
