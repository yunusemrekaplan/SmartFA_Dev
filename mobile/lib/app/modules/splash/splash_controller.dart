import 'package:get/get.dart';
import 'package:mobile/app/data/datasources/local/auth_local_datasource.dart';
import 'package:mobile/app/navigation/app_routes.dart';

/// Splash ekranı ve oturum kontrolü için controller sınıfı
class SplashController extends GetxController {
  final IAuthLocalDataSource _authLocalDataSource;

  SplashController({required IAuthLocalDataSource authLocalDataSource})
      : _authLocalDataSource = authLocalDataSource {
    print('>>> SplashController: Constructor çağrıldı.');
  }

  @override
  void onInit() {
    super.onInit();
    print(
        '>>> SplashController: onInit çağrıldı, authentication kontrol ediliyor...');

    // Gecikmeli olarak kontrol et, böylece ekran gösterilsin
    Future.delayed(const Duration(milliseconds: 200), () {
      _checkAuthentication();
    });
  }

  /// Kullanıcının oturum durumunu kontrol eder ve uygun ekrana yönlendirir
  Future<void> _checkAuthentication() async {
    print('>>> SplashController: _checkAuthentication başlatıldı');

    try {
      // Splash ekranında göstermek için kısa bir bekleme
      print('>>> SplashController: 2 saniye bekleniyor...');
      await Future.delayed(const Duration(seconds: 1));

      // Token kontrolü
      String? accessToken;
      try {
        print('>>> SplashController: Token kontrol ediliyor...');
        accessToken = await _authLocalDataSource.getAccessToken();
        print(
            '>>> SplashController: AccessToken: ${accessToken?.isEmpty == true ? "boş" : (accessToken == null ? "null" : "var")}');
      } catch (e) {
        print('>>> SplashController: Token okuma hatası: $e');
        accessToken = null;
      }

      final hasValidSession = accessToken != null && accessToken.isNotEmpty;
      print(
          '>>> SplashController: Oturum durumu: ${hasValidSession ? "Açık" : "Kapalı"}');

      // Geçikmeyi azalt
      await Future.delayed(const Duration(milliseconds: 500));

      if (hasValidSession) {
        print('>>> SplashController: Ana sayfaya yönlendiriliyor...');
        // Oturum açılmış, ana sayfaya yönlendir
        Get.offAllNamed(AppRoutes.HOME);
      } else {
        print('>>> SplashController: Login sayfasına yönlendiriliyor...');
        // Oturum açılmamış, giriş sayfasına yönlendir
        Get.offAllNamed(AppRoutes.LOGIN);
      }
    } catch (e) {
      print('>>> SplashController: Beklenmeyen hata: $e');
      // Herhangi bir hata durumunda login ekranına yönlendir

      // Kısa bir gecikme ekleyelim
      await Future.delayed(const Duration(milliseconds: 500));

      // Ek güvenlik için try-catch
      try {
        Get.offAllNamed(AppRoutes.LOGIN);
      } catch (navigationError) {
        print('>>> SplashController: Navigasyon hatası: $navigationError');
      }
    }
  }
}
