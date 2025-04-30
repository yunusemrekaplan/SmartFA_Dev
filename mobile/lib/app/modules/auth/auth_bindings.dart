import 'package:get/get.dart';
import 'package:mobile/app/domain/repositories/auth_repository.dart';
import 'package:mobile/app/modules/auth/login/login_controller.dart';
import 'package:mobile/app/modules/auth/register/register_controller.dart';

/// Auth modülü için bağımlılıkları (dependency injection) yönetir.
class AuthBinding extends Bindings {
  @override
  void dependencies() {
    print('>>> AuthBinding dependencies() called');

    // Sadece controller'ları kaydet, diğer bağımlılıklar InitialBinding'den gelecek
    _registerControllers();
  }

  /// Auth modülü için controller'ları kaydeder
  void _registerControllers() {
    // Login Controller - Repository'i InitialBinding'den alır
    Get.lazyPut<LoginController>(
      () => LoginController(
        authRepository: Get.find<IAuthRepository>(),
      ),
      fenix: true,
    );

    // Register Controller - Repository'i InitialBinding'den alır
    Get.lazyPut<RegisterController>(
      () => RegisterController(
        authRepository: Get.find<IAuthRepository>(),
      ),
      fenix: true,
    );

    print('>>> Auth controllers registered');
  }
}
