import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mobile/app/modules/accounts/controllers/accounts_controller.dart';
import 'package:mobile/app/modules/budgets/controllers/budgets_controller.dart';
import 'package:mobile/app/modules/dashboard/controllers/dashboard_controller.dart';
import 'package:mobile/app/modules/settings/settings_controller.dart';
import 'package:mobile/app/modules/transactions/controllers/transactions_controller.dart';

/// HomeScreen'in state'ini ve modül verilerinin yüklenmesini yönetir.
class HomeController extends GetxController {
  // Alt navigasyon ve sayfa görünümü için kullanılan kontrolcüler
  final RxInt selectedIndex = 0.obs;
  late final PageController pageController;

  // Animasyon durumları
  final RxBool isChangingTab = false.obs;
  final Rx<double> navigationBarAnimationValue = 1.0.obs;

  // Uygulama geneli yükleme durumları
  final RxBool isInitialLoading = false.obs;
  final RxString loadingMessage = ''.obs;
  final RxBool hasError = false.obs;
  final RxString errorMessage = ''.obs;

  // Alt sekmelerin controller'larını saklamak için değişkenler
  late final DashboardController _dashboardController;
  late final AccountsController _accountsController;
  late final TransactionsController _transactionsController;
  late final BudgetsController _budgetsController;
  late final SettingsController _settingsController;

  // Her modül için yükleme durumlarını tutan değişkenler
  final RxBool isDashboardLoaded = false.obs;
  final RxBool isAccountsLoaded = false.obs;
  final RxBool isTransactionsLoaded = false.obs;
  final RxBool isBudgetsLoaded = false.obs;

  // Alt sekmelerin her birine erişecek getter'lar
  DashboardController get dashboardController => _dashboardController;

  AccountsController get accountsController => _accountsController;

  TransactionsController get transactionsController => _transactionsController;

  BudgetsController get budgetsController => _budgetsController;

  SettingsController get settingsController => _settingsController;

  @override
  void onInit() {
    super.onInit();
    _initializeApp();
  }

  /// Uygulama başlangıç işlemlerini yönetir
  Future<void> _initializeApp() async {
    try {
      isInitialLoading.value = true;
      loadingMessage.value = 'Uygulama başlatılıyor...';

      // PageController'ı başlat
      pageController = PageController(initialPage: selectedIndex.value);

      // Controller'ları başlat
      loadingMessage.value = 'Controller\'lar yükleniyor...';
      await _initControllers();

      // İlk verileri yükle (sadece dashboard için)
      loadingMessage.value = 'Veriler yükleniyor...';
      await _loadInitialDashboardData();

      hasError.value = false;
      errorMessage.value = '';
    } catch (e) {
      hasError.value = true;
      errorMessage.value = 'Uygulama başlatılırken hata oluştu: $e';
      printError(info: 'Error during app initialization: $e');
    } finally {
      isInitialLoading.value = false;
      loadingMessage.value = '';
    }
  }

  /// Alt modül controller'larını başlatır
  Future<void> _initControllers() async {
    try {
      _dashboardController = Get.find<DashboardController>();
      _accountsController = Get.find<AccountsController>();
      _transactionsController = Get.find<TransactionsController>();
      _budgetsController = Get.find<BudgetsController>();
      _settingsController = Get.find<SettingsController>();
    } catch (e) {
      throw Exception('Controller\'lar yüklenemedi: $e');
    }
  }

  /// Sadece dashboard verilerini yükler
  Future<void> _loadInitialDashboardData() async {
    try {
      if (!isDashboardLoaded.value) {
        await _dashboardController.loadDashboardData();
        isDashboardLoaded.value = true;
      }
    } catch (e) {
      printError(info: 'Error loading initial dashboard data: $e');
      rethrow;
    }
  }

  @override
  void onClose() {
    pageController.dispose();
    super.onClose();
  }

  /// Sekme değiştirildiğinde çağrılacak metot.
  void changeTabIndex(int index) async {
    if (selectedIndex.value == index) return;

    // Animasyonu başlat
    isChangingTab.value = true;
    navigationBarAnimationValue.value = 0.8;

    // Kısa gecikme ile tam animasyonu görünür yap
    await Future.delayed(const Duration(milliseconds: 100));
    selectedIndex.value = index;

    // PageView'i güncelle
    if (pageController.hasClients) {
      pageController.jumpToPage(index);
    }

    // Seçilen sekmenin verilerini yükle
    await _loadModuleData(index);

    // Animasyonu tamamla
    await Future.delayed(const Duration(milliseconds: 200));
    navigationBarAnimationValue.value = 1.0;
    isChangingTab.value = false;
  }

  /// Seçilen sekmenin verilerini yükler
  Future<void> _loadModuleData(int index) async {
    try {
      switch (index) {
        case 0: // Dashboard
          if (!isDashboardLoaded.value) {
            await _dashboardController.loadDashboardData();
            isDashboardLoaded.value = true;
          }
          break;
        case 1: // Accounts
          if (!isAccountsLoaded.value) {
            await _accountsController.loadAccounts();
            isAccountsLoaded.value = true;
          }
          break;
        case 2: // Transactions
          if (!isTransactionsLoaded.value) {
            await _transactionsController.loadTransactions();
            isTransactionsLoaded.value = true;
          }
          break;
        case 3: // Budgets
          if (!isBudgetsLoaded.value) {
            await _budgetsController.loadBudgets();
            isBudgetsLoaded.value = true;
          }
          break;
      }
    } catch (e) {
      printError(info: 'Error loading module data for index $index: $e');
    }
  }

  /// Tüm modüllerin verilerini yeniler
  Future<void> refreshAllData() async {
    try {
      isDashboardLoaded.value = false;
      isAccountsLoaded.value = false;
      isTransactionsLoaded.value = false;
      isBudgetsLoaded.value = false;

      // Aktif sekmenin verilerini öncelikli olarak yükle
      await _loadModuleData(selectedIndex.value);

      // Diğer modüllerin verilerini arka planda yükle
      for (var i = 0; i < 4; i++) {
        if (i != selectedIndex.value) {
          _loadModuleData(i);
        }
      }
    } catch (e) {
      printError(info: 'Error refreshing all data: $e');
    }
  }

  /// Belirli bir modülün verilerini yeniler
  Future<void> refreshModuleData(int moduleIndex) async {
    try {
      switch (moduleIndex) {
        case 0:
          isDashboardLoaded.value = false;
          break;
        case 1:
          isAccountsLoaded.value = false;
          break;
        case 2:
          isTransactionsLoaded.value = false;
          break;
        case 3:
          isBudgetsLoaded.value = false;
          break;
      }
      await _loadModuleData(moduleIndex);
    } catch (e) {
      printError(info: 'Error refreshing module $moduleIndex: $e');
    }
  }
}
