import 'package:get/get.dart';
import 'package:mobile/app/domain/repositories/auth_repository.dart';
import 'package:mobile/app/modules/auth/controllers/login_controller.dart';
import 'package:mobile/app/modules/auth/controllers/register_controller.dart';
import 'package:mobile/app/modules/auth/services/auth_data_service.dart';
import 'package:mobile/app/modules/auth/services/auth_form_service.dart';
import 'package:mobile/app/modules/auth/services/auth_navigation_service.dart';
import 'package:mobile/app/modules/auth/services/auth_ui_service.dart';

/// Auth modülü için bağımlılıkları (dependency injection) yönetir.
/// DIP (Dependency Inversion Principle) için gerekli bağımlılıkları bağlar
class AuthBinding extends Bindings {
  @override
  void dependencies() {
    // Önce servisleri kaydet
    _registerServices();

    // Sonra controller'ları kaydet
    _registerControllers();
  }

  /// Auth modülü için servisleri kaydeder
  void _registerServices() {
    // Repository bağımlılığını al
    final authRepository = Get.find<IAuthRepository>();

    // Servisleri kaydet
    Get.lazyPut<AuthDataService>(
      () => AuthDataService(authRepository),
      fenix: true,
    );

    Get.lazyPut<AuthFormService>(
      () => AuthFormService(),
      fenix: true,
    );

    Get.lazyPut<AuthNavigationService>(
      () => AuthNavigationService(),
      fenix: true,
    );

    Get.lazyPut<AuthUIService>(
      () => AuthUIService(),
      fenix: true,
    );
  }

  /// Auth modülü için controller'ları kaydeder
  void _registerControllers() {
    // LoginController - Servis bağımlılıklarını inject et
    Get.lazyPut<LoginController>(
      () => LoginController(
        dataService: Get.find<AuthDataService>(),
        formService: Get.find<AuthFormService>(),
        navigationService: Get.find<AuthNavigationService>(),
        uiService: Get.find<AuthUIService>(),
      ),
      fenix: true,
    );

    // RegisterController - Servis bağımlılıklarını inject et
    Get.lazyPut<RegisterController>(
      () => RegisterController(
        dataService: Get.find<AuthDataService>(),
        formService: Get.find<AuthFormService>(),
        navigationService: Get.find<AuthNavigationService>(),
        uiService: Get.find<AuthUIService>(),
      ),
      fenix: true,
    );
  }
}
