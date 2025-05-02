import 'package:get/get.dart';
import 'package:mobile/app/modules/accounts/accounts_binding.dart';
import 'package:mobile/app/modules/budgets/budgets_binding.dart';
import 'package:mobile/app/modules/dashboard/dashboard_binding.dart';
import 'package:mobile/app/modules/home/home_controller.dart';
import 'package:mobile/app/modules/settings/settings_binding.dart';
import 'package:mobile/app/modules/transactions/transactions_binding.dart';

/// Home modülü ve alt modüllerinin bağımlılıklarını yönetir.
class HomeBinding extends Bindings {
  @override
  void dependencies() {
    // Ana Home Controller
    Get.lazyPut<HomeController>(() => HomeController(), fenix: true);

    // Alt modüllerin binding'lerini yükle
    _initModuleBindings();
  }

  /// Tüm alt modüllerin binding'lerini yükler
  void _initModuleBindings() {
    final modules = [
      DashboardBinding(),
      AccountsBinding(),
      TransactionsBinding(),
      BudgetsBinding(),
      SettingsBinding(),
    ];

    // Her bir modülün binding'ini çalıştır
    for (final binding in modules) {
      try {
        binding.dependencies();
      } catch (e) {
        printError(
            info: 'Error loading dependencies for ${binding.runtimeType}: $e');
      }
    }
  }
}
