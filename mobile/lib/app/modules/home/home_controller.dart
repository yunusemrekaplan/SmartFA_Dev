import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mobile/app/modules/accounts/controllers/accounts_controller.dart';
import 'package:mobile/app/modules/budgets/controllers/budgets_controller.dart';
import 'package:mobile/app/modules/dashboard/controllers/dashboard_controller.dart';
import 'package:mobile/app/modules/settings/settings_controller.dart';
import 'package:mobile/app/modules/transactions/controllers/transactions_controller.dart';

/// HomeScreen'in state'ini (özellikle aktif sekme index'ini) yönetir.
class HomeController extends GetxController {
  // Alt navigasyon ve sayfa görünümü için kullanılan kontrolcüler
  final RxInt selectedIndex = 0.obs;
  late final PageController pageController;

  // Animasyon durumları
  final RxBool isChangingTab = false.obs;
  final Rx<double> navigationBarAnimationValue = 1.0.obs;

  // Alt sekmelerin controller'larını saklamak için değişkenler
  late final DashboardController _dashboardController;
  late final AccountsController _accountsController;
  late final TransactionsController _transactionsController;
  late final BudgetsController _budgetsController;
  late final SettingsController _settingsController;

  // Yenileme kilitlerini tutan değişkenler (duplicate istekleri önlemek için)
  final RxBool _isRefreshingDashboard = false.obs;
  final RxBool _isRefreshingAccounts = false.obs;
  final RxBool _isRefreshingTransactions = false.obs;
  final RxBool _isRefreshingBudgets = false.obs;

  // Alt sekmelerin her birine erişecek getter'lar
  DashboardController get dashboardController => _dashboardController;
  AccountsController get accountsController => _accountsController;
  TransactionsController get transactionsController => _transactionsController;
  BudgetsController get budgetsController => _budgetsController;
  SettingsController get settingsController => _settingsController;

  // Son yenileme zamanını tutmak için değişken
  DateTime? _lastDashboardRefresh;

  @override
  void onInit() {
    super.onInit();
    // PageController'ı başlat
    pageController = PageController(initialPage: selectedIndex.value);
    _initControllers();

    // Sekme değişimlerini dinleyerek gerekli işlemleri yap
    ever(selectedIndex, _handleTabChange);
  }

  @override
  void onClose() {
    // Controller'ları dispose et
    pageController.dispose();
    super.onClose();
  }

  /// Alt modül controller'larına erişim için onları bulur ve saklar
  void _initControllers() {
    try {
      _dashboardController = Get.find<DashboardController>();
      _accountsController = Get.find<AccountsController>();
      _transactionsController = Get.find<TransactionsController>();
      _budgetsController = Get.find<BudgetsController>();
      _settingsController = Get.find<SettingsController>();
    } catch (e) {
      printError(info: 'Tab controllers could not be loaded: $e');
      // Hata durumunda binding'leri kontrol et
    }
  }

  /// Sekme değiştirildiğinde çağrılacak metot.
  /// Animasyonlu geçiş için sayfa geçişlerini yönetir.
  void changeTabIndex(int index) {
    if (selectedIndex.value == index) {
      return; // Zaten seçili sekme seçilirse işlem yapma
    }

    // Animasyonu başlat
    isChangingTab.value = true;
    navigationBarAnimationValue.value = 0.8; // Küçült

    // Kısa gecikme ile tam animasyonu görünür yap
    Future.delayed(const Duration(milliseconds: 100), () {
      selectedIndex.value = index;

      // PageView'i de güncelle
      if (pageController.hasClients) {
        pageController.jumpToPage(index);
      }

      // Animasyonu tamamla
      Future.delayed(const Duration(milliseconds: 200), () {
        navigationBarAnimationValue.value = 1.0; // Geri büyüt
        isChangingTab.value = false;
      });
    });
  }

  /// Sekme değiştiğinde yapılacak işlemleri yönetir
  void _handleTabChange(int index) {
    // Sekmeye göre yenileme veya veri getirme işlemleri
    // Eğer aynı sekmeye tekrar tıklanırsa yenileme yapma
    if (index == selectedIndex.value) {
      return;
    }

    switch (index) {
      case 0: // Dashboard
        // Dashboard için özel kontrol - sadece gerektiğinde yenile
        if (_dashboardController.isLoading.value ||
            _isRefreshingDashboard.value) {
          print(
              '>>> HomeController: Dashboard is already loading or refreshing, skipping');
          return;
        }
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
    }
  }

