import 'package:get/get.dart';
import 'package:mobile/app/domain/repositories/account_repository.dart';
import 'package:mobile/app/modules/accounts/controllers/accounts_controller.dart';
import 'package:mobile/app/modules/accounts/services/account_data_service.dart';
import 'package:mobile/app/modules/accounts/services/account_navigation_service.dart';
import 'package:mobile/app/modules/accounts/services/account_ui_service.dart';

/// Accounts modülü için bağımlılık enjeksiyonu sağlayan binding sınıfı
/// DIP (Dependency Inversion Principle) için gerekli bağımlılıkları bağlar
class AccountsBinding implements Bindings {
  @override
  void dependencies() {
    // Repositories
    final accountRepository = Get.find<IAccountRepository>();

    // Services
    Get.lazyPut<AccountDataService>(
      () => AccountDataService(accountRepository),
      fenix: true,
    );

    Get.lazyPut<AccountNavigationService>(
      () => AccountNavigationService(),
      fenix: true,
    );

    Get.lazyPut<AccountUIService>(
      () => AccountUIService(),
      fenix: true,
    );

    // Controller
    Get.lazyPut<AccountsController>(
      () => AccountsController(
        dataService: Get.find<AccountDataService>(),
        navigationService: Get.find<AccountNavigationService>(),
        uiService: Get.find<AccountUIService>(),
      ),
    );
  }
}
