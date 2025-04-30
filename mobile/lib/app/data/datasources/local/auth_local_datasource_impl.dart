import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:mobile/app/data/datasources/local/auth_local_datasource.dart';

/// IAuthLocalDataSource arayüzünün flutter_secure_storage kullanan geliştirilmiş implementasyonu.
class AuthLocalDataSourceImpl implements IAuthLocalDataSource {
  // Token'ları saklamak için kullanılacak key'ler
  static const String _accessTokenKey = 'accessToken';
  static const String _refreshTokenKey = 'refreshToken';

  // FlutterSecureStorage instance'ı
  final FlutterSecureStorage _secureStorage;

  // Constructor
  const AuthLocalDataSourceImpl(this._secureStorage);

  @override
  Future<void> saveTokens(
      {required String accessToken, required String refreshToken}) async {
    try {
      // Android platformunda hata oluşmasını önlemek için önce token kontrolü yap
      if (accessToken.isEmpty || refreshToken.isEmpty) {
        print('>>> AuthLocalDataSource: Boş token kaydedilmeye çalışıldı!');
        return;
      }

      await _secureStorage.write(key: _accessTokenKey, value: accessToken);
      await _secureStorage.write(key: _refreshTokenKey, value: refreshToken);
      print('>>> AuthLocalDataSource: Tokenlar başarıyla kaydedildi.');
    } catch (e) {
      print('>>> AuthLocalDataSource Error saving tokens: $e');
      // Hata yönetimi eklenebilir (örn: özel exception fırlat)
      throw Exception('Token kaydedilirken bir hata oluştu: $e');
    }
  }

  @override
  Future<String?> getAccessToken() async {
    try {
      final token = await _secureStorage.read(key: _accessTokenKey);
      print(
          '>>> AuthLocalDataSource: Access token okuma sonucu: ${token != null ? 'bulundu' : 'bulunamadı'}');
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
      print(
          '>>> AuthLocalDataSource: Refresh token okuma sonucu: ${token != null ? 'bulundu' : 'bulunamadı'}');
      return token;
    } catch (e) {
      print('>>> AuthLocalDataSource Error reading refresh token: $e');
      return null;
    }
  }

  @override
  Future<void> clearTokens() async {
    try {
      // Tek tek silmek yerine tüm storage'ı temizle (daha güvenli)
      await _secureStorage.deleteAll();
      print('>>> AuthLocalDataSource: Tüm tokenlar temizlendi.');
    } catch (e) {
      print('>>> AuthLocalDataSource Error clearing tokens: $e');
      // Hata fırlat ama uygulamanın çökmesini engelle
      print('>>> Token silme hatası: $e');
    }
  }
}
