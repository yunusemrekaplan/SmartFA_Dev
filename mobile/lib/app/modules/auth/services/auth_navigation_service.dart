import 'package:get/get.dart';
import 'package:mobile/app/navigation/app_routes.dart';

/// Auth modülündeki navigasyon işlemlerini yöneten servis
/// SRP (Single Responsibility Principle) - Navigasyon işlemleri tek bir sınıfta toplanır
class AuthNavigationService {
  /// Login ekranına yönlendirir
  void goToLogin() {
    Get.toNamed(AppRoutes.LOGIN);
  }

  /// Register ekranına yönlendirir
  void goToRegister() {
    Get.toNamed(AppRoutes.REGISTER);
  }

  /// Başarılı giriş/kayıt sonrası ana ekrana yönlendirir
  void goToHomeAfterAuth() {
    Get.offAllNamed(AppRoutes.HOME);
  }

  /// Önceki ekrana dönüş
  void goBack() {
    Get.back();
  }

  /// Password reset ekranına yönlendirir (henüz uygulanmadı)
  void goToPasswordReset() {
    // Şu anda uygulanmadı - ilerde eklenecek
    // Get.toNamed(AppRoutes.PASSWORD_RESET);
  }
}
