import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart' hide Response;
import 'package:mobile/app/data/network/exceptions/app_exception.dart';
import 'package:mobile/app/data/network/exceptions/auth_exception.dart';
import 'package:mobile/app/data/network/exceptions/network_exception.dart';
import 'package:mobile/app/data/network/exceptions/not_found_exception.dart';
import 'package:mobile/app/data/network/exceptions/validation_exception.dart';
import 'package:mobile/app/navigation/app_routes.dart';
import 'package:flutter/foundation.dart' show kDebugMode;
import 'dart:async';

// Token'ları saklamak için kullanılacak key'ler
const String _accessTokenKey = 'accessToken';
const String _refreshTokenKey = 'refreshToken';
const String _refreshEndpoint =
    '/auth/refresh'; // Backend'deki refresh endpoint yolu

/// API isteklerindeki hataları yakalayıp işleyen Dio interceptor.
/// Token yenileme mantığını ve hata tipine göre uygun exception'ları oluşturur.
class ErrorInterceptor extends Interceptor {
  final Dio _dio; // Token yenileme isteği için Dio instance'ı
  late final FlutterSecureStorage _secureStorage;

  // Token yenileme işlemi sırasında diğer istekleri kilitlemek için
  bool _isRefreshing = false;
  Completer<String?>? _refreshCompleter;
  final List<_PendingRequest> _pendingRequests = [];

  ErrorInterceptor(this._dio) {
    try {
      _secureStorage = Get.find<FlutterSecureStorage>();
      _logDebug('FlutterSecureStorage injected from GetX');
    } catch (e) {
      _secureStorage = const FlutterSecureStorage();
      _logDebug('Using default FlutterSecureStorage, error: $e');
    }
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    _logDebug(
        'Error caught for ${err.requestOptions.path} - Status: ${err.response?.statusCode}');

    // 401 (Unauthorized) hatası için token yenileme işlemini başlat
    if (_shouldRefreshToken(err)) {
      await _handleTokenRefresh(err, handler);
      return;
    }

    // Diğer hata türleri için uygun exception'ı oluştur ve reddet
    final exception = _createExceptionFromError(err);
    handler.reject(DioException(
      requestOptions: err.requestOptions,
      error: exception,
      response: err.response,
      type: err.type,
      message: exception.message,
    ));
  }

  /// DioException'dan uygun AppException türevini oluşturur
  AppException _createExceptionFromError(DioException err) {
    final statusCode = err.response?.statusCode;
    final path = err.requestOptions.path;

    switch (statusCode) {
      case 400:
        // Validation hatası olup olmadığını kontrol et
        if (err.response?.data is Map<String, dynamic>) {
          final data = err.response!.data as Map<String, dynamic>;
          if (data.containsKey('errors') || data.containsKey('fieldErrors')) {
            return ValidationException.fromDioResponse(err.response?.data);
          }
        }
        return NetworkException.fromDioError(err);

      case 401:
        return AuthException(
          message: 'Yetkilendirme hatası. Lütfen tekrar giriş yapın.',
          isTokenExpired: true,
          code: 'UNAUTHORIZED',
          details: err,
        );

      case 403:
        return AuthException(
          message: 'Bu işlem için yetkiniz bulunmamaktadır.',
          isTokenExpired: false,
          code: 'FORBIDDEN',
          details: err,
        );

      case 404:
        final resourceType = _getResourceTypeFromPath(path);
        return NotFoundException(
          message: '$resourceType bulunamadı.',
          resourceType: resourceType,
          details: err,
        );

      case 422:
        return ValidationException.fromDioResponse(err.response?.data);

      case 500:
      case 502:
      case 503:
      case 504:
        return NetworkException(
          message: 'Sunucu hatası oluştu. Lütfen daha sonra tekrar deneyin.',
          statusCode: statusCode,
          details: err,
        );

      default:
        return NetworkException.fromDioError(err);
    }
  }

  /// İstek yolundan kaynak tipini çıkarır (users/1 -> User)
  String _getResourceTypeFromPath(String path) {
    String resourceType = 'Kaynak';
    final pathSegments = path.split('/').where((s) => s.isNotEmpty).toList();

    if (pathSegments.isNotEmpty) {
      resourceType = pathSegments.first;
      // Çoğul formdan tekil forma çevir (users -> User)
      if (resourceType.endsWith('s')) {
        resourceType = resourceType.substring(0, resourceType.length - 1);
      }
      // İlk harfi büyüt
      resourceType = resourceType[0].toUpperCase() + resourceType.substring(1);
    }

    return resourceType;
  }

