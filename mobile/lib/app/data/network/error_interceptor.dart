import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart'; // GetX dependency injection ve yönlendirme için
import '../../navigation/app_routes.dart'; // Rota isimleri için
import '../../utils/exceptions.dart'; // AppException sınıflarını import et

// Token'ları saklamak için kullanılacak key'ler
const String _accessTokenKey = 'accessToken';
const String _refreshTokenKey = 'refreshToken';
const String _refreshEndpoint =
    '/auth/refresh'; // Backend'deki refresh endpoint yolu

class ErrorInterceptor extends Interceptor {
  final Dio _dio; // Token yenileme isteği için Dio instance'ı
  late final FlutterSecureStorage _secureStorage;

  // Token yenileme işlemi sırasında diğer istekleri kilitlemek için
  bool _isRefreshing = false;
  final List<RequestOptions> _pendingRequests = [];

  ErrorInterceptor(this._dio) {
    try {
      // GetX ile FlutterSecureStorage'ı bul
      _secureStorage = Get.find<FlutterSecureStorage>();
      print('>>> ErrorInterceptor: FlutterSecureStorage injected from GetX');
    } catch (e) {
      // Fallback olarak doğrudan oluştur
      _secureStorage = const FlutterSecureStorage();
      print(
          '>>> ErrorInterceptor: Using default FlutterSecureStorage, error: $e');
    }
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    print('>>> ErrorInterceptor: Error caught for ${err.requestOptions.path}');
    print('>>> ErrorInterceptor: Status Code: ${err.response?.statusCode}');
    print('>>> ErrorInterceptor: Error Data: ${err.response?.data}');

    // Eğer hata 401 Unauthorized ise ve refresh endpoint'i değilse token yenilemeyi dene
    if (err.response?.statusCode == 401 &&
        !err.requestOptions.path.contains(_refreshEndpoint)) {
      print('>>> ErrorInterceptor: 401 detected, attempting token refresh...');

      // Eğer zaten bir yenileme işlemi devam ediyorsa, bu isteği beklemeye al
      if (_isRefreshing) {
        print(
            '>>> ErrorInterceptor: Refresh already in progress, queuing request.');
        _pendingRequests.add(err.requestOptions);
        // Handler'ı sonlandırma, istek askıda kalır.
        // Yenileme bitince bu istekler tekrar denenecek.
        return; // handler.next(err) veya handler.reject(err) çağırma!
      }

      _isRefreshing = true; // Yenileme başladı

      // Refresh token'ı güvenli depolamadan oku
      final String? refreshToken =
          await _secureStorage.read(key: _refreshTokenKey);
      print(
          '>>> ErrorInterceptor: Refresh token: ${refreshToken != null ? "mevcut" : "bulunamadı"}');

      if (refreshToken != null && refreshToken.isNotEmpty) {
        try {
          print('>>> ErrorInterceptor: Sending refresh token request...');

          // Yeni token almak için refresh endpoint'ine istek yap
          final response = await _dio.post(
            _refreshEndpoint,
            data: {'refreshToken': refreshToken},
            options: Options(
              headers: {}, // Önceki Authorization header'ını temizle
              validateStatus: (status) => true, // Tüm statusları kabul et
            ),
          );

          print(
              '>>> ErrorInterceptor: Refresh response status: ${response.statusCode}');
          print(
              '>>> ErrorInterceptor: Refresh response data: ${response.data}');

          if (response.statusCode == 200) {
            print('>>> ErrorInterceptor: Token refresh successful.');
            // Yeni tokenları al (Backend'den gelen yanıta göre parse et)
            // AuthResponseDto'ya benzer bir yapı varsayılıyor
            final newAccessToken = response.data['accessToken'] as String?;
            final newRefreshToken = response.data['refreshToken'] as String?;

            if (newAccessToken != null && newRefreshToken != null) {
              // Yeni tokenları güvenli depolamaya kaydet
              await _secureStorage.write(
                  key: _accessTokenKey, value: newAccessToken);
              await _secureStorage.write(
                  key: _refreshTokenKey, value: newRefreshToken);
              print('>>> ErrorInterceptor: New tokens saved.');

              // Başarısız olan orijinal isteği yeni token ile tekrar dene
              print(
                  '>>> ErrorInterceptor: Retrying original request: ${err.requestOptions.path}');
              final options = err.requestOptions;
              options.headers['Authorization'] = 'Bearer $newAccessToken';

              // Dio ile isteği tekrar gönder
              // options objesini doğrudan kullanamayabiliriz, yeni bir request oluşturmak gerekebilir.
              final retryResponse = await _dio.request(
                options.path,
                data: options.data,
                queryParameters: options.queryParameters,
                options: Options(
                  method: options.method,
                  headers: options.headers, // Yeni header'ları içeren options
                  contentType: options.contentType,
                  responseType: options.responseType,
                ),
              );
              print(
                  '>>> ErrorInterceptor: Original request retried successfully.');
              // Başarılı yanıtı orijinal handler'a ilet
              handler.resolve(retryResponse);

              // Bekleyen istekleri de yeni token ile tekrar dene
              await _retryPendingRequests(newAccessToken);
              return; // Handler işlendi, erken çık
            } else {
              print(
                  '>>> ErrorInterceptor: Invalid token data received from refresh endpoint.');
              await _handleRefreshError(
                  handler, err, 'Yenileme yanıtı geçersiz.');
            }
          } else {
            print(
                '>>> ErrorInterceptor: Refresh request failed with status: ${response.statusCode}');
            await _handleRefreshError(
                handler, err, 'Token yenileme başarısız oldu.');
          }
        } on DioException catch (refreshError) {
          print(
              '>>> ErrorInterceptor: Error during refresh token request: $refreshError');
          // Refresh token isteği de başarısız olursa (örn: refresh token geçersiz)
          await _handleRefreshError(
              handler, err, 'Token yenileme sırasında hata.');
        } catch (e) {
          print('>>> ErrorInterceptor: Unexpected error during refresh: $e');
          await _handleRefreshError(
              handler, err, 'Beklenmedik yenileme hatası.');
        } finally {
          _isRefreshing = false; // Yenileme bitti
          _pendingRequests.clear(); // Bekleyen istek listesini temizle
          print('>>> ErrorInterceptor: Refresh process finished.');
        }
      } else {
        print('>>> ErrorInterceptor: No refresh token found.');
        // Refresh token yoksa direkt hata ile devam et veya login'e yönlendir
        await _handleRefreshError(handler, err, 'Oturumunuz sonlanmış.');
      }
    } else {
      // 401 olmayan diğer hatalar için NetworkException oluştur ve devam et
      print(
          '>>> ErrorInterceptor: Non-401 error or refresh endpoint error, creating NetworkException.');

      // Hata tipine göre doğru exception oluştur
      AppException exception;

      if (err.response?.statusCode == 400 || err.response?.statusCode == 422) {
        // 400 Bad Request veya 422 Unprocessable Entity durumlarında validasyon hatası olabilir
        exception = ValidationException.fromDioResponse(err.response?.data,
            defaultMessage: 'Gönderilen veriler geçersiz');
        print(
            '>>> ErrorInterceptor: Validation error detected with status ${err.response?.statusCode}');
      } else if (err.response?.statusCode == 404) {
        // 404 Not Found - Kaynak bulunamadı hatası
        final path = err.requestOptions.path;
        String resourceType = 'Kaynak';

        // İsteğin yolundan kaynak tipini çıkarmaya çalış
        // Örnek: /users/1 -> User, /accounts/5 -> Account
        final pathSegments =
            path.split('/').where((s) => s.isNotEmpty).toList();
        if (pathSegments.isNotEmpty) {
          resourceType = pathSegments.first;
          // Çoğul formdan tekil forma çevir (örn: users -> User)
          if (resourceType.endsWith('s')) {
            resourceType = resourceType.substring(0, resourceType.length - 1);
          }
          // İlk harfi büyüt
          resourceType =
              resourceType[0].toUpperCase() + resourceType.substring(1);
        }

        exception = NotFoundException(
            message:
                err.response?.data?['message'] ?? '$resourceType bulunamadı',
            resourceType: resourceType);
        print(
            '>>> ErrorInterceptor: Not found error detected for resource: $resourceType');
      } else {
        // Diğer hata tipleri için NetworkException kullan
        exception = NetworkException.fromDioError(err);
        print(
            '>>> ErrorInterceptor: Network exception created with message: ${exception.message}');
      }

      // Orijinal hatayı özel exception ile güncelle
      final updatedError = DioException(
          requestOptions: err.requestOptions,
          response: err.response,
          type: err.type,
          error: exception, // Özel exception'ı error alanına ekle
          message: exception.message // Anlamlı hata mesajını ayarla
          );

      handler.next(updatedError); // Güncellenen hatayla devam et
    }
  }