  /// Dashboard verilerini yeniler
  void _refreshDashboard() {
    // Zaten yenileniyor mu kontrol et
    if (_isRefreshingDashboard.value) {
      print(
          '>>> HomeController: Dashboard refresh already in progress, skipping');
      return;
    }

    // Son yenileme zamanını kontrol et
    final now = DateTime.now();
    if (_lastDashboardRefresh != null) {
      final difference = now.difference(_lastDashboardRefresh!);
      if (difference.inSeconds < 5) {
        // Minimum 5 saniye ara
        print('>>> HomeController: Dashboard refresh too frequent, skipping');
        return;
      }
    }

    try {
      print('>>> HomeController: Refreshing dashboard data');
      _isRefreshingDashboard.value = true;
      _lastDashboardRefresh = now;

      // Önce yükleme durumunu kontrol edelim
      if (_dashboardController.isLoading.value) {
        print('>>> HomeController: Dashboard already loading, resetting state');
        _dashboardController.resetLoadingState();
        // Yükleme durumunun tamamen sıfırlandığından emin olmak için kısa bir gecikme
        Future.delayed(const Duration(milliseconds: 100));
      }

      _dashboardController.refreshDashboardData().then((_) {
        print('>>> HomeController: Dashboard refresh completed');
      }).catchError((error) {
        printError(info: 'Error during dashboard refresh: $error');
      }).whenComplete(() {
        _isRefreshingDashboard.value = false;
      });
    } catch (e) {
      printError(info: 'Error refreshing dashboard: $e');
      _isRefreshingDashboard.value = false;
    }
  }

  /// Hesaplar verilerini yeniler
  void _refreshAccounts() async {
    // Zaten yenileniyor mu kontrol et
    if (_isRefreshingAccounts.value) {
      print(
          '>>> HomeController: Accounts refresh already in progress, skipping');
      return;
    }

    try {
      print('>>> HomeController: Refreshing accounts data');
      _isRefreshingAccounts.value = true;

      // Force parametresini true olarak geçerek yükleme durumunu sıfırlamayı sağla
      await _accountsController.refreshAccounts(force: true);
      print('>>> HomeController: Accounts refresh completed');
    } catch (e) {
      printError(info: 'Error refreshing accounts: $e');

      // Hata durumunda yükleme durumunu sıfırla
      if (_accountsController.isLoading.value) {
        _accountsController.resetLoadingState();
      }
    } finally {
      _isRefreshingAccounts.value = false;
    }
  }

  /// İşlemler verilerini yeniler
  void _refreshTransactions() async {
    // Zaten yenileniyor mu kontrol et
    if (_isRefreshingTransactions.value) {
      print(
          '>>> HomeController: Transactions refresh already in progress, skipping');
      return;
    }

    try {
      print('>>> HomeController: Refreshing transactions data');
      _isRefreshingTransactions.value = true;

      // Önce yükleme durumunu kontrol edelim ve gerekirse sıfırlayalım
      if (_transactionsController.isLoading.value) {
        print(
            '>>> HomeController: Transactions already loading, resetting state');
        _transactionsController.resetLoadingState();

        // Yükleme durumunun tamamen sıfırlandığından emin olmak için kısa bir gecikme
        await Future.delayed(const Duration(milliseconds: 100));
      }

      // Force parametresini true olarak geçerek yükleme durumunu sıfırlamayı sağla
      await _transactionsController.fetchTransactions(
          isInitialLoad: true, force: true);
      print('>>> HomeController: Transactions refresh completed');
    } catch (e) {
      printError(info: 'Error refreshing transactions: $e');

      // Hata durumunda yükleme durumunu sıfırla
      if (_transactionsController.isLoading.value) {
        _transactionsController.resetLoadingState();
      }
    } finally {
      _isRefreshingTransactions.value = false;
    }
  }

  /// Bütçeler verilerini yeniler
  void _refreshBudgets() async {
    // Zaten yenileniyor mu kontrol et
    if (_isRefreshingBudgets.value) {
      print(
          '>>> HomeController: Budgets refresh already in progress, skipping');
      return;
    }

    try {
      print('>>> HomeController: Refreshing budgets data');
      _isRefreshingBudgets.value = true;

      // Önce yükleme durumunu kontrol edelim ve gerekirse sıfırlayalım
      if (_budgetsController.isLoading.value) {
        print('>>> HomeController: Budgets already loading, resetting state');
        _budgetsController.resetLoadingState();

        // Yükleme durumunun tamamen sıfırlandığından emin olmak için kısa bir gecikme
        await Future.delayed(const Duration(milliseconds: 100));
      }

      // Force parametresini true olarak geçerek yükleme durumunu sıfırlamayı sağla
      await _budgetsController.refreshBudgets(force: true);
      print('>>> HomeController: Budgets refresh completed');
    } catch (e) {
      printError(info: 'Error refreshing budgets: $e');

      // Hata durumunda yükleme durumunu sıfırla
      if (_budgetsController.isLoading.value) {
        _budgetsController.resetLoadingState();
      }
    } finally {
      _isRefreshingBudgets.value = false;
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
