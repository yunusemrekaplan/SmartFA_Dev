import 'package:get/get.dart';
import 'package:mobile/app/domain/repositories/auth_repository.dart';
import 'package:mobile/app/modules/auth/controllers/login_controller.dart';
import 'package:mobile/app/modules/auth/controllers/register_controller.dart';

/// Auth modülü için bağımlılıkları (dependency injection) yönetir.
class AuthBinding extends Bindings {
  @override
  void dependencies() {
    // Login ve Register controller'ları GetX bağımlılık sistemi ile kaydet
    _registerControllers();
  }

  /// Auth modülü için controller'ları kaydeder
  void _registerControllers() {
    // Her iki controller için de IAuthRepository bağımlılığını kullan
    Get.lazyPut<LoginController>(
      () => LoginController(authRepository: Get.find<IAuthRepository>()),
      fenix: true, // Aynı instance'ı yeniden kullan
    );

    Get.lazyPut<RegisterController>(
      () => RegisterController(authRepository: Get.find<IAuthRepository>()),
      fenix: true, // Aynı instance'ı yeniden kullan
    );
  }
}
