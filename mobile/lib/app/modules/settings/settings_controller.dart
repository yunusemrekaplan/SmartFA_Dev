import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mobile/app/domain/repositories/auth_repository.dart';
import 'package:mobile/app/navigation/app_routes.dart';

/// Ayarlar ekranının iş mantığını yöneten GetX controller.
class SettingsController extends GetxController {
  final IAuthRepository _authRepository;

  SettingsController({required IAuthRepository authRepository})
      : _authRepository = authRepository;

  // Yüklenme durumu (örn: çıkış yaparken)
  final RxBool isLoading = false.obs;

  // Tema modu değişkeni (açık/koyu tema)
  final RxBool isDarkMode = false.obs;

  // Bildirim durumu
  final RxBool notificationsEnabled = true.obs;

  @override
  void onInit() {
    super.onInit();
    // Burada ayarları local storage'dan yükleyebiliriz
  }

  /// Tema modunu değiştirir
  void toggleThemeMode() {
    isDarkMode.value = !isDarkMode.value;
    // Tema değişikliğini kaydet ve uygula
  }

  /// Bildirim durumunu değiştirir
  void toggleNotifications() {
    notificationsEnabled.value = !notificationsEnabled.value;
    // Bildirim durumunu kaydet
  }

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
    try {
      final result = await _authRepository.logout();

      result.when(
        success: (_) {
          // Başarılı çıkış
          Get.offAllNamed(AppRoutes.LOGIN); // Giriş ekranına yönlendir
          Get.snackbar(
            'Başarılı',
            'Çıkış yapıldı',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.green,
            colorText: Colors.white,
          );
        },
        failure: (error) {
          // Başarısız çıkış
          Get.snackbar(
            'Hata',
            'Çıkış yapılırken bir sorun oluştu: ${error.message}',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.red,
            colorText: Colors.white,
          );
        },
      );
    } catch (e) {
      // Beklenmedik hata
      Get.snackbar(
        'Hata',
        'Beklenmeyen bir hata oluştu',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

// Diğer ayar seçenekleri için metotlar eklenebilir
// (örn: tema değiştirme, dil değiştirme, bildirim ayarları vb.)
}
