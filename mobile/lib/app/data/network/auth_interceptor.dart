import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';

// Token'ları saklamak için kullanılacak key'ler
const String _accessTokenKey = 'accessToken';

class AuthInterceptor extends Interceptor {
  // GetX kullanarak FlutterSecureStorage'ı enjekte et
  late final FlutterSecureStorage _secureStorage;

  AuthInterceptor() {
    try {
      // GetX ile FlutterSecureStorage'ı bul
      _secureStorage = Get.find<FlutterSecureStorage>();
      print('>>> AuthInterceptor: FlutterSecureStorage injected from GetX');
    } catch (e) {
      // Fallback olarak doğrudan oluştur
      _secureStorage = const FlutterSecureStorage();
      print(
          '>>> AuthInterceptor: Using default FlutterSecureStorage, error: $e');
    }
  }

  @override
  void onRequest(
      RequestOptions options, RequestInterceptorHandler handler) async {
    print('>>> AuthInterceptor: Processing request to ${options.path}');

    // Korumalı olmayan endpoint'leri (login, register, refresh) kontrol et
    final isPublicPath = options.path.contains('/auth/login') ||
        options.path.contains('/auth/register') ||
        options.path.contains('/auth/refresh');

    if (!isPublicPath) {
      try {
        // Güvenli depolamadan access token'ı oku (timeout ile)
        print(
            '>>> AuthInterceptor: Reading access token for protected route ${options.path}');

        final String? accessToken =
            await _secureStorage.read(key: _accessTokenKey).timeout(
          const Duration(milliseconds: 2000), // 2 saniye timeout
          onTimeout: () {
            print('>>> AuthInterceptor: Token read timeout');
            return null;
          },
        );

        if (accessToken != null && accessToken.isNotEmpty) {
          // Authorization header'ını ekle
          options.headers['Authorization'] = 'Bearer $accessToken';
          print('>>> AuthInterceptor: Access token added to request headers');
        } else {
          print(
              '>>> AuthInterceptor: No valid access token found for protected route');
        }
      } catch (e) {
        print('>>> AuthInterceptor: Error reading access token: $e');
        // Token okuma hatası durumunda header eklemeden devam et
        // ErrorInterceptor 401 hatasını yakalayıp token yenileme işlemini başlatacak
      }
    } else {
      print('>>> AuthInterceptor: Public endpoint, skipping token check');
    }

    // İsteği devam ettir
    handler.next(options);
  }

  // Küçük yardımcı metod
  int min(int a, int b) => a < b ? a : b;
}
