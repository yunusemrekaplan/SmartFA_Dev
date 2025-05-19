import 'package:dio/dio.dart';
import 'package:mobile/app/data/datasources/local/auth_local_datasource.dart';
import 'package:mobile/app/data/datasources/remote/auth_remote_datasource.dart';
import 'package:mobile/app/domain/models/request/auth_request_models.dart';
import 'package:mobile/app/domain/models/response/auth_response_model.dart';
import 'package:mobile/app/data/network/exceptions/app_exception.dart';
import 'package:mobile/app/data/network/exceptions/auth_exception.dart';
import 'package:mobile/app/data/network/exceptions/network_exception.dart';
import 'package:mobile/app/data/network/exceptions/unexpected_exception.dart';
import 'package:mobile/app/data/network/exceptions/validation_exception.dart';
import 'package:mobile/app/domain/repositories/auth_repository.dart';
import 'package:mobile/app/utils/result.dart';

class AuthRepositoryImpl implements IAuthRepository {
  final IAuthRemoteDataSource _remoteDataSource;
  final IAuthLocalDataSource _localDataSource; // Local DataSource eklendi

  // Constructor güncellendi
  AuthRepositoryImpl(this._remoteDataSource, this._localDataSource);

  @override
  Future<Result<AuthResponseModel, AppException>> login(
      String email, String password) async {
    print('>>> AuthRepository: Login attempt for email: $email');
    final requestModel = LoginRequestModel(email: email, password: password);
    try {
      print('>>> AuthRepository: Sending login request to remote data source');
      final responseModel = await _remoteDataSource.login(requestModel);
      print('>>> AuthRepository: Login successful, access token received');

      // Başarılı olursa tokenları sakla
      print('>>> AuthRepository: Saving tokens to secure storage');
      await _localDataSource.saveTokens(
        accessToken: responseModel.accessToken,
        refreshToken: responseModel.refreshToken,
      );
      print('>>> AuthRepository: Tokens saved successfully');

      return Success(responseModel); // Başarılı Result döndür
    } on DioException catch (e) {
      print('>>> AuthRepository: DioException during login: ${e.message}');
      print('>>> AuthRepository: Status code: ${e.response?.statusCode}');

      // Giriş yaparken kimlik doğrulama hatası
      if (e.response?.statusCode == 401 || e.response?.statusCode == 403) {
        // Sunucudan gelen mesaja bakarak, daha spesifik bir hata mesajı oluşturabilir
        String message;
        if (e.response?.data is Map && e.response?.data['message'] != null) {
          message = e.response?.data['message'];
        } else {
          message = 'Geçersiz e-posta veya şifre.';
        }

        return Failure(
            AuthException(message: message, code: 'INVALID_CREDENTIALS'));
      }

      // Validasyon hataları
      if (e.response?.statusCode == 400 || e.response?.statusCode == 422) {
        return Failure(ValidationException.fromDioResponse(e.response?.data,
            defaultMessage: 'Giriş bilgileri geçersiz.'));
      }

      // Diğer ağ hataları
      return Failure(NetworkException.fromDioError(e));
    } catch (e) {
      // Diğer beklenmedik hatalar
      print('>>> AuthRepository: Unexpected error during login: $e');
      return Failure(UnexpectedException.fromException(e as Exception));
    }
  }

  @override
  Future<Result<AuthResponseModel, AppException>> register(
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
      // Kayıt olurken validasyon hatası
      if (e.response?.statusCode == 400 || e.response?.statusCode == 422) {
        return Failure(ValidationException.fromDioResponse(e.response?.data,
            defaultMessage: 'Kayıt bilgileri geçersiz.'));
      }

      // E-posta zaten kullanılıyorsa
      if (e.response?.statusCode == 409) {
        String message = 'Bu e-posta adresi zaten kullanılıyor.';

        // Sunucudan gelen mesaja bakarak daha spesifik bir hata mesajı alabilir
        if (e.response?.data is Map && e.response?.data['message'] != null) {
          message = e.response?.data['message'];
        }

        return Failure(ValidationException(
            message: message, fieldErrors: {'email': message}));
      }

      return Failure(NetworkException.fromDioError(e));
    } catch (e) {
      return Failure(UnexpectedException.fromException(e as Exception));
    }
  }

  @override
  Future<Result<AuthResponseModel, AppException>> refreshToken(
      String refreshToken) async {
    final requestModel = RefreshTokenRequestModel(refreshToken: refreshToken);
    try {
      final responseModel = await _remoteDataSource.refreshToken(requestModel);
      // Başarılı olursa yeni tokenları sakla
      await _localDataSource.saveTokens(
        accessToken: responseModel.accessToken,
        refreshToken: responseModel.refreshToken,
      );
      return Success(responseModel);
    } on DioException {
      // Refresh token geçersizse veya başka bir API hatası varsa
      // Tokenları temizle ve hata döndür
      await _localDataSource.clearTokens(); // Hata durumunda tokenları temizle

      return Failure(AuthException(
          message: 'Oturum süresi doldu, lütfen tekrar giriş yapın.',
          isTokenExpired: true,
          code: 'TOKEN_EXPIRED'));
    } catch (e) {
      await _localDataSource
          .clearTokens(); // Güvenlik için beklenmedik hatada da temizle
      return Failure(UnexpectedException.fromException(e as Exception));
    }
  }

  @override
  Future<Result<void, AppException>> revokeToken(String refreshToken) async {
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
      return Failure(NetworkException.fromDioError(e));
    } catch (e) {
      await _localDataSource.clearTokens(); // Beklenmedik hatada da temizle
      return Failure(UnexpectedException.fromException(e as Exception));
    }
  }

  @override
  Future<bool> isLoggedIn() async {
    // Access token varlığını kontrol et
    final accessToken = await _localDataSource.getAccessToken();
    return accessToken != null && accessToken.isNotEmpty;
  }

  @override
  Future<Result<void, AppException>> logout() async {
    try {
      // Yerel tokenları temizle
      final refreshToken = await _localDataSource.getRefreshToken();

      // Eğer refresh token varsa API'de de geçersiz kıl
      if (refreshToken != null && refreshToken.isNotEmpty) {
        // API sonucunu çok önemsemiyoruz, yerel olarak çıkış yapıldı
        await _remoteDataSource
            .revokeToken(RefreshTokenRequestModel(refreshToken: refreshToken))
            .catchError((_) => null); // Hataları görmezden gel
      }

      await _localDataSource.clearTokens();

      // Başarılı sonuç döndür
      return Success(null);
    } catch (e) {
      await _localDataSource.clearTokens();

      // Hatayı sarmala ve döndür
      return Failure(UnexpectedException.fromException(e as Exception));
    }
  }
}
