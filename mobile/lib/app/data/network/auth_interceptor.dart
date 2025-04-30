import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';

// Token'ları saklamak için kullanılacak key'ler
const String _accessTokenKey = 'accessToken';
const String _refreshTokenKey = 'refreshToken';

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
      print('>>> AuthInterceptor: Using default FlutterSecureStorage, error: $e');
    }
  }

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    print('>>> AuthInterceptor: Processing request to ${options.path}');

    // Korumalı olmayan endpoint'leri (login, register, refresh) kontrol et
    final isPublicPath = options.path.contains('/auth/login') ||
        options.path.contains('/auth/register') ||
        options.path.contains('/auth/refresh');

    if (!isPublicPath) {
      try {
        // Güvenli depolamadan access token'ı oku
        print('>>> AuthInterceptor: Reading access token for protected route ${options.path}');
        final String? accessToken = await _secureStorage.read(key: _accessTokenKey);

        if (accessToken != null && accessToken.isNotEmpty) {
          // Header'a Bearer token'ı ekle
          options.headers['Authorization'] = 'Bearer $accessToken';
          print('>>> AuthInterceptor: Token added to header for ${options.path}');
          print(
              '>>> AuthInterceptor: Token: Bearer ${accessToken.substring(0, min(10, accessToken.length))}...');
        } else {
          print(
              '>>> AuthInterceptor: ⚠️ No access token found for protected route ${options.path}');
          // Token yoksa backend 401 döndürecek ve ErrorInterceptor tarafından işlenecek
        }
      } catch (e) {
        print('>>> AuthInterceptor: ⚠️ Error reading token: $e');
        // Hata durumunda devam et, backend 401 döndürecek
      }
    } else {
      print('>>> AuthInterceptor: Public path, no token required for ${options.path}');
    }

    // İsteği devam ettir
    super.onRequest(options, handler);
  }

  // Küçük yardımcı metod
  int min(int a, int b) => a < b ? a : b;
}
