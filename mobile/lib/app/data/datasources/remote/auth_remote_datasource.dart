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

  Future<AuthResponseModel> refreshToken(
      RefreshTokenRequestModel refreshRequest);

  Future<void> revokeToken(
      RefreshTokenRequestModel revokeRequest); // Genellikle bir şey döndürmez
}

class AuthRemoteDataSource implements IAuthRemoteDataSource {
  final DioClient _dioClient;

  AuthRemoteDataSource(this._dioClient); // DioClient'ı inject et

  @override
  Future<AuthResponseModel> login(LoginRequestModel loginRequest) async {
    try {
      print(
          '>>> AuthRemoteDataSource: Sending login request to endpoint: $_loginEndpoint');
      print('>>> AuthRemoteDataSource: Login data: ${loginRequest.toJson()}');

      final response = await _dioClient.post(
        _loginEndpoint,
        data: loginRequest.toJson(), // İstek modelini JSON'a çevir
      );

      print(
          '>>> AuthRemoteDataSource: Login response status: ${response.statusCode}');
      print('>>> AuthRemoteDataSource: Login response received');

      if (response.data == null) {
        throw Exception('Login response data is null');
      }

      // Yanıtı parse et ve kontrol et
      try {
        final authResponse = AuthResponseModel.fromJson(response.data);
        print(
            '>>> AuthRemoteDataSource: Access token received: ${authResponse.accessToken.substring(0, min(10, authResponse.accessToken.length))}...');
        return authResponse;
      } catch (parseError) {
        print(
            '>>> AuthRemoteDataSource: Error parsing login response: $parseError');
        print('>>> AuthRemoteDataSource: Response data: ${response.data}');
        rethrow;
      }
    } on DioException catch (e) {
      // Hata yönetimi (ErrorInterceptor ele alacak ama burada loglama/özel hata fırlatma yapılabilir)
      print('>>> AuthRemoteDataSource: Login DioException: ${e.message}');
      print('>>> AuthRemoteDataSource: Status code: ${e.response?.statusCode}');
      print('>>> AuthRemoteDataSource: Response data: ${e.response?.data}');
      rethrow; // Şimdilik tekrar fırlat
    } catch (e) {
      print('>>> AuthRemoteDataSource: Login Unexpected Error: $e');
      rethrow;
    }
  }

  @override
  Future<AuthResponseModel> register(
      RegisterRequestModel registerRequest) async {
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
  Future<AuthResponseModel> refreshToken(
      RefreshTokenRequestModel refreshRequest) async {
    try {
      print(
          '>>> AuthRemoteDataSource: Sending refresh token request to: $_refreshEndpoint');

      final response = await _dioClient.post(
        _refreshEndpoint,
        data: refreshRequest.toJson(),
      );

      print(
          '>>> AuthRemoteDataSource: Refresh token response received: ${response.statusCode}');
      return AuthResponseModel.fromJson(response.data);
    } on DioException catch (e) {
      print(
          '>>> AuthRemoteDataSource: Refresh Token DioException: ${e.message}');
      print('>>> AuthRemoteDataSource: Status code: ${e.response?.statusCode}');
      rethrow;
    } catch (e) {
      print('>>> AuthRemoteDataSource: Refresh Token Unexpected Error: $e');
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

  // Yararlı yardımcı metod
  int min(int a, int b) => a < b ? a : b;
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