  // Bekleyen istekleri yeniden deneyen yardımcı metot
  Future<void> _retryPendingRequests(String newAccessToken) async {
    print(
        '>>> ErrorInterceptor: Retrying ${_pendingRequests.length} pending requests...');
    final List<RequestOptions> requestsToRetry =
        List.from(_pendingRequests); // Kopyasını al
    _pendingRequests.clear(); // Orijinal listeyi temizle

    for (var options in requestsToRetry) {
      options.headers['Authorization'] = 'Bearer $newAccessToken';
      print('>>> ErrorInterceptor: Retrying pending request: ${options.path}');
      try {
        // İsteği tekrar gönder (resolve/reject yok, kendi akışında devam eder)
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
        print(
            '>>> ErrorInterceptor: Pending request ${options.path} retried successfully.');
      } catch (e) {
        print(
            '>>> ErrorInterceptor: Error retrying pending request ${options.path}: $e');
        // Tekrar deneme başarısız olursa ne yapılacağına karar verilebilir (örn: loglama)
      }
    }
    print('>>> ErrorInterceptor: Finished retrying pending requests.');
  }

  // Refresh token hatası durumunda yapılacak işlemler
  Future<void> _handleRefreshError(ErrorInterceptorHandler handler,
      DioException originalError, String message) async {
    print('>>> ErrorInterceptor: Handling refresh error: $message');
    // Tokenları temizle
    try {
      await _secureStorage.delete(key: _accessTokenKey);
      await _secureStorage.delete(key: _refreshTokenKey);
      print('>>> ErrorInterceptor: Tokens deleted.');
    } catch (e) {
      print('>>> ErrorInterceptor: Error deleting tokens: $e');
    }

    // AuthException oluştur
    final authException = AuthException(
        message: message,
        isTokenExpired: true,
        code: 'AUTH_TOKEN_EXPIRED',
        details: originalError);

    // Kullanıcıyı login ekranına yönlendir (GetX ile)
    Get.offAllNamed(AppRoutes.LOGIN); // Tüm geçmişi temizleyerek Login'e git

    // Orijinal hatayı AuthException ile güncelle ve reddet
    handler.reject(DioException(
        requestOptions: originalError.requestOptions,
        error: authException, // Özel exception kullan
        response: originalError.response, // Orijinal yanıtı koru (opsiyonel)
        type: originalError.type,
        message: authException.message // Anlamlı hata mesajı
        ));
  }
}
