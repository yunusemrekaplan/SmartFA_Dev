import 'package:get/get.dart';

// Controller importu (henüz oluşturulmadı)
import 'settings_controller.dart';
// Gerekirse AuthRepository importu (Logout işlemi için)
import '../../domain/repositories/auth_repository.dart';

/// Settings modülü için bağımlılıkları yönetir.
class SettingsBinding extends Bindings {
  @override
  void dependencies() {
    print('>>> SettingsBinding dependencies() called');

    // --- Repository Bağımlılıkları ---
    // AuthRepository (Logout için gerekli, Initial veya Auth binding'de kaydedilmiş olmalı)
    // Get.lazyPut<IAuthRepository>(...); // Eğer burada kaydedilecekse

    // --- Controller Bağımlılığı ---
    // SettingsController'ı kaydet ve gerekli repository'leri inject et.
    Get.lazyPut<SettingsController>(
      () => SettingsController(
        authRepository:
            Get.find<IAuthRepository>(), // Logout için AuthRepository'yi bul
      ),
      fenix: true,
    );
  }
}
