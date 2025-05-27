import 'package:get/get.dart';
import 'package:mobile/app/data/datasources/local/auth_local_datasource.dart';
import 'package:mobile/app/navigation/app_routes.dart';
import 'dart:async';

/// Splash ekranı ve oturum kontrolü için controller sınıfı
class SplashController extends GetxController {
  final IAuthLocalDataSource _authLocalDataSource;

  // Loading durumu
  final RxBool isChecking = true.obs;
  final RxString statusMessage = 'Başlatılıyor...'.obs;

  SplashController({required IAuthLocalDataSource authLocalDataSource})
      : _authLocalDataSource = authLocalDataSource {
    print('>>> SplashController: Constructor çağrıldı.');
  }

  @override
  void onInit() {
    super.onInit();
    print(
        '>>> SplashController: onInit çağrıldı, authentication kontrol ediliyor...');

    // Hızlı kontrol için minimal gecikme
    Future.delayed(const Duration(milliseconds: 100), () {
      _checkAuthentication();
    });
  }

  /// Kullanıcının oturum durumunu kontrol eder ve uygun ekrana yönlendirir
  Future<void> _checkAuthentication() async {
    print('>>> SplashController: _checkAuthentication başlatıldı');

    try {
      isChecking.value = true;
      statusMessage.value = 'Oturum kontrol ediliyor...';

      // Token kontrolü
      String? accessToken;
      String? refreshToken;

      try {
        print('>>> SplashController: Token kontrol ediliyor...');

        // Parallel olarak her iki token'ı da oku
        final tokenFutures = await Future.wait([
          _authLocalDataSource.getAccessToken(),
          _authLocalDataSource.getRefreshToken(),
        ]);

        accessToken = tokenFutures[0];
        refreshToken = tokenFutures[1];

        print(
            '>>> SplashController: AccessToken: ${accessToken?.isEmpty == true ? "boş" : (accessToken == null ? "null" : "var")}');
        print(
            '>>> SplashController: RefreshToken: ${refreshToken?.isEmpty == true ? "boş" : (refreshToken == null ? "null" : "var")}');
      } catch (e) {
        print('>>> SplashController: Token okuma hatası: $e');
        accessToken = null;
        refreshToken = null;
      }

      final hasValidSession = (accessToken != null && accessToken.isNotEmpty) ||
          (refreshToken != null && refreshToken.isNotEmpty);

      print(
          '>>> SplashController: Oturum durumu: ${hasValidSession ? "Açık" : "Kapalı"}');

      // Minimum splash görünüm süresi (UX için)
      statusMessage.value =
          hasValidSession ? 'Hoş geldiniz...' : 'Yönlendiriliyor...';
      await Future.delayed(const Duration(milliseconds: 500));

      // Uygun rotaya yönlendir
      if (hasValidSession) {
        print('>>> SplashController: Home ekranına yönlendiriliyor...');
        Get.offAllNamed(AppRoutes.HOME);
      } else {
        print('>>> SplashController: Login ekranına yönlendiriliyor...');
        Get.offAllNamed(AppRoutes.LOGIN);
      }
    } catch (e) {
      print('>>> SplashController: Beklenmedik hata: $e');
      statusMessage.value = 'Hata oluştu...';

      // Hata durumunda login'e yönlendir
      await Future.delayed(const Duration(seconds: 1));
      Get.offAllNamed(AppRoutes.LOGIN);
    } finally {
      isChecking.value = false;
    }
  }

  /// Manuel yeniden kontrol (hata durumunda kullanılabilir)
  Future<void> retryAuthCheck() async {
    print('>>> SplashController: Manuel yeniden kontrol başlatıldı');
    await _checkAuthentication();
  }
}
