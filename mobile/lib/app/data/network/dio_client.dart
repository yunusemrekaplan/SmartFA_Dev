import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart'; // kDebugMode için
import 'auth_interceptor.dart'; // AuthInterceptor import
import 'error_interceptor.dart'; // ErrorInterceptor import

// Backend API'nin geliştirme ortamı için temel URL'si
// Bunu ortam değişkenleri veya config dosyası ile yönetmek daha iyidir.
const String baseUrl =
    'http://192.168.1.189:5104/api'; // Backend API adresinizi buraya girin (appsettings.Development.json'daki adres)

class DioClient {
  late final Dio _dio; // Ana Dio instance'ı
  late final Dio _refreshDio; // Token yenileme için ayrı Dio instance'ı

  // Singleton pattern (isteğe bağlı, GetX ile de yönetilebilir)
  static final DioClient _instance = DioClient._internal();

  factory DioClient() => _instance;

  DioClient._internal() {
    // Ana Dio instance'ı (standart istekler için)
    _dio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        connectTimeout:
            const Duration(milliseconds: 10000), // 10 saniye bağlantı timeout
        receiveTimeout:
            const Duration(milliseconds: 15000), // 15 saniye yanıt alma timeout
        sendTimeout:
            const Duration(milliseconds: 10000), // 10 saniye gönderme timeout
        responseType: ResponseType.json, // Yanıtları JSON olarak bekle
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    // Token yenileme için özel Dio instance'ı (daha kısa timeout)
    _refreshDio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        connectTimeout:
            const Duration(milliseconds: 5000), // 5 saniye bağlantı timeout
        receiveTimeout:
            const Duration(milliseconds: 8000), // 8 saniye yanıt alma timeout
        sendTimeout:
            const Duration(milliseconds: 5000), // 5 saniye gönderme timeout
        responseType: ResponseType.json,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    // Ana Dio için interceptor'ları ekle
    // ÖNEMLİ SIRA: Auth -> Error -> Log (Log en sonda olmalı ki her şeyi yakalasın)
    _dio.interceptors.add(AuthInterceptor());
    // ErrorInterceptor, token yenileme isteği için ayrı Dio instance'ını alır.
    _dio.interceptors.add(ErrorInterceptor(_refreshDio));

    // Geliştirme ortamında istek/yanıt loglaması için interceptor ekle
    if (kDebugMode) {
      _dio.interceptors.add(LogInterceptor(
        requestBody: true, // İstek body'sini logla
        responseBody: true, // Yanıt body'sini logla
        requestHeader: true, // İstek header'larını logla
        responseHeader:
            false, // Yanıt header'larını loglama (çok yer kaplayabilir)
        error: true, // Hataları logla
        logPrint: (obj) =>
            debugPrint('>>> DioClient: $obj'), // Logları debug console'a yazdır
      ));

      // Refresh Dio için de logging (daha basit)
      _refreshDio.interceptors.add(LogInterceptor(
        requestBody: true,
        responseBody: true,
        requestHeader: false,
        responseHeader: false,
        error: true,
        logPrint: (obj) => debugPrint('>>> RefreshDio: $obj'),
      ));
    }
  }

  // Ana Dio instance'ına dışarıdan erişim için getter
  Dio get dio => _dio;

  // Refresh Dio instance'ına erişim için getter
  Dio get refreshDio => _refreshDio;

  // --- Genel HTTP Metotları (Wrapper'lar) ---
  // Bu metotlar, interceptor'ların işini yapmasına izin verir ve
  // sadece temel istekleri yönlendirir. Hata yönetimi interceptor'da yapılır.

  /// GET isteği yapar.
  Future<Response> get(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onReceiveProgress,
  }) async {
    try {
      final Response response = await _dio.get(
        path,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
        onReceiveProgress: onReceiveProgress,
      );
      return response;
    } on DioException {
      // Hata yönetimi interceptor'da yapılacak, burada sadece tekrar fırlatıyoruz.
      rethrow;
    } catch (e) {
      // Beklenmedik diğer hatalar için
      rethrow;
    }
  }

  /// POST isteği yapar.
  Future<Response> post(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
    try {
      final Response response = await _dio.post(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
        onSendProgress: onSendProgress,
        onReceiveProgress: onReceiveProgress,
      );
      return response;
    } on DioException {
      rethrow;
    } catch (e) {
      rethrow;
    }
  }

  /// PUT isteği yapar.
  Future<Response> put(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
    try {
      final Response response = await _dio.put(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
        onSendProgress: onSendProgress,
        onReceiveProgress: onReceiveProgress,
      );
      return response;
    } on DioException {
      rethrow;
    } catch (e) {
      rethrow;
    }
  }

  /// DELETE isteği yapar.
  Future<Response> delete(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    try {
      final Response response = await _dio.delete(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      );
      return response;
    } on DioException {
      rethrow;
    } catch (e) {
      rethrow;
    }
  }

  /// Token yenileme işlemi için özel POST metodu (timeout optimizasyonu ile)
  Future<Response> refreshPost(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    try {
      final Response response = await _refreshDio.post(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      );
      return response;
    } on DioException {
      rethrow;
    } catch (e) {
      rethrow;
    }
  }
}
