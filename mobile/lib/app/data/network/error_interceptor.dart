import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart'; // GetX dependency injection ve yönlendirme için
import 'dio_client.dart'; // DioClient'a erişim için (veya doğrudan Dio instance'ı)
import '../../navigation/app_routes.dart'; // Rota isimleri için

// Token'ları saklamak için kullanılacak key'ler
const String _accessTokenKey = 'accessToken';
const String _refreshTokenKey = 'refreshToken';
const String _refreshEndpoint = '/auth/refresh'; // Backend'deki refresh endpoint yolu

class ErrorInterceptor extends Interceptor {
  final Dio _dio; // Token yenileme isteği için Dio instance'ı
  // final _secureStorage = Get.find<FlutterSecureStorage>(); // GetX örneği
  final _secureStorage = const FlutterSecureStorage(); // Doğrudan kullanım örneği

  // Token yenileme işlemi sırasında diğer istekleri kilitlemek için
  bool _isRefreshing = false;
  final List<RequestOptions> _pendingRequests = [];

  ErrorInterceptor(this._dio); // Dio instance'ını constructor ile al

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    print('>>> ErrorInterceptor: Error caught for ${err.requestOptions.path}');
    print('>>> ErrorInterceptor: Status Code: ${err.response?.statusCode}');
    print('>>> ErrorInterceptor: Error Data: ${err.response?.data}');

    // Eğer hata 401 Unauthorized ise ve refresh endpoint'i değilse token yenilemeyi dene
    if (err.response?.statusCode == 401 && err.requestOptions.path != _refreshEndpoint) {
      print('>>> ErrorInterceptor: 401 detected, attempting token refresh...');

      // Eğer zaten bir yenileme işlemi devam ediyorsa, bu isteği beklemeye al
      if (_isRefreshing) {
        print('>>> ErrorInterceptor: Refresh already in progress, queuing request.');
        _pendingRequests.add(err.requestOptions);
        // Handler'ı sonlandırma, istek askıda kalır.
        // Yenileme bitince bu istekler tekrar denenecek.
        return; // handler.next(err) veya handler.reject(err) çağırma!
      }

      _isRefreshing = true; // Yenileme başladı

      // Refresh token'ı güvenli depolamadan oku
      final String? refreshToken = await _secureStorage.read(key: _refreshTokenKey);

      if (refreshToken != null && refreshToken.isNotEmpty) {
        try {
          print('>>> ErrorInterceptor: Sending refresh token request...');
          // Yeni token almak için refresh endpoint'ine istek yap
          // ÖNEMLİ: Bu istek için kullanılan Dio instance'ında interceptor'lar
          // döngüye neden olmaması için dikkatli yönetilmeli.
          // Yeni bir Dio instance kullanmak veya mevcut instance'ı klonlamak daha güvenli olabilir.
          // Şimdilik mevcut instance ile deniyoruz.
          final response = await _dio.post(
            _refreshEndpoint,
            data: {'refreshToken': refreshToken},
          );

          if (response.statusCode == 200) {
            print('>>> ErrorInterceptor: Token refresh successful.');
            // Yeni tokenları al (Backend'den gelen yanıta göre parse et)
            // AuthResponseDto'ya benzer bir yapı varsayılıyor
            final newAccessToken = response.data['accessToken'] as String?;
            final newRefreshToken = response.data['refreshToken'] as String?;

            if (newAccessToken != null && newRefreshToken != null) {
              // Yeni tokenları güvenli depolamaya kaydet
              await _secureStorage.write(key: _accessTokenKey, value: newAccessToken);
              await _secureStorage.write(key: _refreshTokenKey, value: newRefreshToken);
              print('>>> ErrorInterceptor: New tokens saved.');

              // Başarısız olan orijinal isteği yeni token ile tekrar dene
              print('>>> ErrorInterceptor: Retrying original request: ${err.requestOptions.path}');
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
              print('>>> ErrorInterceptor: Original request retried successfully.');
              // Başarılı yanıtı orijinal handler'a ilet
              handler.resolve(retryResponse);

              // Bekleyen istekleri de yeni token ile tekrar dene
              await _retryPendingRequests(newAccessToken);
            } else {
              print('>>> ErrorInterceptor: Invalid token data received from refresh endpoint.');
              await _handleRefreshError(handler, err, 'Yenileme yanıtı geçersiz.');
            }
          } else {
            print(
                '>>> ErrorInterceptor: Refresh request failed with status: ${response.statusCode}');
            await _handleRefreshError(handler, err, 'Token yenileme başarısız oldu.');
          }
        } on DioException catch (refreshError) {
          print('>>> ErrorInterceptor: Error during refresh token request: $refreshError');
          // Refresh token isteği de başarısız olursa (örn: refresh token geçersiz)
          await _handleRefreshError(handler, err, 'Token yenileme sırasında hata.');
        } catch (e) {
          print('>>> ErrorInterceptor: Unexpected error during refresh: $e');
          await _handleRefreshError(handler, err, 'Beklenmedik yenileme hatası.');
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
      // 401 olmayan diğer hatalar için direkt devam et
      print('>>> ErrorInterceptor: Non-401 error, passing through.');
      super.onError(err, handler); // veya handler.next(err);
    }
  }

  // Bekleyen istekleri yeniden deneyen yardımcı metot
  Future<void> _retryPendingRequests(String newAccessToken) async {
    print('>>> ErrorInterceptor: Retrying ${_pendingRequests.length} pending requests...');
    final List<RequestOptions> requestsToRetry = List.from(_pendingRequests); // Kopyasını al
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
        print('>>> ErrorInterceptor: Pending request ${options.path} retried successfully.');
      } catch (e) {
        print('>>> ErrorInterceptor: Error retrying pending request ${options.path}: $e');
        // Tekrar deneme başarısız olursa ne yapılacağına karar verilebilir (örn: loglama)
      }
    }
    print('>>> ErrorInterceptor: Finished retrying pending requests.');
  }

  // Refresh token hatası durumunda yapılacak işlemler
  Future<void> _handleRefreshError(
      ErrorInterceptorHandler handler, DioException originalError, String message) async {
    print('>>> ErrorInterceptor: Handling refresh error: $message');
    // Tokenları temizle
    await _secureStorage.deleteAll();
    // Kullanıcıyı login ekranına yönlendir (GetX ile)
    Get.offAllNamed(AppRoutes.LOGIN); // Tüm geçmişi temizleyerek Login'e git
    // Orijinal hatayı reddet (isteği sonlandır)
    handler.reject(DioException(
      requestOptions: originalError.requestOptions,
      error: message, // Özel hata mesajı
      response: originalError.response, // Orijinal yanıtı koru (opsiyonel)
      type: originalError.type,
    ));
  }
}
