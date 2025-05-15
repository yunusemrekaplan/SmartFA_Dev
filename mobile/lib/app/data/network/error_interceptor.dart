import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart' hide Response;
import 'package:mobile/app/data/network/exceptions.dart';
import 'package:mobile/app/navigation/app_routes.dart';
import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:mobile/app/modules/home/home_controller.dart';
import 'package:mobile/app/modules/dashboard/dashboard_controller.dart';

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
  final List<RequestOptions> _pendingRequests = [];

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

    // 401 Unauthorized hatası token yenileme ile çözülebilir mi?
    if (_shouldRefreshToken(err)) {
      await _handleTokenRefresh(err, handler);
      return;
    }

    // Diğer hatalar için uygun AppException oluştur
    final exception = _createAppException(err);
    _logDebug(
        'Created exception: ${exception.runtimeType} - ${exception.message}');

    // Orijinal hatayı özel exception ile güncelle
    final updatedError = DioException(
        requestOptions: err.requestOptions,
        response: err.response,
        type: err.type,
        error: exception,
        message: exception.message);

    handler.next(updatedError);
  }

  /// Hata tipine göre uygun AppException oluşturur
  AppException _createAppException(DioException err) {
    final statusCode = err.response?.statusCode;
    final responseData = err.response?.data;

    // 404 Not Found -> NotFoundException
    if (statusCode == 404) {
      final resourceType = _getResourceTypeFromPath(err.requestOptions.path);
      return NotFoundException(
          message: err.response?.data?['message'] ?? '$resourceType bulunamadı',
          resourceType: resourceType);
    }

    // 400 Bad Request veya 422 Unprocessable Entity
    if (statusCode == 400 || statusCode == 422) {
      // Yanıtın yapısını kontrol et
      if (responseData is Map<String, dynamic> &&
          (responseData.containsKey('errors') ||
              responseData.containsKey('fieldErrors'))) {
        // Doğrulama hatası formatında
        return ValidationException.fromDioResponse(responseData,
            defaultMessage: 'Gönderilen veriler geçersiz');
      } else {
        // Doğrulama hatası formatında değil, genel bir hata
        String message = '';
        if (responseData is String) {
          message = responseData;
        } else if (responseData is Map<String, dynamic> &&
            responseData.containsKey('message')) {
          message = responseData['message'].toString();
        } else {
          message = 'İstek işlenemedi';
        }

        return NetworkException(
            message: message,
            code: 'BAD_REQUEST',
            statusCode: statusCode,
            details: responseData);
      }
    }

    // Diğer tüm hatalar için NetworkException
    return NetworkException.fromDioError(err);
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
    if (_isRefreshing) {
      _logDebug('Refresh already in progress, queuing request.');
      _pendingRequests.add(err.requestOptions);
      return;
    }

    _isRefreshing = true;

    try {
      final refreshToken = await _secureStorage.read(key: _refreshTokenKey);

      if (refreshToken == null || refreshToken.isEmpty) {
        _logDebug('No refresh token found.');
        await _handleRefreshError(handler, err, 'Oturumunuz sonlanmış.');
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

          // Başarısız olan orijinal isteği yeni token ile tekrar dene
          final retryResponse =
              await _retryRequest(err.requestOptions, newAccessToken);
          handler.resolve(retryResponse);

          // Bekleyen diğer istekleri de yeni token ile tekrar dene
          await _retryPendingRequests(newAccessToken);

          // Token yenileme başarılı olduktan sonra dashboard verilerini yenile
          _refreshDashboardData();

          return;
        }
      }

      // Geçerli token alınamadıysa
      await _handleRefreshError(
          handler, err, 'Oturum yenilenemedi. Lütfen tekrar giriş yapın.');
    } on DioException catch (refreshError) {
      _logDebug('Error during refresh token request: $refreshError');
      await _handleRefreshError(handler, err, 'Token yenileme sırasında hata.');
    } catch (e) {
      _logDebug('Unexpected error during refresh: $e');
      await _handleRefreshError(handler, err, 'Beklenmedik yenileme hatası.');
    } finally {
      _isRefreshing = false;
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

    options.headers['Authorization'] = 'Bearer $newAccessToken';

    return await _dio.request(
      options.path,
      data: options.data,
      queryParameters: options.queryParameters,
      options: Options(
        method: options.method,
        headers: options.headers,
        contentType: options.contentType,
        responseType: options.responseType,
      ),
    );
  }

  /// Bekleyen istekleri yeniden deneyen yardımcı metot
  Future<void> _retryPendingRequests(String newAccessToken) async {
    _logDebug('Retrying ${_pendingRequests.length} pending requests...');

    final List<RequestOptions> requestsToRetry = List.from(_pendingRequests);
    _pendingRequests.clear();

    for (var options in requestsToRetry) {
      options.headers['Authorization'] = 'Bearer $newAccessToken';
      _logDebug('Retrying pending request: ${options.path}');

      try {
        await _dio.request(
          options.path,
          data: options.data,
          queryParameters: options.queryParameters,
          options: Options(
            method: options.method,
            headers: options.headers,
            contentType: options.contentType,
            responseType: options.responseType,
          ),
        );
      } catch (e) {
        _logDebug('Error retrying pending request ${options.path}: $e');
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

    // AuthException oluştur
    final authException = AuthException(
        message: message,
        isTokenExpired: true,
        code: 'AUTH_TOKEN_EXPIRED',
        details: originalError);

    // Kullanıcıyı login ekranına yönlendir
    Get.offAllNamed(AppRoutes.LOGIN);

    // Orijinal hatayı AuthException ile güncelle ve reddet
    handler.reject(DioException(
        requestOptions: originalError.requestOptions,
        error: authException,
        response: originalError.response,
        type: originalError.type,
        message: authException.message));
  }

  /// Dashboard verilerini yenilemek için HomeController'ı çağırır
  void _refreshDashboardData() {
    try {
      // Token yenileme işlemlerinin tamamen bitmesi için daha uzun bir gecikme ekle
      // Bu da kullanıcı arayüzündeki yükleme göstergelerinin doğru şekilde çalışmasını sağlar
      Future.delayed(const Duration(milliseconds: 800), () {
        if (Get.isRegistered<HomeController>()) {
          final homeController = Get.find<HomeController>();
          _logDebug('Triggering dashboard refresh after token refresh');

          // Dashboard controller'ına direkt erişip önce yükleme durumunu sıfırla
          if (Get.isRegistered<DashboardController>()) {
            final dashboardController = Get.find<DashboardController>();
            _logDebug('Resetting dashboard loading state before refresh');
            dashboardController.resetLoadingState();
          }

          // Sonra tüm verileri yenile
          homeController.refreshAllData();
        } else {
          _logDebug(
              'HomeController is not registered yet, cannot refresh dashboard');
        }
      });
    } catch (e) {
      _logDebug('Error refreshing dashboard data: $e');
    }
  }

  /// Debug modunda log basar (Release modunda çalışmaz)
  void _logDebug(String message) {
    if (kDebugMode) {
      // ignore: avoid_print
      print('>>> ErrorInterceptor: $message');
    }
  }
}
