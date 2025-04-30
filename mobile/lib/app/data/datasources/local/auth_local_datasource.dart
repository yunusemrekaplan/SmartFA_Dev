/// Cihazın güvenli depolama alanında authentication token'larını yöneten arayüz.
abstract class IAuthLocalDataSource {
  /// Access ve Refresh token'ları güvenli depolamaya kaydeder.
  Future<void> saveTokens(
      {required String accessToken, required String refreshToken});

  /// Kayıtlı Access token'ı getirir.
  Future<String?> getAccessToken();

  /// Kayıtlı Refresh token'ı getirir.
  Future<String?> getRefreshToken();

  /// Kayıtlı tüm authentication token'larını siler.
  Future<void> clearTokens();
}
