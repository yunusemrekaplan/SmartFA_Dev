import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:mobile/app/domain/models/request/auth_request_models.dart';
import 'package:mobile/app/domain/models/response/auth_response_model.dart';
import 'package:mobile/app/data/network/dio_client.dart';
import 'package:mobile/app/data/network/exceptions/app_exception.dart';
import 'package:mobile/app/data/network/exceptions/unexpected_exception.dart';

// Auth API endpoint yolları
const String _loginEndpoint = '/auth/login';
const String _registerEndpoint = '/auth/register';
const String _refreshEndpoint = '/auth/refresh';
const String _revokeEndpoint = '/auth/revoke';

abstract class IAuthRemoteDataSource {
  /// Kullanıcı girişi yapar
  Future<AuthResponseModel> login(LoginRequestModel loginRequest);

  /// Yeni kullanıcı kaydı oluşturur
  Future<AuthResponseModel> register(RegisterRequestModel registerRequest);

  /// Access token yenilemek için refresh token kullanır
  Future<AuthResponseModel> refreshToken(
      RefreshTokenRequestModel refreshRequest);

  /// Refresh token'ı iptal eder (logout)
  Future<void> revokeToken(RefreshTokenRequestModel revokeRequest);
}

class AuthRemoteDataSource implements IAuthRemoteDataSource {
  final DioClient _dioClient;

  AuthRemoteDataSource(this._dioClient);

  @override
  Future<AuthResponseModel> login(LoginRequestModel loginRequest) async {
    try {
      _logDebug('Sending login request: ${loginRequest.email}');

      final response = await _dioClient.post(
        _loginEndpoint,
        data: loginRequest.toJson(),
      );

      _logDebug('Login response received');

      if (response.data == null) {
        throw UnexpectedException(message: 'Login yanıtı boş');
      }

      // Yanıtı parse et
      try {
        final authResponse = AuthResponseModel.fromJson(response.data);
        _logDebug('Access token received successfully');
        return authResponse;
      } catch (parseError) {
        _logError('Error parsing login response', parseError);
        throw UnexpectedException(
          message: 'Giriş yanıtı işlenirken hata oluştu',
          details: parseError,
        );
      }
    } on DioException {
      // Dio hataları interceptor tarafından işlenecek
      rethrow;
    } catch (e) {
      if (e is AppException) {
        // Zaten AppException fırlatılmışsa tekrar sarmalama
        rethrow;
      }
      _logError('Login unexpected error', e);
      throw UnexpectedException(
        message: 'Giriş yapılırken beklenmeyen bir hata oluştu',
        details: e,
      );
    }
  }

  @override
  Future<AuthResponseModel> register(
      RegisterRequestModel registerRequest) async {
    try {
      _logDebug('Sending register request');

      final response = await _dioClient.post(
        _registerEndpoint,
        data: registerRequest.toJson(),
      );

      _logDebug('Register response received');

      return AuthResponseModel.fromJson(response.data);
    } on DioException {
      rethrow;
    } catch (e) {
      _logError('Register unexpected error', e);
      throw UnexpectedException(
        message: 'Kayıt işlemi sırasında beklenmeyen bir hata oluştu',
        details: e,
      );
    }
  }

  @override
  Future<AuthResponseModel> refreshToken(
      RefreshTokenRequestModel refreshRequest) async {
    try {
      _logDebug('Sending refresh token request');

      final response = await _dioClient.post(
        _refreshEndpoint,
        data: refreshRequest.toJson(),
      );

      _logDebug('Refresh token response received');

      return AuthResponseModel.fromJson(response.data);
    } on DioException {
      rethrow;
    } catch (e) {
      _logError('Refresh token unexpected error', e);
      throw UnexpectedException(
        message: 'Token yenilenirken beklenmeyen bir hata oluştu',
        details: e,
      );
    }
  }

  @override
  Future<void> revokeToken(RefreshTokenRequestModel revokeRequest) async {
    try {
      _logDebug('Sending revoke token request');

      await _dioClient.post(
        _revokeEndpoint,
        data: revokeRequest.toJson(),
      );

      _logDebug('Token revoked successfully');
    } on DioException {
      rethrow;
    } catch (e) {
      _logError('Revoke token unexpected error', e);
      throw UnexpectedException(
        message: 'Token iptal edilirken beklenmeyen bir hata oluştu',
        details: e,
      );
    }
  }

  /// Debug modunda log çıktısı verir
  void _logDebug(String message) {
    if (kDebugMode) {
      print('>>> AuthRemoteDataSource: $message');
    }
  }

  /// Debug modunda hata log çıktısı verir
  void _logError(String operation, Object error) {
    if (kDebugMode) {
      print('>>> AuthRemoteDataSource ERROR [$operation]: $error');
    }
  }

  // Yardımcı metod
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