  /// Token yenileme gerekip gerekmediğini kontrol eder
  bool _shouldRefreshToken(DioException err) {
    return err.response?.statusCode == 401 &&
        !err.requestOptions.path.contains(_refreshEndpoint);
  }

  /// Token yenileme işlemini gerçekleştirir
  Future<void> _handleTokenRefresh(
      DioException err, ErrorInterceptorHandler handler) async {
    _logDebug('401 detected, attempting token refresh...');

    // Eğer zaten bir yenileme işlemi devam ediyorsa, bu isteği beklemeye al
    if (_isRefreshing && _refreshCompleter != null) {
      _logDebug('Refresh already in progress, queuing request.');
      _pendingRequests.add(_PendingRequest(err.requestOptions, handler));

      // Refresh işleminin tamamlanmasını bekle
      final newAccessToken = await _refreshCompleter!.future;

      if (newAccessToken != null) {
        // Token başarıyla yenilendi, isteği tekrar dene
        try {
          final retryResponse =
              await _retryRequest(err.requestOptions, newAccessToken);
          handler.resolve(retryResponse);
        } catch (retryError) {
          _logDebug('Error retrying queued request: $retryError');
          handler.reject(err);
        }
      } else {
        // Token yenilenemedi, hata döndür
        handler.reject(err);
      }
      return;
    }

    _isRefreshing = true;
    _refreshCompleter = Completer<String?>();

    try {
      final refreshToken = await _secureStorage.read(key: _refreshTokenKey);

      if (refreshToken == null || refreshToken.isEmpty) {
        _logDebug('No refresh token found.');
        await _handleRefreshError(handler, err, 'Oturumunuz sonlanmış.');
        _refreshCompleter!.complete(null);
        return;
      }

      final response = await _tryRefreshToken(refreshToken);

      if (response.statusCode == 200 &&
          response.data != null &&
          response.data is Map<String, dynamic>) {
        final tokens = response.data as Map<String, dynamic>;
        final newAccessToken = tokens['accessToken'] as String?;
        final newRefreshToken = tokens['refreshToken'] as String?;

        if (newAccessToken != null && newRefreshToken != null) {
          await _saveTokens(newAccessToken, newRefreshToken);
          _logDebug('Token refresh successful');

          // Başarısız olan orijinal isteği yeni token ile tekrar dene
          try {
            final retryResponse =
                await _retryRequest(err.requestOptions, newAccessToken);
            handler.resolve(retryResponse);
          } catch (retryError) {
            _logDebug('Error retrying original request: $retryError');
            handler.reject(err);
          }

          // Bekleyen istekleri işle
          _processPendingRequests(newAccessToken);

          // Refresh işlemini tamamla
          _refreshCompleter!.complete(newAccessToken);
          return;
        }
      }

      // Geçerli token alınamadıysa
      await _handleRefreshError(
          handler, err, 'Oturum yenilenemedi. Lütfen tekrar giriş yapın.');
      _refreshCompleter!.complete(null);
    } on DioException catch (refreshError) {
      _logDebug('Error during refresh token request: $refreshError');
      await _handleRefreshError(handler, err, 'Token yenileme sırasında hata.');
      _refreshCompleter!.complete(null);
    } catch (e) {
      _logDebug('Unexpected error during refresh: $e');
      await _handleRefreshError(handler, err, 'Beklenmedik yenileme hatası.');
      _refreshCompleter!.complete(null);
    } finally {
      _isRefreshing = false;
      _refreshCompleter = null;
      _pendingRequests.clear();
    }
  }

  /// Refresh token ile yeni tokenlar almayı dener
  Future<Response> _tryRefreshToken(String refreshToken) async {
    _logDebug('Sending refresh token request...');

    return await _dio.post(
      _refreshEndpoint,
      data: {'refreshToken': refreshToken},
      options: Options(
        headers: {}, // Önceki Authorization header'ını temizle
        validateStatus: (status) => true, // Tüm statusları kabul et
        sendTimeout: const Duration(milliseconds: 5000), // Kısa timeout
        receiveTimeout: const Duration(milliseconds: 8000), // Kısa timeout
      ),
    );
  }

