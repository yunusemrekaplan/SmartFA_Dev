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
    print('>>> HomeBinding dependencies() called');

    // Ana Home Controller (BottomNavBar yönetimi, genel home state'i vb. için)
    // Bu controller, diğer sekmelerin controller'larına erişebilir veya
    // sekme değişimini yönetebilir.
    Get.lazyPut<HomeController>(() => HomeController(), fenix: true);

    // Her bir alt sekmenin binding'ini çalıştır
    // Bu sayede tüm modüller tek seferde yüklenir
    _initDashboardBinding();
    _initAccountsBinding();
    _initTransactionsBinding();
    _initBudgetsBinding();
    _initSettingsBinding();
  }

  /// Dashboard modülü için bağımlılıkları yükler
  void _initDashboardBinding() {
    try {
      DashboardBinding().dependencies();
      print('>>> Dashboard dependencies loaded');
    } catch (e) {
      print('>>> Error loading dashboard dependencies: $e');
    }
  }

  /// Accounts modülü için bağımlılıkları yükler
  void _initAccountsBinding() {
    try {
      AccountsBinding().dependencies();
      print('>>> Accounts dependencies loaded');
    } catch (e) {
      print('>>> Error loading accounts dependencies: $e');
    }
  }

  /// Transactions modülü için bağımlılıkları yükler
  void _initTransactionsBinding() {
    try {
      TransactionsBinding().dependencies();
      print('>>> Transactions dependencies loaded');
    } catch (e) {
      print('>>> Error loading transactions dependencies: $e');
    }
  }

  /// Budgets modülü için bağımlılıkları yükler
  void _initBudgetsBinding() {
    try {
      BudgetsBinding().dependencies();
      print('>>> Budgets dependencies loaded');
    } catch (e) {
      print('>>> Error loading budgets dependencies: $e');
    }
  }

  /// Settings modülü için bağımlılıkları yükler
  void _initSettingsBinding() {
    try {
      SettingsBinding().dependencies();
      print('>>> Settings dependencies loaded');
    } catch (e) {
      print('>>> Error loading settings dependencies: $e');
    }
  }
}
