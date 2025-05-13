import 'package:get/get.dart';
import 'package:mobile/app/domain/repositories/account_repository.dart';
import 'package:mobile/app/modules/accounts/controllers/add_edit_account_controller.dart';
import 'package:mobile/app/modules/accounts/services/account_form_service.dart';
import 'package:mobile/app/modules/accounts/services/account_navigation_service.dart';
import 'package:mobile/app/modules/accounts/services/account_ui_service.dart';
import 'package:mobile/app/modules/accounts/services/account_update_service.dart';

/// AddEditAccount modülü için bağımlılık enjeksiyonu sağlayan binding sınıfı
/// DIP (Dependency Inversion Principle) için gerekli bağımlılıkları bağlar
class AddEditAccountBinding implements Bindings {
  @override
  void dependencies() {
    // Repositories
    final accountRepository = Get.find<IAccountRepository>();

    // Services
    Get.lazyPut<AccountFormService>(
      () => AccountFormService(),
      fenix: true,
    );

    Get.lazyPut<AccountUpdateService>(
      () => AccountUpdateService(accountRepository),
      fenix: true,
    );

    if (!Get.isRegistered<AccountNavigationService>()) {
      Get.lazyPut<AccountNavigationService>(
        () => AccountNavigationService(),
        fenix: true,
      );
    }

    if (!Get.isRegistered<AccountUIService>()) {
      Get.lazyPut<AccountUIService>(
        () => AccountUIService(),
        fenix: true,
      );
    }

    // Controller
    Get.lazyPut<AddEditAccountController>(
      () => AddEditAccountController(
        formService: Get.find<AccountFormService>(),
        updateService: Get.find<AccountUpdateService>(),
        navigationService: Get.find<AccountNavigationService>(),
        uiService: Get.find<AccountUIService>(),
      ),
    );
  }
}
