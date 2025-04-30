import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mobile/app/data/datasources/local/auth_local_datasource.dart';
import 'package:mobile/app/data/network/exceptions.dart';
import 'package:mobile/app/domain/repositories/auth_repository.dart';
import 'package:mobile/app/navigation/app_routes.dart';
import 'package:mobile/app/utils/result.dart';

/// Ayarlar ekranının iş mantığını yöneten GetX controller.
class SettingsController extends GetxController {
  final IAuthRepository _authRepository;

  SettingsController({required IAuthRepository authRepository}) : _authRepository = authRepository;

  // Yüklenme durumu (örn: çıkış yaparken)
  final RxBool isLoading = false.obs;

  /// Kategori Yönetimi ekranına yönlendirir.
  void goToCategories() {
    Get.toNamed(AppRoutes.CATEGORIES);
  }

  /// Profil ekranına yönlendirir.
  void goToProfile() {
    Get.toNamed(AppRoutes.PROFILE);
    // Veya Get.to(() => ProfileScreen(), binding: ProfileBinding());
  }

  /// Borçlar ekranına yönlendirir (Eğer Ayarlar altındaysa).
  void goToDebts() {
    Get.toNamed(AppRoutes.DEBTS);
    // Veya ilgili binding ile: Get.to(() => DebtsScreen(), binding: DebtsBinding());
  }

  /// Kullanıcının oturumunu kapatır.
  Future<void> logout() async {
    isLoading.value = true;
    try {
      // TODO: Yerelde saklanan refresh token'ı alıp API'ye göndermek daha doğru olur.
      // Şimdilik AuthRepository'de token temizleme olduğunu varsayıyoruz.
      // Eğer AuthRepository'de logout metodu varsa onu kullan:
      // final result = await _authRepository.logout();

      // Eğer sadece revoke varsa ve token gerekiyorsa:
      // final localDataSource = Get.find<IAuthLocalDataSource>(); // LocalDataSource'u bul
      // final refreshToken = await localDataSource.getRefreshToken();
      // Result result = Result.success(null); // Varsayılan başarı
      // if (refreshToken != null) {
      //    result = await _authRepository.revokeToken(refreshToken);
      // } else {
      //    // Refresh token yoksa yerel temizlik yeterli olabilir
      //    await localDataSource.clearTokens();
      // }

      // Şimdilik en basit senaryo: Sadece yerel tokenları temizle ve login'e git
      // (Bu, backend'deki refresh token'ı iptal etmez)
      final localDataSource = Get.find<IAuthLocalDataSource>(); // LocalDataSource'u bul
      await localDataSource.clearTokens();
      final Result<void, ApiException> result = Success(null); // Geçici olarak başarı varsay

      result.when(
        success: (_) {
          // Başarılı çıkış: Login ekranına yönlendir (tüm geçmişi temizle)
          Get.offAllNamed(AppRoutes.LOGIN);
        },
        failure: (error) {
          // Başarısız çıkış (API hatası vb.)
          print('Logout failed: ${error.message}');
          Get.snackbar(
            'Çıkış Yapılamadı',
            error.message,
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.redAccent,
            colorText: Colors.white,
          );
        },
      );
    } catch (e) {
      // Beklenmedik hata
      print('Logout unexpected error: $e');
      Get.snackbar(
        'Hata',
        'Çıkış yapılırken beklenmedik bir hata oluştu.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

// Diğer ayar seçenekleri için metotlar eklenebilir
// (örn: tema değiştirme, dil değiştirme, bildirim ayarları vb.)
}
