import 'package:flutter_secure_storage/flutter_secure_storage.dart';

// Token'ları saklamak için kullanılacak key'ler (Auth Interceptor'daki ile aynı olmalı)
const String _accessTokenKey = 'accessToken';
const String _refreshTokenKey = 'refreshToken';

/// Cihazın güvenli depolama alanında authentication token'larını yöneten arayüz.
abstract class IAuthLocalDataSource {
  /// Access ve Refresh token'ları güvenli depolamaya kaydeder.
  Future<void> saveTokens({required String accessToken, required String refreshToken});

  /// Kayıtlı Access token'ı getirir.
  Future<String?> getAccessToken();

  /// Kayıtlı Refresh token'ı getirir.
  Future<String?> getRefreshToken();

  /// Kayıtlı tüm authentication token'larını siler.
  Future<void> clearTokens();
}

/// IAuthLocalDataSource arayüzünün flutter_secure_storage kullanan implementasyonu.
class AuthLocalDataSourceImpl implements IAuthLocalDataSource {
  // FlutterSecureStorage instance'ı
  // constructor injection ile veya doğrudan oluşturulabilir.
  // GetX binding ile yönetmek daha test edilebilir yapar.
  final FlutterSecureStorage _secureStorage;

  // Constructor
  const AuthLocalDataSourceImpl(this._secureStorage);

  @override
  Future<void> saveTokens({required String accessToken, required String refreshToken}) async {
    try {
      await _secureStorage.write(key: _accessTokenKey, value: accessToken);
      await _secureStorage.write(key: _refreshTokenKey, value: refreshToken);
      print('>>> AuthLocalDataSource: Tokens saved successfully.'); // Debug log
    } catch (e) {
      print('>>> AuthLocalDataSource Error saving tokens: $e');
      // Hata yönetimi eklenebilir (örn: özel exception fırlat)
      throw Exception('Token kaydedilirken bir hata oluştu.');
    }
  }

  @override
  Future<String?> getAccessToken() async {
    try {
      final token = await _secureStorage.read(key: _accessTokenKey);
      // print('>>> AuthLocalDataSource: Access token read: ${token != null ? 'found' : 'not found'}'); // Debug log
      return token;
    } catch (e) {
      print('>>> AuthLocalDataSource Error reading access token: $e');
      return null; // Hata durumunda null dön
    }
  }

  @override
  Future<String?> getRefreshToken() async {
    try {
      final token = await _secureStorage.read(key: _refreshTokenKey);
      // print('>>> AuthLocalDataSource: Refresh token read: ${token != null ? 'found' : 'not found'}'); // Debug log
      return token;
    } catch (e) {
      print('>>> AuthLocalDataSource Error reading refresh token: $e');
      return null;
    }
  }

  @override
  Future<void> clearTokens() async {
    try {
      await _secureStorage.delete(key: _accessTokenKey);
      await _secureStorage.delete(key: _refreshTokenKey);
      // Veya tümünü silmek için: await _secureStorage.deleteAll();
      print('>>> AuthLocalDataSource: Tokens cleared successfully.'); // Debug log
    } catch (e) {
      print('>>> AuthLocalDataSource Error clearing tokens: $e');
      throw Exception('Token silinirken bir hata oluştu.');
    }
  }
}
