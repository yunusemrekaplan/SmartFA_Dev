import 'package:dio/dio.dart';
import 'package:mobile/app/data/datasources/local/auth_local_datasource.dart';
import 'package:mobile/app/data/datasources/remote/auth_remote_datasource.dart';
import 'package:mobile/app/data/models/request/auth_request_models.dart';
import 'package:mobile/app/data/models/response/auth_response_model.dart';
import 'package:mobile/app/data/network/exceptions.dart';
import 'package:mobile/app/domain/repositories/auth_repository.dart';
import 'package:mobile/app/utils/result.dart';

class AuthRepositoryImpl implements IAuthRepository {
  final IAuthRemoteDataSource _remoteDataSource;
  final IAuthLocalDataSource _localDataSource; // Local DataSource eklendi

  // Constructor güncellendi
  AuthRepositoryImpl(this._remoteDataSource, this._localDataSource);

  @override
  Future<Result<AuthResponseModel, ApiException>> login(String email, String password) async {
    final requestModel = LoginRequestModel(email: email, password: password);
    try {
      final responseModel = await _remoteDataSource.login(requestModel);
      // Başarılı olursa tokenları sakla
      await _localDataSource.saveTokens(
        accessToken: responseModel.accessToken,
        refreshToken: responseModel.refreshToken,
      );
      return Success(responseModel); // Başarılı Result döndür
    } on DioException catch (e) {
      return Failure(ApiException.fromDioError(e)); // Dio hatasını ApiException'a çevir
    } catch (e) {
      // Diğer beklenmedik hatalar
      return Failure(ApiException.fromException(e as Exception));
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
      await _localDataSource.saveTokens(
        accessToken: responseModel.accessToken,
        refreshToken: responseModel.refreshToken,
      );
      return Success(responseModel);
    } on DioException catch (e) {
      return Failure(ApiException.fromDioError(e));
    } catch (e) {
      return Failure(ApiException.fromException(e as Exception));
    }
  }

  @override
  Future<Result<AuthResponseModel, ApiException>> refreshToken(String refreshToken) async {
    final requestModel = RefreshTokenRequestModel(refreshToken: refreshToken);
    try {
      final responseModel = await _remoteDataSource.refreshToken(requestModel);
      // Başarılı olursa yeni tokenları sakla
      await _localDataSource.saveTokens(
        accessToken: responseModel.accessToken,
        refreshToken: responseModel.refreshToken,
      );
      return Success(responseModel);
    } on DioException catch (e) {
      // Refresh token geçersizse veya başka bir API hatası varsa
      // Tokenları temizle ve hata döndür
      await _localDataSource.clearTokens(); // Hata durumunda tokenları temizle
      return Failure(ApiException.fromDioError(e));
    } catch (e) {
      await _localDataSource.clearTokens(); // Güvenlik için beklenmedik hatada da temizle
      return Failure(ApiException.fromException(e as Exception));
    }
  }

  @override
  Future<Result<void, ApiException>> revokeToken(String refreshToken) async {
    final requestModel = RefreshTokenRequestModel(refreshToken: refreshToken);
    try {
      await _remoteDataSource.revokeToken(requestModel);
      // Başarılı olursa yereldeki tokenları da temizle (Logout gibi)
      await _localDataSource.clearTokens();
      return Success(null); // Başarılı ama veri yok
    } on DioException catch (e) {
      // Token zaten geçersizse veya bulunamazsa da yereldekini temizleyebiliriz.
      if (e.response?.statusCode == 400 || e.response?.statusCode == 404) {
        await _localDataSource.clearTokens();
      }
      return Failure(ApiException.fromDioError(e));
    } catch (e) {
      await _localDataSource.clearTokens(); // Beklenmedik hatada da temizle
      return Failure(ApiException.fromException(e as Exception));
    }
  }

// Opsiyonel: isLoggedIn ve logout metotları eklenebilir
/*
  @override
  Future<bool> isLoggedIn() async {
    // Access veya Refresh token var mı diye kontrol et
    final accessToken = await _localDataSource.getAccessToken();
    // final refreshToken = await _localDataSource.getRefreshToken(); // Refresh token kontrolü de eklenebilir
    return accessToken != null && accessToken.isNotEmpty;
  }

  @override
  Future<Result<void, ApiException>> logout() async {
    // Yerel tokenları temizle ve API'ye revoke isteği gönder (opsiyonel)
    final refreshToken = await _localDataSource.getRefreshToken();
    await _localDataSource.clearTokens();
    if (refreshToken != null) {
      // API'deki revoke işleminin sonucunu çok önemsemeyebiliriz,
      // çünkü yerelden zaten sildik. Ama yine de çağırmak iyi olabilir.
      return await revokeToken(refreshToken);
    }
    return Result.success(null);
  }
  */
}
