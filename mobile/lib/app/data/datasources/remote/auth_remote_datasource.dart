import 'package:dio/dio.dart';
import 'package:mobile/app/data/models/request/auth_request_models.dart';
import 'package:mobile/app/data/models/response/auth_response_model.dart';
import 'package:mobile/app/data/network/dio_client.dart';

// Auth API endpoint yolları
const String _loginEndpoint = '/auth/login';
const String _registerEndpoint = '/auth/register';
const String _refreshEndpoint = '/auth/refresh';
const String _revokeEndpoint = '/auth/revoke';

abstract class IAuthRemoteDataSource {
  Future<AuthResponseModel> login(LoginRequestModel loginRequest);

  Future<AuthResponseModel> register(RegisterRequestModel registerRequest);

  Future<AuthResponseModel> refreshToken(RefreshTokenRequestModel refreshRequest);

  Future<void> revokeToken(RefreshTokenRequestModel revokeRequest); // Genellikle bir şey döndürmez
}

class AuthRemoteDataSource implements IAuthRemoteDataSource {
  final DioClient _dioClient;

  AuthRemoteDataSource(this._dioClient); // DioClient'ı inject et

  @override
  Future<AuthResponseModel> login(LoginRequestModel loginRequest) async {
    try {
      final response = await _dioClient.post(
        _loginEndpoint,
        data: loginRequest.toJson(), // İstek modelini JSON'a çevir
      );

      // Yanıtı AuthResponseModel'e dönüştür
      return AuthResponseModel.fromJson(response.data);
    } on DioException catch (e) {
      // Hata yönetimi (ErrorInterceptor ele alacak ama burada loglama/özel hata fırlatma yapılabilir)
      print('AuthRemoteDataSource Login Error: $e');
      // İdealde, burada yakalanan DioException'ı daha anlamlı bir custom exception'a çevirebiliriz.
      // throw LoginException(message: e.message ?? 'Giriş sırasında hata.');
      rethrow; // Şimdilik tekrar fırlat
    } catch (e) {
      print('AuthRemoteDataSource Login Unexpected Error: $e');
      rethrow;
    }
  }

  @override
  Future<AuthResponseModel> register(RegisterRequestModel registerRequest) async {
    try {
      final response = await _dioClient.post(
        _registerEndpoint,
        data: registerRequest.toJson(),
      );
      return AuthResponseModel.fromJson(response.data);
    } on DioException catch (e) {
      print('AuthRemoteDataSource Register Error: $e');
      // throw RegisterException(message: e.message ?? 'Kayıt sırasında hata.');
      rethrow;
    } catch (e) {
      print('AuthRemoteDataSource Register Unexpected Error: $e');
      rethrow;
    }
  }

  @override
  Future<AuthResponseModel> refreshToken(RefreshTokenRequestModel refreshRequest) async {
    try {
      final response = await _dioClient.post(
        _refreshEndpoint,
        data: refreshRequest.toJson(),
      );
      return AuthResponseModel.fromJson(response.data);
    } on DioException catch (e) {
      print('AuthRemoteDataSource Refresh Error: $e');
      // throw RefreshTokenException(message: e.message ?? 'Token yenileme hatası.');
      rethrow;
    } catch (e) {
      print('AuthRemoteDataSource Refresh Unexpected Error: $e');
      rethrow;
    }
  }

  @override
  Future<void> revokeToken(RefreshTokenRequestModel revokeRequest) async {
    try {
      await _dioClient.post(
        _revokeEndpoint,
        data: revokeRequest.toJson(),
      );
      // Başarılı yanıt genellikle 204 No Content olur, bir şey döndürmeye gerek yok.
    } on DioException catch (e) {
      print('AuthRemoteDataSource Revoke Error: $e');
      // throw RevokeTokenException(message: e.message ?? 'Token iptal hatası.');
      rethrow;
    } catch (e) {
      print('AuthRemoteDataSource Revoke Unexpected Error: $e');
      rethrow;
    }
  }
}

// Opsiyonel: Özel Hata Sınıfları (lib/app/data/network/exceptions.dart)
// class ApiException implements Exception {
//   final String message;
//   ApiException({required this.message});
// }
// class LoginException extends ApiException { LoginException({required super.message}); }
// class RegisterException extends ApiException { RegisterException({required super.message}); }
// class RefreshTokenException extends ApiException { RefreshTokenException({required super.message}); }
// class RevokeTokenException extends ApiException { RevokeTokenException({required super.message}); }
