import 'package:get/get.dart';
import 'package:mobile/app/modules/accounts/accounts_controller.dart';
import 'package:mobile/app/modules/budgets/budgets_controller.dart';
import 'package:mobile/app/modules/dashboard/dashboard_controller.dart';
import 'package:mobile/app/modules/settings/settings_controller.dart';
import 'package:mobile/app/modules/transactions/transactions_controller.dart';

/// HomeScreen'in state'ini (özellikle aktif sekme index'ini) yönetir.
class HomeController extends GetxController {
  // BottomNavigationBar'daki seçili sekmenin index'ini tutan reaktif değişken.
  // Başlangıçta ilk sekme (Dashboard) seçili olsun (index 0).
  final RxInt selectedIndex = 0.obs;

  // Alt sekmelerin controller'larını saklamak için değişkenler
  late final DashboardController _dashboardController;
  late final AccountsController _accountsController;
  late final TransactionsController _transactionsController;
  late final BudgetsController _budgetsController;
  late final SettingsController _settingsController;

  // Alt sekmelerin her birine erişecek getter'lar
  DashboardController get dashboardController => _dashboardController;
  AccountsController get accountsController => _accountsController;
  TransactionsController get transactionsController => _transactionsController;
  BudgetsController get budgetsController => _budgetsController;
  SettingsController get settingsController => _settingsController;

  @override
  void onInit() {
    super.onInit();
    _initControllers();

    // Sekme değişimlerini dinleyerek gerekli işlemleri yap
    ever(selectedIndex, _handleTabChange);
  }

  /// Alt modül controller'larına erişim için onları bulur ve saklar
  void _initControllers() {
    try {
      _dashboardController = Get.find<DashboardController>();
      _accountsController = Get.find<AccountsController>();
      _transactionsController = Get.find<TransactionsController>();
      _budgetsController = Get.find<BudgetsController>();
      _settingsController = Get.find<SettingsController>();
      print('>>> All tab controllers loaded successfully');
    } catch (e) {
      print('>>> Error finding tab controllers: $e');
      // Hata durumunda binding'leri kontrol et
    }
  }

  /// Sekme değiştirildiğinde çağrılacak metot.
  void changeTabIndex(int index) {
    selectedIndex.value = index;
  }

  /// Sekme değiştiğinde yapılacak işlemleri yönetir
  void _handleTabChange(int index) {
    print('Selected Tab Index: $index');

    // Sekmeye göre yenileme veya veri getirme işlemleri
    switch (index) {
      case 0: // Dashboard
        _refreshDashboard();
        break;
      case 1: // Accounts
        _refreshAccounts();
        break;
      case 2: // Transactions
        _refreshTransactions();
        break;
      case 3: // Budgets
        _refreshBudgets();
        break;
      case 4: // Settings
        // Ayarlar için özel bir yenileme gerekmeyebilir
        break;
    }
  }

  /// Dashboard verilerini yeniler
  void _refreshDashboard() {
    try {
      _dashboardController.refreshData();
    } catch (e) {
      print('>>> Error refreshing dashboard: $e');
    }
  }

  /// Hesaplar verilerini yeniler
  void _refreshAccounts() {
    try {
      _accountsController.fetchAccounts();
    } catch (e) {
      print('>>> Error refreshing accounts: $e');
    }
  }

  /// İşlemler verilerini yeniler
  void _refreshTransactions() {
    try {
      _transactionsController.fetchTransactions(isInitialLoad: false);
    } catch (e) {
      print('>>> Error refreshing transactions: $e');
    }
  }

  /// Bütçeler verilerini yeniler
  void _refreshBudgets() {
    try {
      _budgetsController.refreshBudgets();
    } catch (e) {
      print('>>> Error refreshing budgets: $e');
    }
  }

  /// Uygulama genelinde veri yenileme
  void refreshAllData() {
    _refreshDashboard();
    _refreshAccounts();
    _refreshTransactions();
    _refreshBudgets();
  }
}