  /// Yeni tokenları güvenli depolamaya kaydeder
  Future<void> _saveTokens(String accessToken, String refreshToken) async {
    await _secureStorage.write(key: _accessTokenKey, value: accessToken);
    await _secureStorage.write(key: _refreshTokenKey, value: refreshToken);
    _logDebug('New tokens saved.');
  }

  /// Başarısız olan isteği yeni token ile tekrar dener
  Future<Response> _retryRequest(
      RequestOptions options, String newAccessToken) async {
    _logDebug('Retrying original request: ${options.path}');

    // Yeni options oluştur (orijinali değiştirme)
    final newOptions = Options(
      method: options.method,
      headers: {
        ...options.headers,
        'Authorization': 'Bearer $newAccessToken',
      },
      contentType: options.contentType,
      responseType: options.responseType,
      validateStatus: options.validateStatus,
      receiveTimeout: options.receiveTimeout,
      sendTimeout: options.sendTimeout,
    );

    return await _dio.request(
      options.path,
      data: options.data,
      queryParameters: options.queryParameters,
      options: newOptions,
    );
  }

  /// Bekleyen istekleri yeniden deneyen yardımcı metot
  void _processPendingRequests(String newAccessToken) async {
    _logDebug('Processing ${_pendingRequests.length} pending requests...');

    final List<_PendingRequest> requestsToRetry = List.from(_pendingRequests);

    for (var pendingRequest in requestsToRetry) {
      try {
        final retryResponse =
            await _retryRequest(pendingRequest.options, newAccessToken);
        pendingRequest.handler.resolve(retryResponse);
        _logDebug(
            'Successfully retried pending request: ${pendingRequest.options.path}');
      } catch (e) {
        _logDebug(
            'Error retrying pending request ${pendingRequest.options.path}: $e');
        // Hata durumunda orijinal hatayı döndür
        pendingRequest.handler.reject(DioException(
          requestOptions: pendingRequest.options,
          error: e,
          type: DioExceptionType.unknown,
        ));
      }
    }
  }

  /// Refresh token hatası durumunda yapılacak işlemler
  Future<void> _handleRefreshError(ErrorInterceptorHandler handler,
      DioException originalError, String message) async {
    _logDebug('Handling refresh error: $message');

    // Tokenları temizle
    try {
      await _secureStorage.delete(key: _accessTokenKey);
      await _secureStorage.delete(key: _refreshTokenKey);
    } catch (e) {
      _logDebug('Error deleting tokens: $e');
    }

    // Bekleyen istekleri de temizle ve hata döndür
    for (var pendingRequest in _pendingRequests) {
      final authException = AuthException(
          message: message,
          isTokenExpired: true,
          code: 'AUTH_TOKEN_EXPIRED',
          details: originalError);

      pendingRequest.handler.reject(DioException(
          requestOptions: pendingRequest.options,
          error: authException,
          response: originalError.response,
          type: originalError.type,
          message: authException.message));
    }

    // AuthException oluştur
    final authException = AuthException(
        message: message,
        isTokenExpired: true,
        code: 'AUTH_TOKEN_EXPIRED',
        details: originalError);

    // Kullanıcıyı login ekranına yönlendir
    try {
      Get.offAllNamed(AppRoutes.LOGIN);
    } catch (e) {
      _logDebug('Error navigating to login: $e');
    }

    // Orijinal hatayı AuthException ile güncelle ve reddet
    handler.reject(DioException(
        requestOptions: originalError.requestOptions,
        error: authException,
        response: originalError.response,
        type: originalError.type,
        message: authException.message));
  }

  /// Debug modunda log basar (Release modunda çalışmaz)
  void _logDebug(String message) {
    if (kDebugMode) {
      // ignore: avoid_print
      print('>>> ErrorInterceptor: $message');
    }
  }
}

/// Bekleyen istek için helper sınıf
class _PendingRequest {
  final RequestOptions options;
  final ErrorInterceptorHandler handler;

  _PendingRequest(this.options, this.handler);
}
