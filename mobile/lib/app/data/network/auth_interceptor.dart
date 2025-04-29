import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

// Token'ları saklamak için kullanılacak key'ler
const String _accessTokenKey = 'accessToken';

class AuthInterceptor extends Interceptor {
  // flutter_secure_storage instance'ı (GetX ile inject edilebilir veya doğrudan kullanılabilir)
  // final _secureStorage = Get.find<FlutterSecureStorage>(); // GetX örneği
  final _secureStorage = const FlutterSecureStorage(); // Doğrudan kullanım örneği

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    // Korumalı olmayan endpoint'leri (login, register, refresh) kontrol et
    // Bu kontrolü endpoint path'ine göre daha detaylı yapabilirsiniz.
    final isPublicPath = options.path.contains('/auth/login') ||
        options.path.contains('/auth/register') ||
        options.path.contains('/auth/refresh');

    if (!isPublicPath) {
      // Güvenli depolamadan access token'ı oku
      final String? accessToken = await _secureStorage.read(key: _accessTokenKey);

      if (accessToken != null && accessToken.isNotEmpty) {
        // Header'a Bearer token'ı ekle
        options.headers['Authorization'] = 'Bearer $accessToken';
        print('>>> AuthInterceptor: Token added to header for ${options.path}'); // Debug log
      } else {
        print('>>> AuthInterceptor: No access token found for protected route ${options.path}'); // Debug log
        // Token yoksa ne yapılacağına karar verilebilir (örn: hata fırlat, isteği durdur)
        // Şimdilik devam etmesine izin veriyoruz, backend 401 döndürecektir.
      }
    } else {
      print('>>> AuthInterceptor: Public path, no token added for ${options.path}'); // Debug log
    }

    // İsteği devam ettir
    super.onRequest(options, handler);
  }
}
